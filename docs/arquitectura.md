# Arquitectura del proyecto

## Tipo de arquitectura
- Proyecto de modelado de base de datos relacional.
- Se utiliza arquitectura de datos centrada en control de cambios y versionado.
- Liquibase es la herramienta de migración de esquema.
- Docker se usa para levantar el entorno con PostgreSQL y ejecutar migraciones.

## Por qué esta arquitectura
- Permite aplicar cambios de esquema de forma ordenada.
- Separa definiciones de datos (DDL), datos de prueba (DML), control de acceso (DCL) y transacciones (TCL).
- Facilita rollback y prueba de cambios en entornos aislados.
- Mejora la trazabilidad de cada cambio y el trabajo en equipo.

## Estructura de carpetas
| Carpeta | Contenido | Función | Ventaja |
|---|---|---|---|
| `01_ddl/` | Scripts de definición de tablas, esquemas, extensiones, tipos y constraints | Cambios de estructura del modelo | Mantiene el esquema organizado por tema |
| `02_dml/` | Scripts de inserción, actualización, borrado y upsert | Datos de prueba y carga inicial | Separa datos del esquema |
| `03_dcl/` | Scripts de roles, grants y políticas | Control de acceso y seguridad | Centraliza permisos y políticas de datos |
| `04_tcl/` | Scripts de transacciones y recuperación | Control de transacciones | Sirve para pruebas de consistencia |
| `05_rollbacks/` | Scripts de reversión para DDL, DML, DCL y TCL | Revertir cambios | Permite deshacer deploys con orden |
| `docker/` | Dockerfile de Liquibase | Contenerización de migraciones | Asegura ejecución repetible |
| `docs/` | Documentos técnicos | Guías y análisis | Agrupa documentación del proyecto |
| `scripts/` | PowerShell para rollback y reaplicación | Automatización local | Facilita tareas manuales |

## Ventajas principales
- Control de versiones de la base de datos.
- Migraciones ordenadas y reproducibles.
- Separación clara entre estructura y datos.
- Integración con Docker para entornos locales.
- Escalabilidad para añadir nuevos cambios sin desorden.

## Cómo funciona el proceso
1. Definir cambios en `01_ddl/`.
2. Registrar scripts en `changelog-master.yaml`.
3. Levantar PostgreSQL con Docker.
4. Ejecutar Liquibase para aplicar migraciones.
5. Insertar datos de prueba desde `02_dml/` si es necesario.
6. Usar `05_rollbacks/` para revertir cambios cuando sea necesario.
