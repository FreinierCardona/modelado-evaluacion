# Base de Datos

## Lógica del modelo
- Es un modelo relacional normalizado.
- Cada tabla tiene claves primarias y llaves foráneas para mantener integridad.
- Usa `uuid` con `gen_random_uuid()` en muchas tablas.
- Incluye `created_at` y `updated_at` en tablas principales.

## Dominios principales
- Geografía y catálogos: países, ciudades, monedas, direcciones.
- Aerolínea: información de aerolíneas.
- Personas y seguridad: datos de personas, cuentas de usuario, roles y permisos.
- Cliente y lealtad: programas de lealtad, cuentas y beneficios.
- Aeropuertos y flota: aeropuertos, terminales, puertas, aeronaves, modelos y mantenimiento.
- Operaciones de vuelo: vuelos, segmentos, retrasos y estados.
- Reservas y ventas: reservas, tickets, ventas y asignaciones de asientos.
- Embarque: check-in, pases de abordar y validaciones.
- Pagos y facturación: pagos, transacciones, reembolsos, facturas e impuestos.

## Dependencias entre dominios
- `airline` es referencia para vuelos, aeronaves, programas de lealtad y tarifas.
- `person` conecta identidad, seguridad y clientes.
- `reservation` conecta pasajeros, ventas y tickets.
- `sale` conecta tickets, pagos y facturación.
- `flight_segment` conecta segmentos de vuelo, retrasos y asientos.

## Funcionalidad del esquema
- El esquema soporta un proceso de viaje completo:
  1. registro de personas y clientes,
  2. gestión de aerolíneas y vuelos,
  3. reservas y tickets,
  4. embarque,
  5. pagos y facturación.
- Los datos de referencia permiten mantener consistencia en países, monedas y estados.
- Las políticas de seguridad y roles controlan el acceso a datos sensibles.

## Componentes clave
| Componente | Uso | Comentario |
|---|---|---|
| `pgcrypto` | Generación de UUID | Requerido para `gen_random_uuid()` |
| `changelog-master.yaml` | Orquesta migraciones Liquibase | Selecciona los cambios a aplicar |
| `01_ddl/` | Esquema y constraints | Define tablas y relaciones |
| `02_dml/` | Carga de datos | Inserta datos de prueba y catálogos |
| `03_dcl/` | Seguridad de datos | Roles, grants y políticas |
| `05_rollbacks/` | Deshacer cambios | Scripts de reversión ordenados |

## Observaciones prácticas
- El esquema es adecuado para pruebas y análisis de dominio.
- Está pensado para desplegarse con migraciones controladas.
- La separación de archivos facilita revisiones de cambios y auditoría.
- El modelo prioriza integridad y claridad de dependencias.
