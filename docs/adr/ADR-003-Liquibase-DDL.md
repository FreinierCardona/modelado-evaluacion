# ADR-003: Adoptar Liquibase para versionamiento de DDL

**Contexto**
- Actualmente el esquema está definido por SQL manual en `modelo_postgresql.sql`.
- No existe control de cambios centralizado ni historial de migraciones aplicadas en los entornos.

**Problema**
- Cambios DDL manuales generan riesgo de divergencia entre entornos (dev/qa/prod), dificultad de rollback y falta de trazabilidad por cambio aplicado.

**Decisión**
- Adoptar Liquibase (changelogs en XML/YAML/SQL) como fuente de verdad para todos los cambios DDL. Mantener un changelog maestro (`db/changelog-master.xml`) y changeSets aislados por HU/feature.

**Justificación técnica**
- Liquibase añade: control de versión de DDL, metadata de ejecuciones (`DATABASECHANGELOG`), soporte de rollback, preconditions y contexts (dev/qa/prod).
- Se integra fácilmente en pipelines CI/CD y permite generar baseline a partir del esquema actual.

**Pasos recomendados (resumen)**
1. Generar baseline inicial:
   - Usar `pg_dump --schema-only` para referencia y generar un `initial` changelog manual o usar `liquibase generateChangeLog` en DB de referencia.
2. Estructura de directorios:
   - `infra/db/changelogs/changelog-master.xml`
   - `infra/db/changelogs/features/HU-<NN>-<desc>.xml` (uno por historia)
3. Convenciones:
   - `changeSet id`: `HU-XX-YYYYMMDD-HHMMSS` y `author` = developer.
   - Usar `context` y `labels` para distinguir ejecuciones (dev/qa/prod).
4. Integración CI/CD:
   - En `develop`: CI aplica `liquibase update` contra DB ephemeral/dev.
   - En `qa`: al merge a `qa` aplicar migraciones en staging vía pipeline con datos de test.
   - En `main`: requerir PR y aprobación manual + copia de seguridad antes de `liquibase update` en prod.
5. Rollback/Preconditions:
   - Cada `changeSet` debe incluir `rollback` cuando sea posible y `preConditions` que validen supuestos (existencia tabla/columna).

**Ejemplo de changeSet (XML, simplificado)**

```xml
<changeSet id="HU-01-20260420-001" author="dev">
  <createTable tableName="claim">
    <column name="claim_id" type="uuid">
      <constraints primaryKey="true"/>
    </column>
    <column name="customer_id" type="uuid"/>
    <column name="reported_at" type="timestamptz" defaultValueComputed="NOW()"/>
  </createTable>
  <addForeignKeyConstraint baseTableName="claim" baseColumnNames="customer_id" referencedTableName="customer" referencedColumnNames="customer_id"/>
  <rollback>
    <dropTable tableName="claim"/>
  </rollback>
</changeSet>
```

**Consecuencias o impacto esperado**
- +Trazabilidad y reproducibilidad entre entornos.
- Trabajo inicial para transformar `modelo_postgresql.sql` en un `baseline` y educar al equipo para crear changeSets por HU.
- Requiere incluir `liquibase` en pipelines y gestionar credenciales/entornos.

**Herramientas y recomendaciones**
- Liquibase CLI/Gradle/Maven plugin. Usar contexts y tags. Añadir checklist PR para cambios DDL (impacto, rollback, preconditions, tiempo estimado de despliegue).

---
*Archivo: docs/adr/ADR-003-Liquibase-DDL.md*