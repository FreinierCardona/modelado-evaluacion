# ADR-005: Implementación de Soft Delete (borrado lógico)

**Análisis Lógico del ADR Original**
- El esquema actual tiene tablas con restricciones de unicidad (como `UNIQUE` en `country.iso_alpha2` o `user_account.username`). Estas impiden valores repetidos.
- Si borras físicamente (con `DELETE`), pierdes datos para siempre, complicando auditoría, reversión o integridad.
- Se necesita "borrar" sin perder datos, manteniendo lógica de BD intacta.
- El ADR propone agregar `deleted_at`, cambiar `UNIQUE` por índices parciales, ajustar queries y purga automática.
- Riesgos: Cambios en estructura pueden dañar BD si no se prueban; lógica se complica sin filtros.

**Contexto**
- El esquema actual tiene restricciones de unicidad pero no campo de borrado lógico (`deleted_at`).
- Requisitos: Conservar historial para auditoría y permitir reversión manual, sin perder información.

**Problema**
- Borrados físicos pierden datos, rompen historial y afectan integridad referencial.
- Necesitamos borrado lógico básico sin cambiar constraints únicas ni agregar procesos automáticos.

**Decisión**
- Adoptar `deleted_at timestamptz NULL` en entidades base (ejemplos: `person`, `user_account`, `customer`, `reservation`, `ticket`, `sale`, `invoice`, `country`, `currency`).
- Mantener restricciones `UNIQUE` intactas; en lógica de aplicación verificar conflictos manualmente con filas activas.
- Marcar filas como eliminadas con UPDATE en lugar de DELETE físico.
- Filtrar filas activas en queries con `WHERE deleted_at IS NULL`.

**Justificación técnica**
- `deleted_at` marca filas eliminadas sin borrarlas, conservando datos.
- No cambia constraints `UNIQUE`, evitando complejidad de índices parciales.
- Es simple: Solo agregar columna y ajustar queries manualmente.
- Minimiza riesgos: Cambios aditivos, no disruptivos.

**Cambios DDL ejemplares (pasos y ejemplos)**

1. Agregar columna `deleted_at` (no disruptivo):

```sql
ALTER TABLE user_account ADD COLUMN deleted_at timestamptz;
ALTER TABLE reservation ADD COLUMN deleted_at timestamptz;
```

2. Marcar como eliminado (en lugar de DELETE físico):

```sql
UPDATE user_account SET deleted_at = now() WHERE user_account_id = 'uuid-aqui';
```

3. Filtrar en consultas (siempre agregar para ver solo activos):

```sql
SELECT * FROM user_account WHERE deleted_at IS NULL;
```

4. Reversión manual (poner NULL para restaurar):

```sql
UPDATE user_account SET deleted_at = NULL WHERE user_account_id = 'uuid-aqui';
```

**Tabla de tablas recomendadas para soft delete (ejemplos)**

| Tabla | Motivo |
|---|---|
| `user_account` | Evitar perder historial de accesos; marcar eliminado en lugar de borrar. |
| `person`, `customer` | Conservar datos para auditoría; no perder relaciones. |
| `reservation`, `ticket`, `sale` | Mantener historial comercial; evitar inconsistencias. |
| `invoice`, `payment`, `refund` | Conservación contable; soft-delete simple. |

**Consecuencias o impacto esperado**
- La BD crece un poco (filas marcadas quedan), pero no se rompe.
- Consultas sin filtro mostrarían eliminados—disciplina básica: siempre filtra.
- No hay purga automática; hacer manualmente si es necesario.

**Notas de migración y riesgos**
- Agregar columna no rompe nada; probar en staging antes.
- Verificar manualmente conflictos de unicidad al crear nuevos registros.
- Riesgo bajo: Cambios simples, reversibles; no cambiar constraints evita errores.

---