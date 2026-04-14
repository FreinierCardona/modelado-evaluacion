# Airline Management System — Análisis de Dominios y Entidades

> Documento de referencia arquitectónica · Versión 1.1 · Abril 2026

---

## 1. Introducción

Este documento describe la arquitectura de datos del sistema de gestión de aerolíneas. Cubre **12 dominios funcionales** con un total de **67 entidades** sobre PostgreSQL con la extensión `pgcrypto`.

**Convenciones del esquema:**
- Todas las PKs son `UUID` generadas con `gen_random_uuid()`.
- Los catálogos tienen `code + name` con restricción `UNIQUE` en ambos.
- Las tablas de unión M:N tienen `UNIQUE` compuesto sobre las FKs.
- Los estados usan `CHECK constraints` con valores explícitos.
- Todas las tablas tienen `created_at` y `updated_at` automáticos.

---

## 2. Mapa de Dominios

Los 12 dominios se organizan en tres capas:

| Capa Fundacional | Capa Operacional | Capa Transaccional |
|---|---|---|
| 01 Geografía y Referencia | 06 Aeropuerto | 09 Ventas, Reservas y Tickets |
| 02 Aerolínea | 07 Aeronave | 10 Embarque |
| 03 Identidad | 08 Operaciones de Vuelo | 11 Pagos |
| 04 Seguridad | 05 Cliente y Loyalty | 12 Facturación |

---

## 3. Detalle por Dominio

### Dominio 01 — Geografía y Datos de Referencia

Provee el modelo jerárquico de ubicaciones: `continente → país → estado → ciudad → distrito → dirección`. Es el dominio fundacional: todo lo que necesita ubicarse físicamente depende de `address_id`.

**Lógica:** `time_zone` se asocia a `city` para soportar cálculos de hora local en vuelos internacionales. `currency` es un catálogo compartido con billing y loyalty.

| Tabla | Descripción | FK clave |
|---|---|---|
| `continent` | Agrupación de países por continente | — |
| `country` | País soberano con código ISO | `continent_id` |
| `state_province` | División administrativa de primer nivel | `country_id` |
| `city` | Municipio con zona horaria | `state_province_id`, `time_zone_id` |
| `district` | Subdivisión interna de una ciudad | `city_id` |
| `address` | Dirección física con coordenadas GPS | `district_id` |
| `time_zone` | Zona horaria con offset UTC en minutos | — |
| `currency` | Moneda ISO con símbolo y unidades menores | — |

---

### Dominio 02 — Aerolínea

Define las aerolíneas operadoras. `airline_id` es clave foránea en `customer`, `loyalty_program`, `fare` y `flight`, lo que convierte a `airline` en el eje que articula todos los dominios operacionales.

**Lógica:** `is_active` permite deshabilitar operadores sin borrar registros históricos.

| Tabla | Descripción | FK clave |
|---|---|---|
| `airline` | Operador aéreo con códigos IATA/ICAO | `home_country_id` |

---

### Dominio 03 — Identidad (Personas y Documentos)

Modela personas físicas independientemente de su rol (pasajero, empleado, usuario). Esta separación evita duplicar datos demográficos entre `customer`, `user_account` y `reservation_passenger`.

**Lógica:** El flag `is_primary` en `person_document` (FIX-01) con índice parcial garantiza un documento activo por persona por tipo. `person` se referencia desde todos los contextos manteniendo la identidad en un solo lugar.

| Tabla | Descripción | FK clave |
|---|---|---|
| `person` | Persona física: nombres, nacimiento, género, nacionalidad | `person_type_id`, `nationality_country_id` |
| `person_type` | Catálogo de tipos de persona | — |
| `document_type` | Tipos de documento (pasaporte, DNI, etc.) | — |
| `person_document` | Documento de identidad o viaje emitido a una persona | `person_id`, `document_type_id`, `issuing_country_id` |
| `contact_type` | Catálogo de tipos de contacto (email, teléfono) | — |
| `person_contact` | Dato de contacto de una persona | `person_id`, `contact_type_id` |

---

### Dominio 04 — Seguridad (Usuarios, Roles y Permisos)

Implementa un modelo **RBAC** (Role-Based Access Control). Un `user_account` está ligado a una persona física y se le asignan roles; cada rol tiene permisos granulares.

