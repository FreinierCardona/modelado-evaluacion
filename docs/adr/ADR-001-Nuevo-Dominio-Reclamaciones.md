# ADR-001: Nuevo Dominio — Gestión de Reclamaciones y Compensaciones de Pasajeros

**Contexto**
- El modelo actual incluye tablas relevantes: `flight_delay`, `baggage`, `reservation`, `ticket`, `customer`, `payment`, `refund` y `user_account`.
- No existe un dominio centralizado para rastrear reclamaciones (retrasos, equipaje perdido, cancelaciones) ni su integración con pagos/compensaciones.

**Problema**
- Falta un registro unificado y trazable de reclamaciones de pasajeros que relacione incidentes operativos (delay/loss), clientes, reservas y compensaciones financieras.

**Decisión**
- Introducir un dominio "Claims" (reclamaciones) con un conjunto mínimo de tablas que permitan capturar, procesar y resolver reclamaciones y su impacto contable.

**Justificación técnica**
- Reutiliza claves y relaciones existentes (`customer`, `reservation`, `ticket`, `baggage`, `payment`) para garantizar consistencia y minimizar duplicación.
- Separación de responsabilidades: el dominio Claims se implementa como módulo/servicio que consume eventos (p. ej. `flight_delay`, `baggage` cambios) y persiste en las nuevas tablas.

**Esquema propuesto (resumen)**

| Tabla | PK | FKs | Campos clave (resumen) |
|---|---:|---|---|
| `claim` | `claim_id (uuid)` | `customer_id`, `reservation_id`, `ticket_id`, `claim_type_id`, `claim_status_id` | `reported_at`, `incident_at`, `description`, `amount_requested`, `amount_awarded`, `created_at`, `updated_at` |
| `claim_type` | `claim_type_id` |  | `type_code`, `type_name` (ej: BAGGAGE_LOSS, DELAY_COMPENSATION, CANCELATION)` |
| `claim_status` | `claim_status_id` |  | `status_code`, `status_name` (ej: NEW, UNDER_REVIEW, APPROVED, REJECTED, PAID)` |
| `claim_item` | `claim_item_id` | `claim_id`, `baggage_id`? | `item_type`, `reference_id`, `amount`, `notes` |
| `claim_event` | `claim_event_id` | `claim_id`, `performed_by_user_id` | `event_type`, `event_at`, `details` |
| `claim_attachment` | `attachment_id` | `claim_id`, `uploaded_by_user_id` | `file_key`, `mime_type`, `uploaded_at` |
| `claim_payment` | `claim_payment_id` | `claim_id`, `payment_id` | `amount`, `processed_at`, `notes` |

**Consecuencias o impacto esperado**
- Mejora de la trazabilidad y conciliación: relación directa con `payment`/`refund` para auditoría.
- Incremento de joins en reportes y necesidad de índices: indexar `customer_id`, `reservation_id`, `claim_status_id`.
- Requiere política de almacenamiento para attachments (recomendado: blob storage + metadatos en `claim_attachment`).
- Organización operativa: triggers/consumers para crear reclamos automáticos en casos críticos (ej. `delay_minutes > X`, `baggage_status = 'LOST'`).

**Siguiente paso**
- Crear migración Liquibase inicial con las tablas propuestas y pruebas en entorno `develop`.

---
*Archivo: docs/adr/ADR-001-Nuevo-Dominio-Reclamaciones.md*