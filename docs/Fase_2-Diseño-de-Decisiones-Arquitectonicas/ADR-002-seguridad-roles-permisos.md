# ADR-002 — Seguridad: Diseño de Roles y Permisos

| Campo | Detalle |
|---|---|
| **Estado** | Aceptado |
| **Fecha** | Abril 2026 |
| **Dominio** | Seguridad |
| **Tablas afectadas** | `user_account`, `security_role`, `security_permission`, `user_role`, `role_permission`, `user_status` |

---

## Contexto

El sistema maneja datos sensibles: documentos de identidad de pasajeros, pagos, facturas y datos de vuelos. Si cualquier persona que use la aplicación pudiera modificar o eliminar cualquier tabla, sería un desastre. Necesitamos controlar quién puede hacer qué.

---

## Problema

Sin un sistema de permisos, cualquier usuario del sistema podría:

- Modificar tarifas o reservas sin autorización.
- Ver información de pagos que no le corresponde.
- Eliminar registros críticos por error o de forma maliciosa.

No hay forma de distinguir un agente de check-in de un administrador del sistema.

---

## Decisión

Se implementa un modelo **RBAC (Control de Acceso Basado en Roles)** con las siguientes tablas:

```
user_account → user_role → security_role → role_permission → security_permission
```

**Cómo funciona:**

1. Cada persona que usa el sistema tiene una `user_account`.
2. A esa cuenta se le asignan uno o más `security_role` (por ejemplo: `AGENTE_CHECK_IN`, `SUPERVISOR`, `ADMIN`).
3. Cada rol tiene una lista de `security_permission` (por ejemplo: `LEER_RESERVAS`, `MODIFICAR_TARIFAS`).
4. La tabla `user_status` controla si la cuenta está activa o bloqueada.

**Detalle importante:** La columna `assigned_by_user_id` en `user_role` registra quién asignó el rol. Esto crea una pista de auditoría: siempre se sabe quién le dio permisos a quién.

---

## Justificación técnica

- **RBAC es el estándar probado** para este tipo de sistemas. En lugar de asignar permisos uno por uno a cada usuario, se agrupan en roles. Si un agente cambia de función, solo se cambia su rol, no sus 20 permisos individuales.

- **La separación `role → permission` en M:N** (tabla `role_permission`) permite que múltiples roles compartan el mismo permiso. Por ejemplo, tanto `SUPERVISOR` como `ADMIN` pueden tener `LEER_REPORTES` sin duplicar datos.

- **`user_account` tiene relación 1-1 con `person`** (restricción `UNIQUE(person_id)`). Esto evita que una misma persona tenga dos cuentas con diferentes niveles de acceso, lo que sería una brecha de seguridad.

- **`user_status`** permite desactivar una cuenta sin borrarla. Si un empleado sale de la empresa, se marca como bloqueado y pierde acceso inmediatamente, pero su historial de acciones queda intacto.

---

## Consecuencias e impacto esperado

✅ El sistema puede definir exactamente qué puede hacer cada tipo de usuario.

✅ Agregar un nuevo rol (por ejemplo `AGENTE_VENTAS`) no requiere cambiar la estructura de la base de datos, solo insertar datos nuevos.

✅ Si hay un acceso sospechoso, `assigned_by_user_id` permite rastrear el origen.

⚠️ La aplicación debe verificar permisos antes de ejecutar cualquier operación crítica. La base de datos define la estructura, pero la lógica de verificación vive en el código de la aplicación.

⚠️ Si no se mantiene actualizado el catálogo de permisos, con el tiempo puede volverse incoherente. Requiere disciplina del equipo de desarrollo.
