---
# Análisis de Dominio — Modelo de Datos PostgreSQL

> **Autor:** Freinier Steven Cardona Perez
> **Fecha:** Abril 2026
> **Fuente:** modelo_postgresql.sql

---

## Dominio y tablas (agrupadas según secciones del DDL)

- Geografía y datos de referencia:
  - `time_zone`, `continent`, `country`, `state_province`, `city`, `district`, `address`, `currency`

- Aerolínea:
  - `airline`

- Identidad y personas:
  - `person_type`, `document_type`, `contact_type`, `person`, `person_document`, `person_contact`

- Seguridad / RBAC:
  - `user_status`, `security_role`, `security_permission`, `user_account`, `user_role`, `role_permission`

- Cliente y lealtad:
  - `customer_category`, `benefit_type`, `loyalty_program`, `loyalty_tier`, `customer`, `loyalty_account`, `loyalty_account_tier`, `miles_transaction`, `customer_benefit`

- Aeropuertos e infraestructura:
  - `airport`, `terminal`, `boarding_gate`, `runway`, `airport_regulation`

- Aeronaves y mantenimiento:
  - `aircraft_manufacturer`, `aircraft_model`, `cabin_class`, `aircraft`, `aircraft_cabin`, `aircraft_seat`, `maintenance_provider`, `maintenance_type`, `maintenance_event`

- Operaciones de vuelo:
  - `flight_status`, `delay_reason_type`, `flight`, `flight_segment`, `flight_delay`

- Ventas, reservas y boletería:
  - `reservation_status`, `sale_channel`, `fare_class`, `fare`, `ticket_status`, `reservation`, `reservation_passenger`, `sale`, `ticket`, `ticket_segment`, `seat_assignment`, `baggage`

- Embarque:
  - `boarding_group`, `check_in_status`, `check_in`, `boarding_pass`, `boarding_validation`

- Pagos:
  - `payment_status`, `payment_method`, `payment`, `payment_transaction`, `refund`

- Facturación:
  - `tax`, `exchange_rate`, `invoice_status`, `invoice`, `invoice_line`

### Listado completo de tablas (orden DDL):

1. time_zone
2. continent
3. country
4. state_province
5. city
6. district
7. address
8. currency
9. airline
10. person_type
11. document_type
12. contact_type
13. person
14. person_document
15. person_contact
16. user_status
17. security_role
18. security_permission
19. user_account
20. user_role
21. role_permission
22. customer_category
23. benefit_type
24. loyalty_program
25. loyalty_tier
26. customer
27. loyalty_account
28. loyalty_account_tier
29. miles_transaction
30. customer_benefit
31. airport
32. terminal
33. boarding_gate
34. runway
35. airport_regulation
36. aircraft_manufacturer
37. aircraft_model
38. cabin_class
39. aircraft
40. aircraft_cabin
41. aircraft_seat
42. maintenance_provider
43. maintenance_type
44. maintenance_event
45. flight_status
46. delay_reason_type
47. flight
48. flight_segment
49. flight_delay
50. reservation_status
51. sale_channel
52. fare_class
53. fare
54. ticket_status
55. reservation
56. reservation_passenger
57. sale
58. ticket
59. ticket_segment
60. seat_assignment
61. baggage
62. boarding_group
63. check_in_status
64. check_in
65. boarding_pass
66. boarding_validation
67. payment_status
68. payment_method
69. payment
70. payment_transaction
71. refund
72. tax
73. exchange_rate
74. invoice_status
75. invoice
76. invoice_line

### Entidades pivote y referencias directas
- `airline` — es referenciada explícitamente por: `loyalty_program(airline_id)`, `customer(airline_id)`, `aircraft(airline_id)`, `flight(airline_id)`, `fare(airline_id)`.
- `person` — es referenciada por: `person_document(person_id)`, `person_contact(person_id)`, `user_account(person_id)`, `reservation_passenger(person_id)`, `customer(person_id)`.
- `reservation` — es referenciada por: `reservation_passenger(reservation_id)`, `sale(reservation_id)`.
- `sale` — es referenciada por: `ticket(sale_id)`, `payment(sale_id)`, `invoice(sale_id)`.
- `ticket` / `ticket_segment` — `ticket_segment` referencia `ticket(ticket_id)` y `flight_segment(flight_segment_id)`; `seat_assignment` usa una clave compuesta que enlaza `ticket_segment` con `flight_segment`.
- `flight_segment` — es referenciada por: `ticket_segment(flight_segment_id)`, `flight_delay(flight_segment_id)`, `seat_assignment(flight_segment_id)`.
- `loyalty_account` — es referenciada por: `miles_transaction(loyalty_account_id)`, `loyalty_account_tier(loyalty_account_id)`.
- `invoice` — es referenciada por: `invoice_line(invoice_id)`.

### Patrones y convenciones observables
- Claves primarias: la mayoría de tablas usan `uuid` con `DEFAULT gen_random_uuid()` (requiere `pgcrypto` en DDL).
- Auditoría mínima: muchas tablas contienen `created_at` y `updated_at` con `DEFAULT now()`.
- Unicidad: múltiples `CONSTRAINT ... UNIQUE` (ej.: `uq_country_alpha2`, `uq_user_account_username`, `uq_ticket_number`, `uq_invoice_number`, `uq_fare_code`).
- CHECK constraints frecuentes para dominios y fechas (ej.: `ck_person_gender`, `ck_reservation_dates`, `ck_ticket_segment_sequence`, `ck_flight_segment_schedule`).
- Claves compuestas y restricciones de paridad: ejemplo `uq_flight_instance (airline_id, flight_number, service_date)`, y la FK compuesta en `seat_assignment` que referencia `ticket_segment(ticket_segment_id, flight_segment_id)`.
- Comentarios DDL explícitos: `COMMENT ON TABLE reservation`, `ticket_segment`, `seat_assignment`, `loyalty_account_tier`, `invoice_line`.

#### Índices explícitos 
- Hay índices adicionales creados con `CREATE INDEX` para columnas de join y búsqueda (ej.: `idx_country_continent_id`, `idx_person_document_number`, `idx_flight_service_date`, `idx_invoice_sale_id`, etc.).

#### Observaciones estrictas 
- No hay triggers ni funciones DDL definidas en el archivo leído; sólo tablas, constraints, comentarios e índices.
- El DDL declara la extensión `pgcrypto` (línea inicial) para `gen_random_uuid()`.

### Recomendaciones técnicas (breves y concretas)
1. Antes de cualquier cambio estructural (índices parciales, soft-delete, etc.) ejecutar comprobaciones de duplicados sobre columnas `UNIQUE` para evitar fallos en migraciones.
2. Probar cambios en un entorno de qa con copia de datos, verificando constraints, índices y tiempos de consulta.
3. Revisar índices actuales y añadir índices a columnas de filtro/join críticas si se detectan consultas lentas (p.ej. `flight(service_date)`, `sale(reservation_id)`).
4. Documentar las claves compuestas sensibles (ej.: FK compuesta en `seat_assignment`) antes de introducir automatismos que modifiquen esas relaciones.

## Conclusión
- El DDL define un esquema relacional normalizado con PKs UUID, abundantes constraints y FK que modelan integridad referencial. El análisis anterior fue reescrito para listar de forma exacta las tablas, relaciones y patrones visibles en el archivo `modelo_postgresql.sql`.
