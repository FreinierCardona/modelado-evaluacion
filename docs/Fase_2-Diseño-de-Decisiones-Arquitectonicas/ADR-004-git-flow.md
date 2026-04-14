# ADR-004 — Flujo de Trabajo con Git Flow

| Campo | Detalle |
|---|---|
| **Estado** | Aceptado |
| **Fecha** | Abril 2026 |
| **Dominio** | Control de Versiones / DevOps |
| **Afecta** | Todo el equipo de desarrollo |

---

## Contexto

El proyecto tiene múltiples ambientes: desarrollo local, pruebas (QA) y producción (main). Cada historia de usuario necesita pasar por todos esos ambientes antes de llegar a producción. Sin un flujo claro, es fácil mezclar código que no está listo, o subir cambios directamente a producción sin revisión.

---

## Problema

Sin un flujo de ramas definido:

- Los cambios se pueden mezclar en cualquier orden.
- Es difícil saber qué está en QA y qué ya está en producción.
- Un error en una tarea puede bloquear a todo el equipo si está en la rama principal.
- No hay un proceso claro de revisión antes de pasar al siguiente ambiente.

---

## Decisión

Se adopta el siguiente flujo de ramas para cada historia de usuario. Se usa `HU-01` como ejemplo:

### Estructura de ramas

```
main
├── develop
│   └── HU-01-dev
├── qa
│   └── HU-01-qa
└── HU-01-main
```

### Flujo paso a paso

```
1. De main se crean tres ramas base:
   main → develop
   main → qa
   main → HU-01-main

2. De develop se crea la rama de trabajo:
   develop → HU-01-dev

3. De qa se crea la rama de pruebas:
   qa → HU-01-qa
```

### Ciclo de integración

```
HU-01-dev  →  develop  →  HU-01-qa  →  qa  →  HU-01-main  →  main
```

**Descripción de cada paso:**

| Paso | Qué pasa |
|---|---|
| `HU-01-dev → develop` | El developer termina la tarea y hace merge a develop para integrar con el resto del equipo. |
| `develop → HU-01-qa` | Se actualiza la rama de QA con los últimos cambios integrados. |
| `HU-01-qa → qa` | Las pruebas pasaron. Se integra en el ambiente de QA. |
| `qa → HU-01-main` | QA aprobó. Se prepara la rama para subir a producción. |
| `HU-01-main → main` | Se sube a producción. |

---

## Justificación técnica

- **Aislamiento por tarea:** cada historia de usuario vive en su propia rama. Si `HU-01` tiene un error, no afecta el trabajo de `HU-02` ni el ambiente de producción.

- **Progresión controlada:** un cambio solo avanza al siguiente ambiente cuando fue revisado y aprobado en el anterior. No se puede saltar de `dev` a producción.

- **Trazabilidad:** al ver el historial de Git, se puede reconstruir exactamente cuándo y cómo cada cambio llegó a producción.

- **`develop` como zona de integración:** antes de ir a QA, todos los cambios del equipo se integran aquí. Si hay conflictos entre tareas, se resuelven en `develop`, no en producción.

- **`main` siempre estable:** la rama `main` solo recibe cambios que ya pasaron por `dev` y `qa`. En cualquier momento, `main` representa el estado actual de producción.

---

## Diagrama del flujo

```
main ──────────────────────────────────────────► producción estable
  │                                          ▲
  ├─► develop ──────────────────────────┐   │
  │      └─► HU-01-dev ──► develop ──┘  │   │
  │                                     ▼   │
  ├─► qa ──────────────────────────────────┐│
  │      └─► HU-01-qa ──► qa ──────────┘  ││
  │                                        ││
  └─► HU-01-main ◄──── qa ────────────────┘│
           └──────────────────────────────► main
```

---

## Consecuencias e impacto esperado

✅ El equipo siempre sabe en qué estado está cada tarea mirando las ramas.

✅ Los errores se detectan en `dev` o `qa` antes de llegar a producción.

✅ Se puede trabajar en varias historias de usuario al mismo tiempo sin que se mezclen.

⚠️ Requiere disciplina: no hacer commits directos en `main` ni en `qa`. Todo debe seguir el ciclo.

⚠️ Si el equipo es muy pequeño (1-2 personas), este flujo puede sentirse pesado al inicio. Con la práctica se vuelve natural.