**Lógica:** `user_account` tiene restricción 1-1 con `person`. `assigned_by_user_id` en `user_role` registra quién asignó el rol. `role_permission` normaliza la relación M:N entre roles y permisos.

| Tabla | Descripción | FK clave |
|---|---|---|
| `user_account` | Cuenta de acceso al sistema | `person_id`, `user_status_id` |
| `user_status` | Estados de cuenta (activo, bloqueado) | — |
| `security_role` | Rol de seguridad con descripción funcional | — |
| `security_permission` | Permiso atómico del sistema | — |
| `user_role` | Asignación de rol a usuario con auditoría | `user_account_id`, `security_role_id` |
| `role_permission` | Relación M:N entre roles y permisos | `security_role_id`, `security_permission_id` |

---

### Dominio 05 — Cliente y Fidelización (Loyalty)

Gestiona la relación comercial de la aerolínea con sus pasajeros frecuentes. Un `customer` es una persona registrada ante una aerolínea específica.

**Lógica:** Una persona puede ser cliente de múltiples aerolíneas. `loyalty_account_tier` (FIX-02) guarda el historial de niveles con `is_current` para lookup en tiempo constante. `miles_transaction` (FIX-03) agrega `balance_after` para evitar recalcular el saldo sumando toda la historia.

| Tabla | Descripción | FK clave |
|---|---|---|
| `customer` | Relación persona-aerolínea como cliente registrado | `airline_id`, `person_id` |
| `customer_category` | Segmentación comercial de clientes | — |
| `loyalty_program` | Programa de millas de una aerolínea | `airline_id`, `default_currency_id` |
| `loyalty_tier` | Niveles dentro del programa (Silver, Gold, Platinum) | `loyalty_program_id` |
| `loyalty_account` | Cuenta individual de millas del cliente | `customer_id`, `loyalty_program_id` |
| `loyalty_account_tier` | Historial de nivel activo/pasado de la cuenta | `loyalty_account_id`, `loyalty_tier_id` |
| `miles_transaction` | Débito/crédito de millas con saldo snapshot | `loyalty_account_id` |
| `benefit_type` | Catálogo de beneficios disponibles | — |
| `customer_benefit` | Beneficio asignado a un cliente con vigencia | `customer_id`, `benefit_type_id` |

---

### Dominio 06 — Aeropuerto

Modela la infraestructura física: terminales, puertas de embarque, pistas y regulaciones. `boarding_gate` es el punto de encuentro operacional entre este dominio y el dominio de vuelos (FIX-04).

| Tabla | Descripción | FK clave |
|---|---|---|
| `airport` | Aeropuerto con códigos IATA/ICAO y ubicación | `address_id` |
| `terminal` | Terminal de un aeropuerto | `airport_id` |
| `boarding_gate` | Puerta de embarque en una terminal | `terminal_id` |
| `runway` | Pista de aterrizaje/despegue con especificaciones | `airport_id` |
| `airport_regulation` | Regulación vigente aplicable al aeropuerto | `airport_id` |

---

### Dominio 07 — Aeronave

Define la flota: fabricantes, modelos, aeronaves con configuración de cabinas y asientos, e historial de mantenimiento.

**Lógica:** La jerarquía `aircraft → aircraft_cabin → aircraft_seat` representa la configuración física exacta del avión. `aircraft_cabin` liga a `cabin_class` habilitando la fijación de tarifas. `maintenance_event` garantiza trazabilidad de aeronavegabilidad.

| Tabla | Descripción | FK clave |
|---|---|---|
| `aircraft_manufacturer` | Fabricante de aeronaves (Boeing, Airbus) | — |
| `aircraft_model` | Modelo de aeronave con alcance máximo | `aircraft_manufacturer_id` |
| `cabin_class` | Clase de cabina (Economy, Business, First) | — |
| `aircraft` | Aeronave individual con matrícula y número de serie | `airline_id`, `aircraft_model_id` |
| `aircraft_cabin` | Cabina configurada en una aeronave específica | `aircraft_id`, `cabin_class_id` |
| `aircraft_seat` | Asiento individual con fila, columna y características | `aircraft_cabin_id` |
| `maintenance_provider` | Proveedor de servicios de mantenimiento | `address_id` |
| `maintenance_type` | Tipo de mantenimiento (A-check, C-check, etc.) | — |
| `maintenance_event` | Evento de mantenimiento con estado y fechas | `aircraft_id`, `maintenance_type_id` |

