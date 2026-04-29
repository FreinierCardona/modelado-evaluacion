# ADR-003: Adoptar Liquibase para versionamiento de DDL

**Contexto**
- Actualmente el esquema está definido por SQL manual en `modelo_postgresql.sql`.
- No existe control de cambios centralizado ni historial de migraciones aplicadas en los entornos.

**Problema**
- Cambios DDL manuales generan riesgo de divergencia entre entornos (dev/qa/prod), dificultad de rollback y falta de trazabilidad por cambio aplicado.

**Decisión**
- Adoptar Liquibase (changelogs en YAML) como fuente de verdad para todos los cambios DDL. Mantener un changelog maestro (`db/changelog-master.yaml`) y changeSets aislados por Historias de Usuario.

**Justificación técnica**
- Liquibase añade: control de versión de DDL, metadata de ejecuciones (`DATABASECHANGELOG`), soporte de rollback, preconditions y contexts (dev/qa/prod).
- Se integra fácilmente en pipelines CI/CD y permite generar baseline a partir del esquema actual.

**Consecuencias o impacto esperado**
- +Trazabilidad y reproducibilidad entre entornos.
- Trabajo inicial para transformar `modelo_postgresql.sql` en un `baseline` y educar al equipo para crear changeSets por HU.
---
