# Análisis de Dominio — Modelo de Datos PostgreSQL

> **Autor:** Freinier Steven Cardona Perez
> **Fecha:** Abril 2026  
> **Fuente:** `modelo_postgresql.sql`

---

## 1. Introducción

El modelo analizado corresponde a un **sistema de gestión integral para una aerolínea comercial**. Su alcance funcional cubre desde la administración geográfica y de flota hasta la venta de tiquetes, el embarque de pasajeros, los pagos y la facturación.

El diseño evidencia una arquitectura orientada a soportar operaciones B2C y B2B con múltiples aerolíneas bajo un mismo núcleo de datos (*multi-tenant* a nivel de `airline_id`), lo que sugiere que la plataforma puede operar como un sistema SaaS para varias compañías aéreas simultáneamente.

La base de datos consta de aproximadamente **70 tablas** distribuidas en **9 dominios funcionales** claramente delimitados, con énfasis en la normalización (3FN) y en la trazabilidad de eventos críticos de negocio.

---

## 2. Identificación de Dominios Funcionales

### 2.1 Geografía y Datos de Referencia

**Propósito:** Proveer la jerarquía geográfica completa que sirve de base para aeropuertos, direcciones, clientes y configuraciones regionales. Actúa como catálogo de soporte transversal a todo el sistema.

| Tabla | Descripción |
|---|---|
| `continent` | Catálogo de continentes con código normalizado |
| `country` | Países con códigos ISO-Alpha2/3 y vínculo al continente |
| `state_province` | Estados o provincias dentro de cada país |
| `city` | Ciudades con asignación de zona horaria |
| `district` | Subdivisiones urbanas dentro de una ciudad |
| `address` | Dirección física con soporte para coordenadas geográficas (lat/lon) |
| `time_zone` | Zonas horarias con offset UTC en minutos |
| `currency` | Monedas ISO con símbolo y unidades menores |

**Por qué esta estructura:** La cascada `continent → country → state_province → city → district → address` permite geolocalización granular de aeropuertos, proveedores de mantenimiento y clientes sin duplicar datos de ubicación en cada entidad.

---

### 2.2 Aerolínea

**Propósito:** Representa la entidad comercial operadora. Es el eje *tenant* del modelo; prácticamente todas las entidades operativas se relacionan con `airline`.

| Tabla | Descripción |
|---|---|
| `airline` | Compañía aérea con códigos IATA/ICAO y país de origen |

**Por qué esta estructura:** Al centralizar la aerolínea en una sola tabla liviana, el modelo permite operar múltiples operadores sin reestructurar el esquema. La restricción `uq_airline_iata` y `uq_airline_icao` garantizan unicidad en el estándar internacional de aviación.

---

### 2.3 Identidad y Personas

**Propósito:** Gestionar la identidad única de cualquier actor humano en el sistema (pasajeros, agentes, empleados) bajo un modelo unificado de persona, evitando duplicar datos demográficos.

| Tabla | Descripción |
|---|---|
| `person` | Datos demográficos centralizados de cualquier individuo |
| `person_type` | Catálogo de tipos de persona (pasajero, agente, etc.) |
| `person_document` | Documentos de identidad (pasaporte, cédula) con país emisor |
| `person_contact` | Canales de contacto (email, teléfono) clasificados por tipo |
| `document_type` | Catálogo de tipos de documento |
| `contact_type` | Catálogo de tipos de contacto |

**Por qué esta estructura:** Un pasajero, un agente de check-in y un cliente de lealtad son la misma `person`. Esta separación evita tener tablas `passenger`, `agent` y `customer` con campos demográficos duplicados. El patrón *Party Model* reduce la redundancia y facilita la gestión de privacidad de datos (GDPR/regulaciones locales).

---

### 2.4 Seguridad y Control de Acceso

**Propósito:** Implementar un modelo de autorización basado en roles (RBAC) para controlar el acceso de usuarios internos al sistema.

| Tabla | Descripción |
|---|---|
| `user_account` | Cuenta de acceso vinculada a una `person`, con hash de contraseña |
| `user_status` | Estados posibles de una cuenta (activa, bloqueada, etc.) |
| `security_role` | Roles del sistema (administrador, agente, supervisor) |
| `security_permission` | Permisos atómicos del sistema |
| `user_role` | Asignación N:N de roles a usuarios con trazabilidad del asignador |
| `role_permission` | Asignación N:N de permisos a roles |

**Por qué esta estructura:** El modelo RBAC clásico `usuario → rol → permiso` permite modificar políticas de seguridad sin alterar el código de aplicación. La columna `assigned_by_user_id` en `user_role` provee auditoría nativa de quién otorgó cada acceso.