---

### Dominio 08 — Operaciones de Vuelo

Modela el vuelo programado y sus segmentos. Un `flight` es la instancia operacional (número de vuelo en una fecha); un `flight_segment` representa cada tramo del itinerario.

**Lógica:** FIX-04 agrega `departure_gate_id` y `arrival_gate_id` al segmento, permitiendo correlacionar el vuelo con la infraestructura del aeropuerto sin consultar `boarding_validation`.

| Tabla | Descripción | FK clave |
|---|---|---|
| `flight_status` | Catálogo de estados (programado, en vuelo, aterrizó) | — |
| `delay_reason_type` | Catálogo de causas de demora (clima, técnico, ATC) | — |
| `flight` | Vuelo operacional: número + fecha + aeronave | `airline_id`, `aircraft_id`, `flight_status_id` |
| `flight_segment` | Tramo origen-destino con tiempos y puertas asignadas | `flight_id`, `origin_airport_id`, `destination_airport_id` |
| `flight_delay` | Registro de demora con causa y minutos | `flight_segment_id`, `delay_reason_type_id` |

---

### Dominio 09 — Ventas, Reservas y Tickets

Es el corazón transaccional del sistema. El flujo es: `reservation → sale → ticket → ticket_segment → seat_assignment → baggage`.

**Lógica:** `reservation` es la entidad raíz y puede ser anónima (`booked_by_customer_id` nullable). `seat_assignment` usa una FK compuesta `(ticket_segment_id, flight_segment_id)` para prevenir asignaciones cruzadas. `baggage` está ligado al `ticket_segment` permitiendo rastreo por tramo.

| Tabla | Descripción | FK clave |
|---|---|---|
| `reservation_status` | Catálogo de estados de reserva | — |
| `sale_channel` | Canal de venta (web, app, agencia, aeropuerto) | — |
| `fare_class` | Clase tarifaria ligada a clase de cabina | `cabin_class_id` |
| `fare` | Tarifa con origen, destino, precio y vigencia | `airline_id`, `origin_airport_id`, `destination_airport_id` |
| `ticket_status` | Estados del ticket (emitido, usado, anulado) | — |
| `reservation` | Reserva raíz con código PNR y canal | `reservation_status_id`, `sale_channel_id` |
| `reservation_passenger` | Pasajero incluido en la reserva | `reservation_id`, `person_id` |
| `sale` | Transacción de venta sobre una reserva | `reservation_id`, `currency_id` |
| `ticket` | Ticket electrónico de vuelo por pasajero | `sale_id`, `reservation_passenger_id`, `fare_id` |
| `ticket_segment` | Tramo de vuelo cubierto por el ticket | `ticket_id`, `flight_segment_id` |
| `seat_assignment` | Asiento asignado por tramo con control de unicidad | `ticket_segment_id`, `aircraft_seat_id` |
| `baggage` | Equipaje registrado por tramo con estado y peso | `ticket_segment_id` |

---

### Dominio 10 — Embarque (Boarding)

Gestiona el proceso de check-in hasta el embarque físico. El flujo es: `check_in → boarding_pass → boarding_validation`.

**Lógica:** `check_in` es 1-1 con `ticket_segment`. `boarding_pass` es 1-1 con `check_in`. `boarding_validation` registra el escaneo en puerta con resultado y agente.

| Tabla | Descripción | FK clave |
|---|---|---|
| `boarding_group` | Grupo de abordaje con secuencia (1, 2, 3...) | — |
| `check_in_status` | Estados del check-in | — |
| `check_in` | Check-in por tramo de ticket con agente y hora | `ticket_segment_id`, `check_in_status_id` |
| `boarding_pass` | Pase de abordar con código de barras | `check_in_id` |
| `boarding_validation` | Resultado del escaneo en puerta | `boarding_pass_id`, `boarding_gate_id` |

---

### Dominio 11 — Pagos

Captura el ciclo completo de pago: autorización, captura, reversos y reembolsos.

