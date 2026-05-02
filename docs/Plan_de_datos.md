# Plan_de_datos

Resumen breve
- Objetivo: poblar datos de prueba coherentes con la integridad referencial del modelo.
- Alcance: 12 schemas (dominios), inserts mínimos 10 registros por tabla.

Orden de ejecución (inserción)
1. sch_geography — catálogos base (time_zone, continent, currency, country, state_province, city, district, address).
2. sch_airline — `airline` (referencia a `country`).
3. sch_identity — `person_type`, `document_type`, `contact_type`, `person`, `person_document`, `person_contact` (usa países).
4. sch_security — catálogos y `user_account` (referencia `person`).
5. sch_customer_and_loyalty — catálogos y objetos de lealtad (usa `airline`, `currency`, `person`).
6. sch_airport — `airport`, `terminal`, `boarding_gate`, `runway`, `airport_regulation` (usa `address`).
7. sch_aircraft — fabricantes, modelos, `cabin_class`, `aircraft`, `aircraft_cabin`, `aircraft_seat`, mantenimiento (usa `airline`).
8. sch_flight_operations — `flight_status`, `delay_reason_type`, `flight`, `flight_segment`, `flight_delay` (usa `aircraft` y `airport`).
9. sch_sales_reservation_and_ticketing — catálogos, `fare_class`, `fare`, `reservation`, `reservation_passenger`, `sale`, `ticket`, `ticket_segment`, `seat_assignment`, `baggage` (usa `customer`, `fare`, `flight_segment`).
10. sch_boarding — `boarding_group`, `check_in_status`, `check_in`, `boarding_pass`, `boarding_validation` (usa `ticket_segment`, `user_account`, `boarding_gate`).
11. sch_payment — `payment_status`, `payment_method`, `payment`, `payment_transaction`, `refund` (usa `sale`).
12. sch_billing — `tax`, `exchange_rate`, `invoice_status`, `invoice`, `invoice_line` (usa `sale`, `currency`).

Por qué este orden
- Las tablas en `sch_geography` son pivotes referenciados por casi todos los dominios (países, monedas, direcciones). Deben poblarse primero.
- Después se crean entidades pivote de negocio (`airline`, `person`, `airport`, `aircraft`) que otras tablas referencian.
- Las tablas transaccionales (vuelos, reservas, ventas, pagos, facturación) se crean una vez disponibles los pivotes.

Cómo ejecutar
- Ejecutar cada script de inserción en el orden numérico: desde `02_dml/00_inserts/000_inserts_sch_geography.sql` hasta `02_dml/00_inserts/011_inserts_sch_billing.sql`.
- Para revertir, ejecutar los rollbacks en orden inverso (011 → 000) ubicados en `05_rollbacks/02_dml/00_inserts/`.
- Recomendación: correr en una transacción por archivo (los scripts ya usan `BEGIN; ... COMMIT;`).

Pautas de dependencias (resumen técnico)
- Referencias estables usadas para joins entre scripts:
  - países: `sch_geography.country.iso_alpha2` (US, GB, FR, DE, ES, BR, CN, JP, AR, MX)
  - monedas: `sch_geography.currency.iso_currency_code` (USD, EUR, GBP, BRL, CNY, JPY, ARS, MXN, CAD, AUD)
  - aerolíneas: `sch_airline.airline.airline_code` (AL001..AL010)
  - personas: relación por `sch_identity.person_document.document_number` (DOC-001..DOC-010) y `sch_identity.person.first_name` (`TestFirst1`..)
  - reservas/ventas: códigos `reservation_code`, `sale_code`, `ticket_number` generados en los scripts (prefijo R/S/T)

Registro de cambios / seguimiento técnico
- Se crearon los siguientes scripts de inserción (02_dml/00_inserts):
  - 000_inserts_sch_geography.sql
  - 001_inserts_sch_airline.sql
  - 002_inserts_sch_identity.sql
  - 003_inserts_sch_security.sql
  - 004_inserts_sch_customer_and_loyalty.sql
  - 005_inserts_sch_airport.sql
  - 006_inserts_sch_aircraft.sql
  - 007_inserts_sch_flight_operations.sql
  - 008_inserts_sch_sales_reservation_and_ticketing.sql
  - 009_inserts_sch_boarding.sql
  - 010_inserts_sch_payment.sql
  - 011_inserts_sch_billing.sql

