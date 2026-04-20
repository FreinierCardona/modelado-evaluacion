# ADR-002: Roles y Permisos (RBAC) — Extensión ligera para recursos y alcance

**Contexto**
- Ya existen tablas básicas: `user_account`, `security_role`, `security_permission`, `user_role`, `role_permission`.
- Requerimos control de acceso con alcance (por airline, por loyalty_program u objetos específicos) y la posibilidad de overrides por usuario.

**Problema**
- El diseño actual permite asignar roles y permisos globales, pero no soporta permisos con scope/alcance (p. ej. permiso sobre una aerolínea específica) ni overrides por usuario.

**Decisión**
- Extender el modelo RBAC con tablas mínimas para resource-scoped permissions y overrides:
  - `security_resource` (opcional, catálogo de recursos)
  - `role_resource_permission` (asocia `security_role` + `security_permission` + scope)
  - `user_permission_override` (permite permitir/denegar explícito por usuario y scope)

**Justificación técnica**
- Mantener `role_permission` para permisos globales y migrar/duplicar filas a `role_resource_permission` con `resource_type`/`resource_id = NULL` para global.
- El enfoque de scope evita proliferación de roles y soporta multi-tenant lógico por `airline_id`.

**Modelo resumido (tablas propuestas)**

| Tabla | PK | FKs | Campos clave |
|---|---:|---|---|
| `role_resource_permission` | `rrp_id (uuid)` | `security_role_id`, `security_permission_id` | `resource_type varchar(50)`, `resource_id uuid NULL`, `granted_at` |
| `user_permission_override` | `upo_id (uuid)` | `user_account_id`, `security_permission_id` | `allow boolean`, `resource_type varchar(50)`, `resource_id uuid NULL`, `created_at` |
| `security_resource` (opcional) | `resource_id (uuid)` |  | `resource_type`, `resource_key`, `resource_name` |

**Consecuencias o impacto esperado**
- +Flexibilidad: permisos por aerolínea/programa/objeto.
- +Complejidad en checks: las consultas de autorización deben mantener un `UNION`/`priority` entre global role->perm, role_resource_perm, user override.
- Recomendación: cachear `effective_permissions` por `user_account_id` en capas de aplicación y revalidar tras cambios.

**Notas de migración**
- Backfill: copiar filas existentes de `role_permission` a `role_resource_permission` con `resource_type=NULL`.
- Pequeña ventana de mantenimiento para evitar conflictos de autorización durante la migración.

---
*Archivo: docs/adr/ADR-002-RBAC-Ext-extension.md*