---

### 2.5 Clientes y Programa de Lealtad

**Propósito:** Gestionar la relación comercial del pasajero con cada aerolínea, incluyendo su historial de millas, nivel de fidelización y beneficios otorgados.

| Tabla | Descripción |
|---|---|
| `customer` | Relación entre una persona y una aerolínea específica |
| `customer_category` | Segmentación comercial del cliente |
| `loyalty_program` | Programa de viajero frecuente de una aerolínea |
| `loyalty_tier` | Niveles del programa (bronce, plata, oro, etc.) con millas requeridas |
| `loyalty_account` | Cuenta de lealtad del cliente en un programa |
| `loyalty_account_tier` | Historial de asignaciones de nivel con fechas de vigencia |
| `miles_transaction` | Movimientos de millas (acumulación, redención, ajuste) |
| `customer_benefit` | Beneficios específicos otorgados a un cliente |
| `benefit_type` | Catálogo de tipos de beneficio |

**Por qué esta estructura:** La tabla `loyalty_account_tier` desacopla el nivel actual del historial de niveles, evitando una dependencia transitiva en `loyalty_account` (preserva 3FN). `miles_transaction` con `miles_delta` positivo/negativo permite reconstruir el saldo de millas en cualquier punto del tiempo mediante una suma acumulada.

---

### 2.6 Aeropuertos e Infraestructura

**Propósito:** Modelar la infraestructura física de los aeropuertos: terminales, puertas de embarque, pistas y regulaciones vigentes.

| Tabla | Descripción |
|---|---|
| `airport` | Aeropuerto con códigos IATA/ICAO y dirección georreferenciada |
| `terminal` | Terminales dentro de un aeropuerto |
| `boarding_gate` | Puertas de embarque por terminal |
| `runway` | Pistas de aterrizaje/despegue con longitud y tipo de superficie |
| `airport_regulation` | Regulaciones aeroportuarias con fechas de vigencia |

**Por qué esta estructura:** La jerarquía `airport → terminal → boarding_gate` refleja la estructura física real y permite asignar vuelos a puertas específicas. `airport_regulation` con `effective_from/to` soporta el versionamiento temporal de normativas sin eliminar registros históricos.

---

### 2.7 Flota y Mantenimiento de Aeronaves

**Propósito:** Gestionar el inventario de aeronaves, su configuración de cabina/asientos y el ciclo de vida de mantenimiento.

| Tabla | Descripción |
|---|---|
| `aircraft_manufacturer` | Fabricantes (Boeing, Airbus, etc.) |
| `aircraft_model` | Modelos con rango máximo de vuelo |
| `aircraft` | Aeronave física con número de registro y matrícula |
| `cabin_class` | Clases de cabina (económica, ejecutiva, primera) |
| `aircraft_cabin` | Configuración de cabinas por aeronave específica |
| `aircraft_seat` | Inventario de asientos con atributos (ventana, pasillo, salida) |
| `maintenance_provider` | Proveedores externos de mantenimiento |
| `maintenance_type` | Tipos de mantenimiento (A-check, C-check, etc.) |
| `maintenance_event` | Eventos de mantenimiento con estado y fechas |

**Por qué esta estructura:** La separación `aircraft_model → aircraft → aircraft_cabin → aircraft_seat` permite que dos aeronaves del mismo modelo tengan configuraciones de asientos distintas (*liveries* diferentes), un requisito real en operaciones de flota mixta.

---

### 2.8 Operaciones de Vuelo

**Propósito:** Modelar la planificación y ejecución de vuelos, incluyendo segmentos de ruta, tiempos reales vs. programados y registro de demoras.

| Tabla | Descripción |
|---|---|
| `flight` | Vuelo como instancia de aerolínea + número + fecha de servicio |
| `flight_status` | Estados del vuelo (a tiempo, demorado, cancelado) |
| `flight_segment` | Segmento de ruta entre dos aeropuertos con tiempos reales y programados |
| `flight_delay` | Registro de demoras con causa y minutos de retraso |
| `delay_reason_type` | Catálogo de causas de demora |

**Por qué esta estructura:** Un vuelo puede tener múltiples segmentos (escalas), por lo que `flight_segment` es la unidad mínima operable. La distinción entre `scheduled_*_at` y `actual_*_at` en `flight_segment` permite calcular OTP (*On-Time Performance*) y SLAs de compensación sin tablas adicionales.

---

### 2.9 Ventas, Reservas y Boletería

**Propósito:** Cubrir el flujo comercial completo desde la reserva hasta la emisión del tiquete, asignación de asiento, equipaje y proceso de embarque.