**Lógica:** `payment_transaction` descompone el ciclo financiero (`AUTH → CAPTURE → VOID/REFUND/REVERSAL`). `refund` soporta reembolsos parciales. `invoice_payment` (FIX-05) cierra la reconciliación conectando `payment` con `invoice`.

| Tabla | Descripción | FK clave |
|---|---|---|
| `payment_status` | Estados del pago (pendiente, autorizado, fallido) | — |
| `payment_method` | Medio de pago (tarjeta, efectivo, millas) | — |
| `payment` | Pago registrado contra una venta | `sale_id`, `payment_status_id`, `currency_id` |
| `payment_transaction` | Transacción financiera atómica del pago | `payment_id` |
| `refund` | Reembolso total o parcial de un pago | `payment_id` |

---

### Dominio 12 — Facturación (Billing)

Gestiona impuestos, tipos de cambio, emisión de facturas y líneas de detalle.

**Lógica:** `tax` tiene vigencia temporal. `exchange_rate` persiste tasas históricas. `invoice_line` mantiene 3FN: no persiste totales derivados. `invoice_payment` (FIX-05) vincula pagos con facturas, soportando pagos parciales y adelantos.

| Tabla | Descripción | FK clave |
|---|---|---|
| `tax` | Impuesto con tasa porcentual y vigencia | — |
| `exchange_rate` | Tasa de cambio histórica entre dos monedas | `from_currency_id`, `to_currency_id` |
| `invoice_status` | Estado de factura (borrador, emitida, pagada) | — |
| `invoice` | Factura emitida sobre una venta | `sale_id`, `invoice_status_id`, `currency_id` |
| `invoice_line` | Línea de detalle de factura | `invoice_id`, `tax_id` |
| `invoice_payment` | *(Nuevo FIX-05)* Reconciliación entre pagos y facturas | `invoice_id`, `payment_id` |

---

## 4. Flujo de Negocio — De la reserva al saldo de millas

| Paso | Actividad | Tablas involucradas |
|---|---|---|
| 1. Reserva | Cliente contacta aerolínea → se crea PNR | `reservation`, `reservation_passenger`, `sale_channel` |
| 2. Venta | Se formaliza la compra | `sale`, `ticket`, `fare` |
| 3. Segmentación | Por cada tramo del itinerario | `ticket_segment`, `flight_segment` |
| 4. Asignación | Sistema o pasajero asignan asiento | `seat_assignment`, `baggage` |
| 5. Pago | Autorización y captura | `payment`, `invoice`, `invoice_payment` |
| 6. Check-in | Online o presencial | `check_in`, `boarding_group` |
| 7. Boarding pass | Emisión con código de barras | `boarding_pass` |
| 8. Embarque | Escaneo en puerta | `boarding_validation`, `boarding_gate` |
| 9. Vuelo | Tiempos reales y demoras | `flight_segment`, `flight_delay` |
| 10. Loyalty | Acreditación de millas post-vuelo | `miles_transaction`, `loyalty_account_tier` |

---

## 5. Tablas con mayor peso arquitectónico

Estas tablas son referenciadas por múltiples dominios y actúan como puntos de articulación del sistema:

| Tabla | Referenciada por | Rol |
|---|---|---|
| `person` | `customer`, `user_account`, `reservation_passenger` | Identidad canónica única |
| `airline` | `aircraft`, `customer`, `loyalty_program`, `fare`, `flight` | Eje central de la plataforma |
| `airport` | `flight_segment` (x2), `fare` (x2), `airport_regulation` | Nodo geográfico-operacional |
| `flight_segment` | `ticket_segment`, `flight_delay`, `seat_assignment` | Unión entre planificación y venta |
| `ticket_segment` | `seat_assignment`, `baggage`, `check_in` | Tramo del pasajero |
| `sale` | `ticket`, `payment`, `invoice` | Raíz financiera |
| `currency` | `loyalty_program`, `fare`, `sale`, `payment`, `invoice`, `exchange_rate` | Moneda transversal |
| `cabin_class` | `aircraft_cabin`, `fare_class` | Puente entre aeronave y tarifa |
| `boarding_gate` | `flight_segment` (FIX-04), `boarding_validation` | Vincula aeropuerto con embarque |
