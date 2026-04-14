# ADR-005 — Auditoría: Tablas de Log e Historial

| Campo | Detalle |
|---|---|
| **Estado** | Aceptado |
| **Fecha** | Abril 2026 |
| **Dominio** | Transversal (todas las tablas) |
| **Tablas afectadas** | Todas (columnas `created_at`, `updated_at`) + tablas con historial explícito |

---

## Contexto

En un sistema de aerolíneas, los datos cambian constantemente: los niveles de fidelidad de un pasajero suben, el saldo de millas se modifica con cada vuelo, los documentos de identidad se renuevan. Si algo sale mal o hay una queja, el equipo necesita saber exactamente qué pasó y cuándo.

Sin auditoría, esa información simplemente no existe.

---

## Problema

Sin mecanismos de registro de cambios:

- No se puede saber quién modificó un registro ni cuándo.
- Si el saldo de millas de un cliente está mal, no hay forma de rastrear qué transacciones lo causaron.
- Si un nivel de fidelidad cambió incorrectamente, no hay historial del nivel anterior.
- Ante una queja o un proceso de soporte, el equipo no tiene evidencia de lo que ocurrió.

---

## Decisión

Se aplican **dos niveles de auditoría** en el esquema:

### Nivel 1 — Columnas de auditoría en todas las tablas

Todas las 67 tablas del sistema tienen estas dos columnas:

```sql
created_at  timestamptz  NOT NULL DEFAULT now()
updated_at  timestamptz  NOT NULL DEFAULT now()
```

- `created_at`: se registra automáticamente cuando se crea el registro.
- `updated_at`: debe actualizarse cada vez que el registro cambia (mediante trigger o lógica de aplicación).

Esto aplica a absolutamente todas las tablas: desde `continent` hasta `invoice_payment`.

---

### Nivel 2 — Historial explícito en tablas críticas

Para procesos de negocio donde el historial completo importa, se guardan todos los registros anteriores, no solo el estado actual.

#### `loyalty_account_tier` — Historial de niveles de fidelidad

```sql
-- Cada vez que un cliente cambia de nivel (Silver → Gold),
-- se crea un nuevo registro. El anterior no se borra.

loyalty_account_tier_id  | loyalty_account_id | loyalty_tier_id | assigned_at | is_current
HU-tier-001              | cuenta-A           | SILVER          | 2024-01-01  | false
HU-tier-002              | cuenta-A           | GOLD            | 2025-03-15  | true   ← nivel actual
```

El campo `is_current = true` (con índice parcial único) señala el nivel vigente. Los registros anteriores quedan para auditoría y análisis.

---

#### `miles_transaction` — Historial completo de millas con saldo

```sql
-- Cada movimiento de millas queda registrado con el saldo resultante.

miles_transaction_id | loyalty_account_id | transaction_type | miles_delta | balance_after | occurred_at
tx-001               | cuenta-A           | EARN             | +500        | 500           | 2024-06-01
tx-002               | cuenta-A           | EARN             | +300        | 800           | 2024-09-10
tx-003               | cuenta-A           | REDEEM           | -200        | 600           | 2025-01-05
```

La columna `balance_after` guarda el saldo acumulado después de cada transacción. Para saber el saldo actual, solo se necesita el último registro, sin sumar toda la historia.

---

#### `person_document` — Historial de documentos de identidad

```sql
-- Un pasajero puede renovar su pasaporte. El antiguo no se borra.
-- is_primary = true marca el documento activo actualmente.

person_document_id | person_id | document_type | document_number | expires_on | is_primary
doc-001            | persona-A | PASSPORT      | AB123456        | 2024-12-31 | false  ← vencido
doc-002            | persona-A | PASSPORT      | CD789012        | 2030-06-30 | true   ← activo
```

---

## Justificación técnica

- **`created_at` y `updated_at` son el mínimo necesario.** Con solo estas dos columnas se puede responder: "¿cuándo se creó este registro y cuándo fue la última vez que cambió?" Es información que cuesta casi nada almacenar y tiene mucho valor cuando se necesita.

- **El historial en tablas críticas protege al negocio.** Si un cliente dice "me quitaron mis millas del vuelo del 5 de enero", la tabla `miles_transaction` tiene exactamente ese registro con `occurred_at`, `miles_delta` y `balance_after`. No hay ambigüedad.

- **`is_current` como bandera de estado activo** es más eficiente que buscar el registro más reciente con `MAX(fecha)`. Un índice parcial sobre `WHERE is_current = true` permite encontrar el dato vigente en tiempo constante.

- **No se borran registros históricos.** Esta es una decisión de diseño deliberada: los datos del pasado tienen valor. Si se necesita "desactivar" algo (un documento vencido, un nivel anterior), se marca como inactivo, no se elimina.

---

## Qué tablas tienen historial y por qué

| Tabla | Qué registra | Por qué es importante |
|---|---|---|
| `miles_transaction` | Cada movimiento de millas | Saldo trazable, protección ante disputas |
| `loyalty_account_tier` | Cada cambio de nivel del cliente | Auditoría de beneficios y escaladas |
| `person_document` | Cada documento de identidad cargado | Historial de viajes y renovaciones |
| `maintenance_event` | Cada intervención en una aeronave | Trazabilidad de aeronavegabilidad |
| `payment_transaction` | Cada paso del ciclo de pago | Soporte ante cargos disputados |

---

## Consecuencias e impacto esperado

✅ Si un cliente tiene una queja, el equipo de soporte puede rastrear exactamente qué pasó con sus millas, su nivel o sus documentos.

✅ Los reportes históricos son posibles sin necesidad de sistemas externos de logging.

✅ La columna `balance_after` en `miles_transaction` evita recalcular el saldo sumando miles de registros cada vez que alguien consulta su cuenta.

⚠️ Las tablas de historial crecen con el tiempo. Para bases de datos de producción con muchos usuarios, eventualmente será necesario definir una política de archivado de registros muy antiguos.

⚠️ La columna `updated_at` no se actualiza sola: requiere un trigger en la base de datos o que la aplicación lo actualice en cada operación `UPDATE`. Si no se configura, el valor nunca cambiará del momento de creación.