| Tabla | Descripción |
|---|---|
| `reservation` | Reserva padre con código PNR y canal de venta |
| `reservation_status` | Estados de reserva (confirmada, en espera, cancelada) |
| `reservation_passenger` | Pasajeros incluidos en una reserva con tipo (adulto, niño, infante) |
| `sale_channel` | Canal de venta (web, agencia, call center) |
| `fare_class` | Clase tarifaria vinculada a clase de cabina |
| `fare` | Tarifa con precio base, penalidades y vigencia por ruta |
| `sale` | Venta concreta derivada de una reserva |
| `ticket` | Tiquete electrónico emitido por pasajero y tarifa |
| `ticket_status` | Estados del tiquete (emitido, usado, reembolsado) |
| `ticket_segment` | Segmentos de vuelo incluidos en un tiquete (itinerario) |
| `seat_assignment` | Asignación de asiento por segmento de tiquete |
| `baggage` | Equipaje registrado con peso, tipo y estado |
| `check_in` | Proceso de check-in por segmento con estado y grupo de embarque |
| `boarding_pass` | Pase de abordar con código de barras único |
| `boarding_group` | Grupos de embarque con orden de prioridad |
| `boarding_validation` | Validaciones en puerta con resultado (aprobado/rechazado) |
| `check_in_status` | Estados del check-in |

**Por qué esta estructura:** La cadena `reservation → sale → ticket → ticket_segment → seat_assignment` separa las responsabilidades comerciales de las operativas. Esto permite, por ejemplo, reasignar un asiento sin afectar la reserva o emitir un nuevo tiquete sin duplicar datos del pasajero.

---

### 2.10 Pagos y Facturación

**Propósito:** Gestionar el ciclo financiero de cada venta: cobro, transacciones con pasarelas de pago, reembolsos, facturación detallada y tipos de cambio.

| Tabla | Descripción |
|---|---|
| `payment` | Pago asociado a una venta con monto y método |
| `payment_status` | Estados del pago (autorizado, capturado, fallido) |
| `payment_method` | Métodos de pago (tarjeta, PSE, efectivo, millas) |
| `payment_transaction` | Transacciones individuales de la pasarela (AUTH, CAPTURE, REFUND) |
| `refund` | Reembolsos con fechas de solicitud y procesamiento |
| `invoice` | Factura emitida por la venta |
| `invoice_status` | Estados de factura (borrador, emitida, anulada) |
| `invoice_line` | Líneas detalladas de factura con precio unitario y cantidad |
| `tax` | Catálogo de impuestos con tasa y vigencia temporal |
| `exchange_rate` | Tipos de cambio diarios entre pares de monedas |

**Por qué esta estructura:** `payment_transaction` registra cada interacción con la pasarela de pago de forma inmutable, soportando auditorías y conciliaciones bancarias. `invoice_line` sin totales derivados (el total se calcula como `SUM(quantity * unit_price)`) es una decisión consciente de 3FN documentada en los comentarios del DDL.

---

## 3. Análisis de Entidades Principales

Las siguientes tablas actúan como **pivotes de negocio** — son el núcleo alrededor del cual giran los flujos más críticos del sistema:

| Entidad | Rol en el negocio | Por qué es pivote |
|---|---|---|
| `airline` | Operador principal del sistema | Casi toda entidad operativa lleva `airline_id`; es el discriminador *multi-tenant* |
| `person` | Actor humano universal | Unifica pasajero, cliente, agente y usuario bajo un único registro de identidad |
| `flight_segment` | Unidad mínima de operación aérea | Es referenciada por `ticket_segment`, `seat_assignment`, `baggage`, `check_in` y `flight_delay` |
| `reservation` | Raíz del flujo comercial | Como indica el comentario del DDL, es la entidad raíz de booking; sin ella no existe `sale` ni `ticket` |
| `ticket_segment` | Puente entre producto y operación | Conecta el tiquete (producto comercial) con el segmento de vuelo (hecho operativo) |
| `loyalty_account` | Centro del programa de fidelización | Concentra millas, niveles e historial de beneficios del viajero frecuente |
| `aircraft` | Activo físico operativo | Vincula la flota (cabinas, asientos, mantenimiento) con los vuelos programados |

---

## 4. Relaciones Relevantes

### 4.1 Relaciones 1:N Críticas

