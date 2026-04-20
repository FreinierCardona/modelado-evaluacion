# ADR-004: Estrategia Gitflow para integridad en despliegues de base de datos

**Contexto**
- Necesitamos reglas claras de branching y despliegue para evitar divergencias de esquema entre `develop`, `qa` y `main`.
- Se usará Liquibase (ADR-003) como motor de migraciones.

**Problema**
- Sin una convención de ramas y procesos de merge específicos para DB, los cambios DDL pueden entrar en entornos en orden incorrecto o sin validación.

**Decisión**
- Adoptar una variante de Gitflow con ramas principales: `develop`, `qa`, `main`.
- Para cada HU (historia), crear ramas hijas con sufijo de entorno: `HU-<NN>-dev`, `HU-<NN>-qa`, `HU-<NN>-main`.
- Convenciones y reglas de CI:
  - `HU-01-dev` → merge a `develop` (aplicar changeSets en dev DB por CI automático).
  - `HU-01-qa` → merge a `qa` (aplicar en staging con datos controlados, integración y pruebas).
  - `HU-01-main` → merge a `main` (despliegue a producción con aprobación y backup previo).

**Tabla resumen (ejemplo)**

| Rama HU | Propósito | Merge target | Acción CI/CD |
|---|---|---|---|
| `HU-01-dev` | Desarrollo y pruebas unitarias | `develop` | CI aplica migraciones en DB de desarrollo ephemeral |
| `HU-01-qa` | Pruebas de integración | `qa` | CI aplica migraciones en staging; correr tests integrados |
| `HU-01-main` | Preparar release | `main` | Pipeline exige aprobación manual, snapshot DB, aplicar migración en producción |

**Políticas y buenas prácticas**
- Cada feature que modifica DDL debe incluir su `changeSet` en `infra/db/changelogs/features/HU-<NN>-<desc>.xml`.
- PR template para cambios DDL: incluir `liquibase changelog path`, `rollback plan`, `impact assessment`, `runtime estimate`.
- Revisiones obligatorias por DBA/arquitecto para merges a `qa` y `main`.
- Tagging de releases: `v<MAJOR>.<MINOR>.<PATCH>` en `main` y tag Liquibase: `liquibase tag` antes del `update` en prod.

**Consecuencias o impacto esperado**
- +Control y predictibilidad en despliegues DB.
- +Overhead en creación de ramas y revisiones; requisito cultural para que desarrolladores creen changeSets por HU.
- Riesgo mitigado de migraciones desordenadas: todo cambio DDL pasa por pipelines y entornos en orden.

---
*Archivo: docs/adr/ADR-004-Gitflow-DB-Branching.md*