- Se crearon los rollbacks correspondientes (05_rollbacks/02_dml/00_inserts):
  - 000_inserts_sch_geography.rollback.sql ... 011_inserts_sch_billing.rollback.sql

- Nota técnica: los scripts usan `ON CONFLICT DO NOTHING` en inserts de catálogos y `SELECT ... LIMIT 1 OFFSET` para obtener ids parent de forma determinista. Esto facilita reruns sin duplicar datos en catálogos.

Pruebas y verificación rápida
- Para verificar: después de ejecutar cada archivo, ejecutar consultas de conteo simples. Ejemplo:
  - SELECT count(*) FROM sch_geography.country;
  - SELECT count(*) FROM sch_sales_reservation_and_ticketing.ticket;

Comentarios finales
- No se modificó la lógica DDL. Los scripts solo insertan datos de prueba respetando FKs y constraints.
- Si quiere que ejecute las inserciones ahora (o que ejecute los rollbacks de prueba en un entorno), indique el entorno/credenciales y lo ejecuto.---
# Plan_de_datos — Plan básico de pobrado de datos de prueba
---

Objetivo: poblar datos de prueba coherentes con las dependencias del modelo, sin alterar la lógica del DDL ni las políticas DCL/RLS.

**Resumen corto**: Los scripts en `02_dml/00_inserts/` insertan 10 registros por tabla (mínimo) usando valores deterministas y selects para respetar FKs entre esquemas. Para revertir, hay rollbacks espejo en `05_rollbacks/02_dml/00_inserts/`.

**Orden de inserción (dependencias)**
- **000**: sch_geography — tablas de referencia (time_zone, continent, currency, country, state, city, district, address). Script: [02_dml/00_inserts/000_inserts_sch_geography.sql](02_dml/00_inserts/000_inserts_sch_geography.sql)
- **001**: sch_airline — depende de `sch_geography.country`. Script: [02_dml/00_inserts/001_inserts_sch_airline.sql](02_dml/00_inserts/001_inserts_sch_airline.sql)
- **002**: sch_identity — catálogos y `person` (usa países). Script: [02_dml/00_inserts/002_inserts_sch_identity.sql](02_dml/00_inserts/002_inserts_sch_identity.sql)
- **003**: sch_security — cuentas y roles (usa `person`). Script: [02_dml/00_inserts/003_inserts_sch_security.sql](02_dml/00_inserts/003_inserts_sch_security.sql)
- **004**: sch_customer_and_loyalty — programas y clientes (usa `airline`, `currency`, `person`). Script: [02_dml/00_inserts/004_inserts_sch_customer_and_loyalty.sql](02_dml/00_inserts/004_inserts_sch_customer_and_loyalty.sql)
- **005**: sch_airport — aeropuertos y dependencias (usa `address` de geography). Script: [02_dml/00_inserts/005_inserts_sch_airport.sql](02_dml/00_inserts/005_inserts_sch_airport.sql)
- **006**: sch_aircraft — fabricantes, modelos y aeronaves (usa `airline`). Script: [02_dml/00_inserts/006_inserts_sch_aircraft.sql](02_dml/00_inserts/006_inserts_sch_aircraft.sql)
- **007**: sch_flight_operations — vuelos y segmentos (usa `airline`, `aircraft`, `airport`). Script: [02_dml/00_inserts/007_inserts_sch_flight_operations.sql](02_dml/00_inserts/007_inserts_sch_flight_operations.sql)
- **008**: sch_sales_reservation_and_ticketing — reservas, ventas, tickets (usa `customer`, `fare`, `flight_segment`). Script: [02_dml/00_inserts/008_inserts_sch_sales_reservation_and_ticketing.sql](02_dml/00_inserts/008_inserts_sch_sales_reservation_and_ticketing.sql)
- **009**: sch_boarding — check-ins y pases (usa `ticket_segment`, `user_account`, `boarding_gate`). Script: [02_dml/00_inserts/009_inserts_sch_boarding.sql](02_dml/00_inserts/009_inserts_sch_boarding.sql)
- **010**: sch_payment — pagos (usa `sale`, `currency`). Script: [02_dml/00_inserts/010_inserts_sch_payment.sql](02_dml/00_inserts/010_inserts_sch_payment.sql)
- **011**: sch_billing — facturación (usa `sale`, `currency`). Script: [02_dml/00_inserts/011_inserts_sch_billing.sql](02_dml/00_inserts/011_inserts_sch_billing.sql)

