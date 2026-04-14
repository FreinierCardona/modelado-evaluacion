# ADR-001 — Dominios Funcionales del Esquema

| Campo | Detalle |
|---|---|
| **Estado** | Aceptado |
| **Fecha** | Abril 2026 |
| **Dominio** | Arquitectura de Datos |
| **Tablas afectadas** | 67 tablas (con mejoras en 6 mediante FIX-01 al FIX-06) |

---

## Resumen de Cambios

| ID | Descripción | Tipo | Tablas Afectadas |
|---|---|---|---|
| **FIX-01** | Agregar `is_primary` a `person_document` | Mejora | `person_document` |
| **FIX-02** | Agregar `is_current` a `loyalty_account_tier` con índice parcial | Corrección lógica | `loyalty_account_tier` |
| **FIX-03** | Agregar `balance_after` a `miles_transaction` | Optimización de rendimiento | `miles_transaction` |
| **FIX-04** | Agregar `departure_gate_id` y `arrival_gate_id` a `flight_segment` | Corrección de diseño | `flight_segment` |
| **FIX-05** | Nueva tabla `invoice_payment` para reconciliación pago-factura | Tabla nueva | `invoice_payment` |
| **FIX-06** | Índices faltantes críticos para consultas de negocio | Optimización de rendimiento | Sin cambios de esquema |

---

## Decisiones Detalladas

### FIX-01 — Agregar `is_primary` a `person_document`

**Estado:** Aceptado · **Dominio:** Identidad · **Tipo:** Mejora

**Contexto**

La tabla `person_document` no tenía forma de distinguir cuál es el documento de viaje activo de una persona. En operaciones de check-in y emisión de boarding pass, el sistema necesita recuperar el documento primario sin escanear todos los registros del pasajero.

**Decisión**

Se añade la columna `is_primary boolean NOT NULL DEFAULT false` a `person_document`. Se crea un índice parcial único (`UNIQUE INDEX WHERE is_primary = true`) sobre `(person_id, document_type_id)` para garantizar que solo exista un documento primario activo por persona por tipo en cualquier momento.

**Razonamiento**

El índice parcial es la solución más eficiente en PostgreSQL: no impone costo en los registros no primarios y garantiza unicidad sin lógica adicional de aplicación. Alternativa descartada: usar `expires_on = NULL` como indicador del documento activo — ambiguo y no enforced por el motor.

**Impacto**

Tabla modificada: `person_document`. Índice nuevo: `uq_person_document_primary`. Sin cambios en tablas dependientes.

---

### FIX-02 — Agregar `is_current` a `loyalty_account_tier` con índice parcial

**Estado:** Aceptado · **Dominio:** Customer & Loyalty · **Tipo:** Corrección lógica

**Contexto**

Para obtener el tier vigente de un cliente, el código original requería ejecutar `MAX(assigned_at)` sobre toda la historia de la cuenta. Además, la restricción `UNIQUE(loyalty_account_id, assigned_at)` era frágil ante dos asignaciones simultáneas (posible en migraciones masivas).

**Decisión**

Se añade `is_current boolean NOT NULL DEFAULT false`. Se crea un índice parcial `UNIQUE INDEX WHERE is_current = true` sobre `loyalty_account_id`. La aplicación debe actualizar `is_current` al transicionar niveles.

**Razonamiento**

Lookup en tiempo constante del tier activo con `SELECT WHERE is_current = true`. El historial completo se preserva para auditoría. Patrón similar al soft-delete con `is_deleted`.

**Impacto**

Tabla modificada: `loyalty_account_tier`. Índice nuevo: `uq_loyalty_account_tier_current`. La aplicación debe gestionar el flag al cambiar niveles.

---

### FIX-03 — Agregar `balance_after` a `miles_transaction`

**Estado:** Aceptado · **Dominio:** Customer & Loyalty · **Tipo:** Optimización de rendimiento

**Contexto**

El saldo de millas no se persistía en ningún lugar del esquema. Cada consulta requería `SUM(miles_delta)` sobre toda la historia de transacciones de la cuenta, que puede crecer ilimitadamente. Problema crítico en pantallas de self-service y en el proceso de checkout.

**Decisión**

Se añade `balance_after integer NOT NULL` a `miles_transaction`. Almacena el saldo acumulado inmediatamente después de aplicar la transacción. La aplicación calcula `balance_after = balance_anterior + miles_delta` en cada `INSERT`.

**Razonamiento**

Patrón ledger con running balance. Permite obtener el saldo actual con `SELECT balance_after ... ORDER BY occurred_at DESC LIMIT 1`. Alternativas descartadas: materializar saldo en `loyalty_account` (hotspot en alta transaccionalidad); vista materializada (sigue requiriendo `SUM()` y tiene lag de refresh).

**Impacto**

Tabla modificada: `miles_transaction`. Índice nuevo: `idx_miles_transaction_occurred_at`.

---

### FIX-04 — Agregar `departure_gate_id` y `arrival_gate_id` a `flight_segment`

**Estado:** Aceptado · **Dominio:** Operaciones de Vuelo · **Tipo:** Corrección de diseño

**Contexto**

