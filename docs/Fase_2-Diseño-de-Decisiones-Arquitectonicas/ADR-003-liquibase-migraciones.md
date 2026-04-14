# ADR-003 — Gestión de Cambios con Liquibase

| Campo | Detalle |
|---|---|
| **Estado** | Aceptado |
| **Fecha** | Abril 2026 |
| **Dominio** | Infraestructura / DevOps |
| **Tablas afectadas** | Todas (gestión del script completo) |

---

## Contexto

El script SQL de este proyecto tiene más de 600 líneas, 67 tablas, índices y correcciones numeradas (FIX-01 al FIX-06). A medida que el proyecto avance, van a aparecer nuevos cambios: agregar columnas, corregir constraints, crear índices nuevos.

Si esos cambios se aplican a mano, ejecutando scripts SQL directamente en la base de datos, tarde o temprano algo va a salir mal.

---

## Problema

Gestionar cambios manuales de base de datos genera estos problemas:

- **No hay historial:** no se sabe con certeza qué cambios tiene cada ambiente (desarrollo, qa, producción).
- **Sin rollback fácil:** si una migración falla a mitad de camino, deshacer los cambios es complicado y riesgoso.
- **Ambientes desincronizados:** el ambiente de desarrollo puede tener columnas que producción todavía no tiene, o viceversa.
- **Trabajo duplicado:** cada developer aplica los cambios por separado, a veces en diferente orden.

---

## Decisión

Se usa **Liquibase** para gestionar todos los cambios de base de datos. Cada modificación al esquema se define como un **changeset** con un ID único, un autor y las instrucciones SQL.

**Estructura básica de un changeset:**

```xml
<changeSet id="FIX-01-add-is-primary-to-person-document" author="dev-equipo">
    <addColumn tableName="person_document">
        <column name="is_primary" type="boolean" defaultValueBoolean="false">
            <constraints nullable="false"/>
        </column>
    </addColumn>
    <rollback>
        <dropColumn tableName="person_document" columnName="is_primary"/>
    </rollback>
</changeSet>
```

Liquibase guarda un registro de qué changesets ya se ejecutaron en una tabla especial llamada `DATABASECHANGELOG`. Si un changeset ya se aplicó, Liquibase lo salta automáticamente.

---

## Justificación técnica

- **Control de versiones real:** cada changeset tiene un ID único. El historial de cambios queda guardado en la base de datos, no solo en la memoria del equipo.

- **Rollback incorporado:** si se agrega una columna y algo falla, el bloque `<rollback>` deshace el cambio automáticamente. Con scripts manuales, hay que escribir ese reverso a mano y esperar que no se olvide.

- **Misma migración en todos los ambientes:** el mismo archivo de Liquibase se ejecuta en desarrollo, QA y producción. Si funciona en dev, funciona en prod porque los pasos son idénticos.

- **Integración con Git:** los archivos de Liquibase se guardan en el repositorio. Cualquier persona del equipo puede ver exactamente qué cambios se hicieron, cuándo y por quién.

- **Funciona con PostgreSQL:** Liquibase es compatible directo con PostgreSQL 15, el motor que usa este proyecto.

---

## Cómo aplicar este proyecto

El script actual (`v1.1`) se convierte en el primer changeset del proyecto:

```
changelog/
├── db.changelog-master.xml       ← archivo raíz
└── migrations/
    ├── 001-schema-inicial.sql    ← las 67 tablas base
    ├── 002-fix01-is-primary.sql  ← FIX-01
    ├── 003-fix02-is-current.sql  ← FIX-02
    └── ...
```

---

## Consecuencias e impacto esperado

✅ Cualquier miembro del equipo puede saber exactamente qué versión de la base de datos tiene cada ambiente con un solo comando: `liquibase status`.

✅ Si una migración rompe algo en QA, se hace rollback en minutos sin intervención manual compleja.

✅ Los cambios de base de datos siguen el mismo flujo de revisión que el código (Pull Request → revisión → merge).

⚠️ El equipo necesita acostumbrarse a no hacer cambios directos en la base de datos. Todo cambio debe pasar por un changeset.

⚠️ Requiere instalar Liquibase en el entorno de CI/CD. Es un paso de configuración inicial que toma tiempo pero paga la inversión desde el primer sprint.