Recomendación de ejecución: ejecutar los scripts en el orden numérico indicado (000 → 011). Cada script es autocontenido y usa selects determinísticos para unir claves entre esquemas.

**Orden de rollback** (ejecutar en orden inverso para evitar violaciones FK): 011 → 010 → 009 → 008 → 007 → 006 → 005 → 004 → 003 → 002 → 001 → 000. Los scripts de rollback se guardaron en `05_rollbacks/02_dml/00_inserts/`.

**Comandos de ejemplo** (ejecutar desde un entorno con conexión psql):

```bash
# insertar todo (ejecutar en orden)
psql -h <host> -U <user> -d <db> -f 02_dml/00_inserts/000_inserts_sch_geography.sql
psql -h <host> -U <user> -d <db> -f 02_dml/00_inserts/001_inserts_sch_airline.sql
# ... seguir hasta 011

# rollback completo (en orden inverso)
psql -h <host> -U <user> -d <db> -f 05_rollbacks/02_dml/00_inserts/011_inserts_sch_billing.rollback.sql
# ... seguir hasta 000
```

**Notas importantes y consideraciones**
- Los scripts asumen que las extensiones DDL (p.ej. `pgcrypto`) y las tablas definidas en `01_ddl` ya existen.
- Algunos deletes en los rollbacks usan patrones (`LIKE`, valores de nombre) para identificar filas insertadas; ejecutar rollback en el orden inverso global minimiza el riesgo de violaciones por FK.
- RLS: las políticas definidas en `03_dcl/02_policies/` (p.ej. `customer` y `loyalty_account`) están habilitadas por DCL; los inserts fueron diseñados para ejecutarse con un rol con permisos suficientes (DB admin o durante despliegue automatizado). Para pruebas desde la aplicación asegúrese de setear `app.current_customer_id` cuando sea necesario.

**Registro técnico (acciones realizadas)**
- Leído: `01_ddl/03_tables/*` para mapear tablas y dependencias.
- Leído: `docs/*` y `03_dcl/*` para comprender RLS y grants.
- Creado: scripts de inserción (12):
  - [02_dml/00_inserts/000_inserts_sch_geography.sql](02_dml/00_inserts/000_inserts_sch_geography.sql)
  - [02_dml/00_inserts/001_inserts_sch_airline.sql](02_dml/00_inserts/001_inserts_sch_airline.sql)
  - [02_dml/00_inserts/002_inserts_sch_identity.sql](02_dml/00_inserts/002_inserts_sch_identity.sql)
  - [02_dml/00_inserts/003_inserts_sch_security.sql](02_dml/00_inserts/003_inserts_sch_security.sql)
  - [02_dml/00_inserts/004_inserts_sch_customer_and_loyalty.sql](02_dml/00_inserts/004_inserts_sch_customer_and_loyalty.sql)
  - [02_dml/00_inserts/005_inserts_sch_airport.sql](02_dml/00_inserts/005_inserts_sch_airport.sql)
  - [02_dml/00_inserts/006_inserts_sch_aircraft.sql](02_dml/00_inserts/006_inserts_sch_aircraft.sql)
  - [02_dml/00_inserts/007_inserts_sch_flight_operations.sql](02_dml/00_inserts/007_inserts_sch_flight_operations.sql)
  - [02_dml/00_inserts/008_inserts_sch_sales_reservation_and_ticketing.sql](02_dml/00_inserts/008_inserts_sch_sales_reservation_and_ticketing.sql)
  - [02_dml/00_inserts/009_inserts_sch_boarding.sql](02_dml/00_inserts/009_inserts_sch_boarding.sql)
  - [02_dml/00_inserts/010_inserts_sch_payment.sql](02_dml/00_inserts/010_inserts_sch_payment.sql)
  - [02_dml/00_inserts/011_inserts_sch_billing.sql](02_dml/00_inserts/011_inserts_sch_billing.sql)
- Creado: rollbacks espejo (12): carpeta [05_rollbacks/02_dml/00_inserts/](05_rollbacks/02_dml/00_inserts/)

