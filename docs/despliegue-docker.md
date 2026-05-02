# Despliegue en Docker

## Qué hace el despliegue
- Levanta un contenedor de PostgreSQL.
- Ejecuta Liquibase dentro de otro contenedor.
- Aplica todas las migraciones del archivo `changelog-master.yaml`.

## Componentes Docker
- `postgres`: contenedor de base de datos PostgreSQL 16 (`postgres:16-alpine`).
- `liquibase`: contenedor de migración que instala el conector JDBC de PostgreSQL y ejecuta Liquibase.

## Cómo se conteneriza
1. PostgreSQL se define en `docker-compose.yml`.
2. Se expone el puerto local `5433` a `5432` del contenedor.
3. Se monta un volumen `postgres_data` para persistir datos.
4. Liquibase se define con `docker/liquibase/Dockerfile`.
5. El contenedor de Liquibase monta el proyecto completo en `/workspace`.

## Flujo de inicio
1. Levantar `postgres`.
2. Esperar a que `postgres` esté sano con `pg_isready`.
3. Iniciar `liquibase` cuando `postgres` esté listo.
4. Liquibase lee `changelog-master.yaml` y aplica los cambios.

## Comando principal
```bash
# Levanta el entorno y ejecuta migraciones
docker compose up --build
```

## Variables de entorno usadas
- `POSTGRES_DB`: nombre de la base de datos (por defecto `modelo_bd_evaluacion`).
- `POSTGRES_USER`: usuario de la base de datos (por defecto `freinercardona`).
- `POSTGRES_PASSWORD`: contraseña de la base de datos (por defecto `29052009`).
- `POSTGRES_PORT`: puerto local para PostgreSQL (por defecto `5433`).

## Qué ocurre en ejecución
- El contenedor `postgres` crea la base de datos y carga el motor.
- `liquibase` se conecta a `jdbc:postgresql://postgres:5432/${POSTGRES_DB}`.
- Se ejecuta el comando `update` de Liquibase.
- Si las migraciones son exitosas, el contenedor de Liquibase termina.

## Ventajas de este despliegue
- Reproduce el entorno sin instalar PostgreSQL localmente.
- Aísla el motor de base de datos y las migraciones.
- Permite ejecutar migraciones idénticas en diferentes equipos.
- Usa volúmenes para mantener los datos entre reinicios.