El esquema no tenía vínculo directo entre un segmento de vuelo y la puerta de embarque. Era imposible consultar "qué puerta usa el vuelo XX" sin cruzar `check_in → boarding_pass → boarding_validation`, lo que requería datos de pasajeros ya embarcados. Las operaciones de tierra necesitan esta información desde la planificación.

**Decisión**

Se añaden `departure_gate_id` y `arrival_gate_id` como columnas nullable en `flight_segment`, referenciando `boarding_gate(boarding_gate_id)`.

**Razonamiento**

Nullable porque la asignación de puerta ocurre operacionalmente después de crear el segmento. Normalizado en `flight_segment` en lugar de tabla separada, dado que la asignación es 1-a-1.

**Impacto**

Tabla modificada: `flight_segment`. Índices nuevos: `idx_flight_segment_departure_gate_id`, `idx_flight_segment_arrival_gate_id`.

---

### FIX-05 — Nueva tabla `invoice_payment` para reconciliación pago-factura

**Estado:** Aceptado · **Dominio:** Facturación / Pagos · **Tipo:** Tabla nueva

**Contexto**

`payment` e `invoice` colgaban ambos de `sale_id` pero no tenían relación directa entre sí. Era imposible responder: ¿qué pago cubrió qué factura? ¿La factura X fue pagada parcialmente? Esto impedía contabilidad correcta, reportes de cuentas por cobrar y conciliación bancaria.

**Decisión**

Se crea `invoice_payment` como tabla puente M:N entre `invoice` y `payment`, con `allocated_amount numeric(12,2) NOT NULL` que representa el monto del pago asignado a esa factura específica.

**Razonamiento**

La relación M:N es necesaria: un pago puede cubrir múltiples facturas (anticipo), y una factura puede ser cubierta por múltiples pagos (cuotas). `allocated_amount` es un atributo de la relación, no un derivado de ninguna entidad individual — mantiene 3FN.

**Impacto**

Tabla nueva: `invoice_payment`. Índices nuevos: `idx_invoice_payment_invoice_id`, `idx_invoice_payment_payment_id`.

---

### FIX-06 — Índices faltantes críticos para consultas de negocio

**Estado:** Aceptado · **Dominio:** Transversal · **Tipo:** Optimización de rendimiento

**Contexto**

El esquema omitió índices en columnas frecuentemente usadas en filtros de negocio, lo que generaría full scans en tablas de alto volumen.

**Decisión**

Se añaden 7 índices nuevos:

| Índice | Tabla (columna) | Propósito |
|---|---|---|
| `idx_customer_airline_id` | `customer(airline_id)` | Segmentación de clientes por aerolínea |
| `idx_loyalty_tier_program_id` | `loyalty_tier(loyalty_program_id)` | Navegación de tiers |
| `idx_miles_transaction_occurred_at` | `miles_transaction(occurred_at)` | Consultas por rango de fecha |
| `idx_flight_airline_id` | `flight(airline_id)` | Listado de vuelos de una aerolínea |
| `idx_fare_route` | `fare(origin_airport_id, destination_airport_id)` | Búsqueda de tarifas por ruta |
| `idx_fare_validity` | `fare(valid_from, valid_to)` | Filtro de tarifas vigentes |
| `idx_ticket_fare_id` | `ticket(fare_id)` | Auditoría de tickets por tarifa |

**Impacto**

Sin cambios de esquema. Solo índices nuevos. Sin impacto en aplicaciones existentes.

---

## Gaps Identificados (Sin Corrección en Script)

### NOTA-01 — Solapamiento de vigencia en `fare`

Dos filas en `fare` pueden tener la misma combinación `(airline_id, origin, destination, fare_class)` con períodos `valid_from/valid_to` solapados. No puede prevenirse con `CHECK` simple.

**Recomendación:** Implementar `EXCLUDE USING gist` con extensión `btree_gist` en producción. Mientras tanto, validar en la capa de aplicación al crear o modificar fares.

---

### NOTA-02 — Sin clave natural compuesta en `person`

La tabla `person` no tiene un unique constraint natural que prevenga registros duplicados de la misma persona física.

**Recomendación:** La deduplicación debe gestionarse en la aplicación mediante matching por `document_number` (que sí tiene `UNIQUE` por tipo+país). No se añade constraint compuesto para evitar falsos positivos con homónimos.

---

## Principios de Diseño Aplicados

| Principio | Aplicación en este esquema |
|---|---|
| **3FN** | No se persisten derivados. `balance_after` es un snapshot confirmado de negocio, no un cálculo derivado. |
| **UUID como PK** | Todas las tablas usan `gen_random_uuid()`. Sin coordinación de secuencias, IDs no predecibles. |
| **Índices parciales** | Usados en FIX-01 y FIX-02 para constraints condicionales. Más eficientes que índices totales. |
| **CHECK constraints en BD** | Estados y valores enumerados validados en la base de datos, independiente de la aplicación. |
| **Catálogos normalizados** | Los tipos de estado, clase, canal, etc. son entidades propias, permitiendo extensión sin DDL. |
| **Auditoría automática** | Todas las tablas tienen `created_at` y `updated_at` con `DEFAULT now()`. |
| **Nullable vs NOT NULL** | FKs opcionales son nullable. FKs de negocio obligatorias son NOT NULL. Consistente en todo el esquema. |
