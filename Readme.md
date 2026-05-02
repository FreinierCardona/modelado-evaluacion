# Modelo de Bases de Datos - Aerolinea

## Descripción general
Este proyecto es un modelo de base de datos para un sistema de aerolínea. Incluye esquema, datos de prueba, control de acceso y despliegue con Docker.

## Flujo del proyecto
1. Definir el esquema en `01_ddl/`.
2. Registrar el orden de ejecución en `changelog-master.yaml`.
3. Usar `02_dml/` para cargar datos de prueba.
4. Controlar permisos con `03_dcl/`.
5. Aplicar rollback con `05_rollbacks/` cuando sea necesario.
6. Ejecutar todo con Docker y Liquibase.

## Qué función tiene
- Modelar una base de datos relacional completa.
- Probar un flujo de reservas, vuelos, embarque, pagos y facturación.
- Organizar cambios de esquema con migraciones.
- Mantener la integridad referencial y seguridad de datos.

## Por qué se hizo
- Para practicar diseño de datos y modelado lógico.
- Para mostrar gestión de cambios con Liquibase.
- Para verificar la integración de bases de datos dentro de contenedores.
- Para crear un repositorio con estructura ordenada y trazable.

## Habilidades técnicas que refuerza
- Diseño de modelos de datos relacionales.
- Uso de PostgreSQL y extensiones (`pgcrypto`).
- Gestión de migraciones con Liquibase.
- Contenerización con Docker.
- Organización de scripts DDL, DML, DCL y rollbacks.

## Conocimientos que pone a prueba
- Identificación de dominios y dependencias.
- Integridad referencial y constraints.
- Separación de responsabilidades en el desarrollo de bases de datos.
- Despliegue reproducible en contenedores.

## Problema que soluciona
- Evita cambios desordenados en el esquema de la base de datos.
- Facilita el despliegue de un modelo de datos completo en entornos locales.
- Permite revertir y controlar migraciones de forma segura.

## Documentación adicional
- `docs/arquitectura.md`
- `docs/despliegue-docker.md`
- `docs/base-de-datos.md`
