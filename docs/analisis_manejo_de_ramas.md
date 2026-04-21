# Análisis del Manejo de Ramas y Ambientes

## Introducción
Este documento explica el flujo de trabajo de ramas y ambientes utilizado en el repositorio, basado en un modelo de Git Flow adaptado para historias de usuario (HU). El sistema asegura separación de entornos y control de calidad en el desarrollo de base de datos.

## Ramas Padres
Las ramas principales representan los ambientes clave:

| Rama | Propósito | Ambiente |
|------|-----------|----------|
| main | Rama de producción, código estable y desplegado | Producción |
| qa | Rama de control de calidad, pruebas integradas | QA |
| develop | Rama de desarrollo, integración de features | Desarrollo |

## Ramas Hijas por Historia de Usuario
Para cada HU, se crean ramas derivadas de las ramas padres. El patrón de nomenclatura es `HU-XX-YYY`, donde XX es el número de HU y YYY indica el ambiente padre.

### Estructura Jerárquica
```
main (producción)
├── HU-01-main (feature branch para HU-01 en main)
├── qa (control de calidad)
│   └── HU-01-qa (feature branch para HU-01 en qa)
└── develop (desarrollo)
    └── HU-01-dev (feature branch para HU-01 en develop)
```

### Creación de Ramas
- De `main`: `HU-XX-main`
- De `qa`: `HU-XX-qa`
- De `develop`: `HU-XX-dev`

El número de ramas HU depende de la cantidad de historias de usuario activas en el proyecto.

## Flujo de Trabajo
El desarrollo sigue un proceso secuencial con merges manuales para asegurar calidad.

### Pasos de Desarrollo
1. **Inicio**: Trabajar en `HU-01-dev` (derivada de `develop`).
2. **Commit y Merge a Develop**: Subir cambios a `HU-01-dev`, luego merge manual a `develop`.
3. **Paso a QA**: Merge manual de `develop` a `HU-01-qa`.
4. **Pruebas en QA**: Subir cambios a `HU-01-qa`, merge a `qa`.
5. **Despliegue a Producción**: Merge manual de `qa` a `HU-01-main`.
6. **Merge Final**: Merge de `HU-01-main` a `main`.

### Diagrama de Flujo
```
HU-01-dev → develop → HU-01-qa → qa → HU-01-main → main
     ↑           ↑         ↑       ↑         ↑         ↑
  Trabajo     Integración  Pruebas  Validación  Staging  Producción
```

## Puntos Clave
- **Separación de Ambientes**: Cada rama padre representa un ambiente aislado.
- **Control de Calidad**: Merges manuales permiten revisiones antes de avanzar.
- **Escalabilidad**: Una rama HU por ambiente soporta múltiples HU concurrentes.
- **Trazabilidad**: Nomenclatura clara facilita seguimiento de cambios por HU.
- **Prevención de Conflictos**: Ramas dedicadas reducen riesgos en merges.

Este modelo asegura que los cambios en base de datos pasen por validación en desarrollo, QA y producción antes del despliegue final.