| Relación | Cardinalidad | Regla de negocio |
|---|---|---|
| `airline → customer` | 1:N | Un cliente pertenece a una aerolínea específica; el mismo `person` puede ser cliente de múltiples aerolíneas |
| `flight → flight_segment` | 1:N | Un vuelo puede tener múltiples segmentos (escalas técnicas o conexiones internas) |
| `reservation → reservation_passenger` | 1:N | Una reserva agrupa a múltiples pasajeros bajo un solo PNR |
| `ticket → ticket_segment` | 1:N | Un tiquete puede cubrir un itinerario con varias etapas |
| `sale → ticket` | 1:N | Una venta puede incluir tiquetes para varios pasajeros de la misma reserva |
| `payment → payment_transaction` | 1:N | Cada pago puede tener múltiples transacciones (autorización + captura + posible reversión) |
| `invoice → invoice_line` | 1:N | Una factura se descompone en líneas tributables independientes |

### 4.2 Relaciones N:N y Tablas Puente

| Relación | Tabla puente | Atributos relevantes |
|---|---|---|
| `user_account ↔ security_role` | `user_role` | `assigned_at`, `assigned_by_user_id` — auditoría completa |
| `security_role ↔ security_permission` | `role_permission` | `granted_at` — control temporal de permisos |
| `ticket ↔ flight_segment` | `ticket_segment` | `segment_sequence_no`, `fare_basis_code` — orden del itinerario y base tarifaria |
| `aircraft ↔ cabin_class` | `aircraft_cabin` | `deck_number` — soporta aeronaves de doble cubierta (A380) |

### 4.3 Reglas de Negocio Implícitas en el Modelo

- **Unicidad de asiento por vuelo:** La constraint `uq_seat_assignment_flight_seat` sobre `(flight_segment_id, aircraft_seat_id)` garantiza que ningún asiento sea asignado a dos pasajeros en el mismo vuelo.
- **Integridad del itinerario:** La FK compuesta en `seat_assignment` hacia `ticket_segment(ticket_segment_id, flight_segment_id)` asegura que solo se pueda asignar asiento a un segmento que realmente pertenezca al tiquete del pasajero.
- **Inmutabilidad contable:** `miles_transaction` con `miles_delta ≠ 0` y tipos `EARN/REDEEM/ADJUST` implementa un libro mayor de millas que no permite editar registros históricos.
- **Consistencia temporal:** Múltiples constraints `CHECK` verifican que las fechas de inicio sean anteriores a las de fin en documentos, tarifas, mantenimientos, facturas y vuelos.
- **Segregación de identidad:** Un `person` solo puede tener **un** `user_account` (`uq_user_account_person`), pero puede tener **múltiples** `customer` records (uno por aerolínea).

---

## 5. Conclusión del Modelo

### Fortalezas Arquitectónicas

El modelo demuestra un nivel de madurez elevado en varios aspectos:

- **Normalización rigurosa (3FN):** Se evitan columnas calculadas persistidas (totales de facturas, saldo de millas) y se separan los históricos de los estados actuales (`loyalty_account_tier`). Los comentarios en el DDL confirman que estas decisiones son intencionales.
- **Diseño *multi-tenant* natural:** El uso generalizado de `airline_id` como discriminador permite escalar el sistema a múltiples operadores sin particionado físico.
- **Trazabilidad nativa:** Todas las tablas tienen `created_at` y `updated_at`. Entidades críticas como `user_role`, `miles_transaction` y `boarding_validation` registran el agente que realizó la acción.
- **Cobertura del estándar aeronáutico:** La inclusión de códigos IATA/ICAO en aerolíneas y aeropuertos, y la distinción entre tiempos programados y reales, alinean el modelo con estándares internacionales (IATA NDC, ATA iSpec).

### Áreas de Evolución Potencial

| Área | Consideración |
|---|---|
| **Auditoría centralizada** | Un log de cambios genérico (tabla `audit_log` o extensión `temporal_tables`) potenciaría el rastreo de modificaciones más allá de `updated_at` |
| **Soft-deletes** | No existe columna `deleted_at` o `is_deleted`; para entidades reguladas (tiquetes, pagos) puede ser necesario por cumplimiento normativo |
| **Particionado** | `flight_segment`, `miles_transaction` y `payment_transaction` son candidatos a particionado por rango de fecha a medida que el volumen crezca |
| **Soporte multilingüe** | Los nombres de catálogos están en un solo idioma; una tabla de traducciones permitiría internacionalización sin alterar el esquema base |
| **Gestión de inventario de asientos** | El modelo actual no tiene una tabla explícita de disponibilidad/cupos por vuelo y clase; esto suele implementarse como una vista materializada o servicio externo de *inventory management* |

### Valoración Final

> El modelo refleja un diseño **sólido, escalable y bien fundamentado** para una plataforma de operaciones aéreas. Su principal fortaleza es el equilibrio entre normalización estricta y practicidad operativa. Está preparado para crecer en volumen de datos mediante indexación estratégica (ya incluida) y en cobertura funcional mediante la adición de nuevos dominios sin reestructurar los existentes.
