# ADR-005: Implementación de Soft Delete (borrado lógico)

**Contexto**
- El esquema actual presenta múltiples tablas con restricciones de unicidad (p. ej. `country.iso_alpha2`, `user_account.username`, `reservation.reservation_code`) pero no hay un campo de borrado lógico (`deleted_at`).
- Requisitos de negocio: conservar historial, permitir reversión administrativa y evitar pérdida de información para auditoría.

**Problema**
- Borrados físicos rompen historial, complican auditoría y afectan integridad referencial si se necesitan restauraciones o conciliaciones.
- Necesitamos una estrategia coherente y mínima para implementar soft delete sin romper constraints únicas.

**Decisión**
- Adoptar `deleted_at timestamptz NULL` en entidades base (ejemplos: `person`, `user_account`, `customer`, `reservation`, `ticket`, `sale`, `invoice`, `country`, `currency`).
- Reemplazar (o complementar temporalmente) las restricciones `UNIQUE` que deben aplicar sólo a filas activas por índices únicos parciales `WHERE deleted_at IS NULL`.

**Justificación técnica**
- `deleted_at` permite distinguir estados (activo vs eliminado) y facilita `undelete` simple.
- PostgreSQL soporta índices únicos parciales, que permiten mantener unicidad sólo para filas no eliminadas.
- Minimiza necesidad de borrados físicos inmediatos; permite política de purga diferida.

**Cambios DDL ejemplares (pasos y ejemplos)**

1. Agregar columna `deleted_at` (no disruptivo):

```sql
ALTER TABLE reservation ADD COLUMN deleted_at timestamptz;
ALTER TABLE user_account ADD COLUMN deleted_at timestamptz;
```

2. Crear índices únicos parciales para aplicar unicidad sólo a filas activas (ejemplo `country` y `user_account`):

```sql
-- Para country.iso_alpha2
CREATE UNIQUE INDEX uq_country_iso_alpha2_active ON country (iso_alpha2) WHERE deleted_at IS NULL;
-- Para user_account.username
CREATE UNIQUE INDEX uq_user_account_username_active ON user_account (username) WHERE deleted_at IS NULL;
```

3. Validar integridad y luego eliminar la constraint única anterior (si existe) en ventana de mantenimiento: `ALTER TABLE DROP CONSTRAINT ...`.

4. Ajustes en aplicación/queries: añadir `WHERE deleted_at IS NULL` en endpoints y vistas que requieran sólo datos activos. Crear vistas `*_active` si se prefiere.

5. Política de purga: job programado que elimine físicamente filas con `deleted_at < now() - interval 'X months'` y registre acciones.

**Tabla de tablas recomendadas para soft delete (ejemplos)**

| Tabla | Motivo |
|---|---|
| `user_account` | Evitar reuso inmediato de `username`, conservar historial de accesos |
| `person`, `customer` | Auditoría y restauración de relaciones |
| `reservation`, `ticket`, `sale` | Mantener historial comercial, evitar inconsistencia contable |
| `invoice`, `payment`, `refund` | Conservación contable; recomendamos sólo soft-delete y purga bajo supervisión |

**Consecuencias o impacto esperado**
- Debe modificarse lógica de unicidad: se requieren índices únicos parciales o migraciones cuidadosas.
- Consultas sin filtro por `deleted_at` podrían mostrar datos eliminados—necesaria disciplina y tests.
- Herramienta de purga y procesos de auditoría deben definirse para evitar crecimiento indefinido de la BD.

**Notas de migración y riesgos**
- Crear índices parciales **antes** de eliminar restricciones antiguas para evitar conflictos.
- Validar duplicados históricos antes de crear índices parciales (pueden existir duplicados con `deleted_at IS NOT NULL`).
- Probar en staging la política de cascada (si se requiere soft-delete en cascada, implementar triggers o jobs en vez de FK cascading físico).

---
*Archivo: docs/adr/ADR-005-Soft-Delete-Strategy.md*