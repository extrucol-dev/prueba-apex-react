# Handoff: Mock Fixes y Siguiente Fase CRM

## Resumen de cambios aplicados

### 1. Fix: oportunidad estado tipos (CERRADO)

**Archivo:** `src/features/oportunidades/api.js`

**Problema:** Los estados de oportunidad usaban `tipo: "ACTIVO"` pero el ERD CRM define los tipos como `ABIERTO | CERRADO_GANADO | CERRADO_PERDIDO`.

**Cambio aplicado:**
```javascript
// ANTES (INCORRECTO):
{ id_estado_oportunidad: 1, nombre: "Prospecto", tipo: "ACTIVO" },
{ id_estado_oportunidad: 2, nombre: "Calificación", tipo: "ACTIVO" },
{ id_estado_oportunidad: 3, nombre: "Propuesta", tipo: "ACTIVO" },
{ id_estado_oportunidad: 4, nombre: "Negociación", tipo: "ACTIVO" },

// DESPUES (CORRECTO):
{ id_estado_oportunidad: 1, nombre: "Prospecto", tipo: "ABIERTO" },
{ id_estado_oportunidad: 2, nombre: "Calificación", tipo: "ABIERTO" },
{ id_estado_oportunidad: 3, nombre: "Propuesta", tipo: "ABIERTO" },
{ id_estado_oportunidad: 4, nombre: "Negociación", tipo: "ABIERTO" },
```

---

### 2. Fix: OPP_CREATE - Campo descripcion faltante

**Archivo:** `src/features/oportunidades/api.js`

**Problema:** La funcion `crear` de oportunidades no enviaba el campo `descripcion` al proceso APEX `OPP_CREATE`.

**Cambio aplicado:**
```javascript
// ANTES:
callProcess("OPP_CREATE", {
  x01: data.titulo,
  x02: data.id_tipo_oportunidad,
  x03: data.id_estado_oportunidad ?? 1,
  x04: data.valor_estimado,
  x05: data.probabilidad_cierre ?? 50,
  x06: data.id_sector,
  x07: data.id_empresa,
  x08: data.fecha_cierre_estimada,
  x09: data.id_usuario,
})

// DESPUES:
callProcess("OPP_CREATE", {
  x01: data.titulo,
  x02: data.descripcion,          // <-- AGREGADO
  x03: data.id_tipo_oportunidad,
  x04: data.id_estado_oportunidad ?? 1,
  x05: data.valor_estimado,
  x06: data.probabilidad_cierre ?? 50,
  x07: data.id_sector,
  x08: data.id_empresa,
  x09: data.fecha_cierre_estimada,
  x10: data.id_usuario,
})
```

---

## Estado actual de los mocks

### Leads (`src/features/leads/api.js`)

| Campo | Estado | Notas |
|-------|--------|-------|
| `leads[].id_estado_lead` | OK | 1-4 corresponde a catalogos |
| `leads[].estado_nombre` | OK | "Nuevo", "Contactado", etc. |
| `catalogos.estados[].tipo` | OK | ABIERTO/CALIFICADO/DESCALIFICADO segun ER |
| `leads[].descripcion` | OK | Presente en mock |
| `leads[].fecha_creacion` | OK | Presente en mock |
| `leads[].id_origen_lead` | OK | Presente en mock |

**Catalogos de leads (correctos):**
```javascript
estados: [
  { id_estado_lead: 1, nombre: 'Nuevo',         tipo: 'ABIERTO',        orden: 1, color_hex: '#3b82f6' },
  { id_estado_lead: 2, nombre: 'Contactado',    tipo: 'ABIERTO',        orden: 2, color_hex: '#f59e0b' },
  { id_estado_lead: 3, nombre: 'Calificado',    tipo: 'CALIFICADO',     orden: 3, color_hex: '#10b981' },
  { id_estado_lead: 4, nombre: 'Descalificado', tipo: 'DESCALIFICADO',  orden: 4, color_hex: '#ef4444' },
]
```

### Oportunidades (`src/features/oportunidades/api.js`)

| Campo | Estado | Notas |
|-------|--------|-------|
| `oportunidades[].id_estado_oportunidad` | OK | 1-6 corresponde a catalogos |
| `oportunidades[].estado_nombre` | OK | "Prospecto", "Calificación", etc. |
| `catalogos.estados[].tipo` | CORREGIDO | Ahora usa ABIERTO/CERRADO_GANADO/CERRADO_PERDIDO |
| `oportunidades[].titulo` | OK | Presente |
| `oportunidades[].valor_estimado` | OK | Presente |
| `crear.x02` (descripcion) | CORREGIDO | Ahora incluye data.descripcion |

**Catalogos de oportunidades (CORREGIDOS):**
```javascript
estados: [
  { id_estado_oportunidad: 1, nombre: "Prospecto",     tipo: "ABIERTO" },
  { id_estado_oportunidad: 2, nombre: "Calificación",  tipo: "ABIERTO" },
  { id_estado_oportunidad: 3, nombre: "Propuesta",    tipo: "ABIERTO" },
  { id_estado_oportunidad: 4, nombre: "Negociación",  tipo: "ABIERTO" },
  { id_estado_oportunidad: 5, nombre: "Ganada",       tipo: "CERRADO_GANADO" },
  { id_estado_oportunidad: 6, nombre: "Perdida",      tipo: "CERRADO_PERDIDO" },
]
```

---

## Pendientes de resolver

### 1. Kanban de Leads - Columna "Convertido"

El kanban de leads tiene 5 columnas pero el ER solo define 4 estados (`Nuevo`, `Contactado`, `Calificado`, `Descalificado`).

**Solucion propuesta:**
- La columna "Convertido" no es un `estado_lead` tipo, sino una vista de leads que ya tienen `id_oportunidad_generada` no nulo
- Cuando un lead se convierte a oportunidad, su `id_estado_lead` queda en `CALIFICADO` (id 3) y `id_oportunidad_generada` apunta a la oportunidad creada
- El kanban deberia mostrar 4 columnas matching con los 4 `estado_lead`, y la columna "Convertido" seria un filtro/vista de los leads con `id_oportunidad_generada IS NOT NULL`

**Archivos a modificar:** `src/features/leads/components/KanbanBoard.jsx` (o similar)

### 2. Nombre de oportunidad en catalogo: "Prospecto" vs "Prospeccion"

El catalogo usa `nombre: "Prospecto"` pero seria mas consistente `nombre: "Prospeccion"`. **Pendiente decision de negocio.**

### 3. Backend APEX: Procesos para Leads y Oportunidades

Los mocks llaman a procesos APEX como `LEADS_LIST`, `LEADS_CREATE`, `OPP_LIST`, `OPP_CREATE`, etc. **No hay documentacion ni scripts SQL** para estos procesos en el repositorio.

**Archivos relacionados:**
- `src/api/apexClient.js` - cliente que llama a los procesos
- `src/features/leads/api.js` - API de leads
- `src/features/oportunidades/api.js` - API de oportunidades

**Procesos APEX referenciados:**
```
LEADS_CATALOGOS, LEADS_LIST, LEADS_GET, LEADS_HISTORIAL, LEADS_CREATE, LEADS_UPDATE, LEADS_DESCALIFICAR, LEADS_CONVERTIR
OPP_LIST, OPP_GET, OPP_ACTIVIDADES, OPP_PRODUCTOS_CATALOGO, OPP_CREATE, OPP_UPDATE, OPP_AVANZAR_ESTADO, OPP_CERRAR_GANADA, OPP_CERRAR_PERDIDA, OPP_ESTANCADOS
```

### 4. Entidad oportunidad - Campos adicionales en actualizar

La funcion `actualizar` de oportunidades no incluye `descripcion`:
```javascript
actualizar: (id, data) =>
  callProcess("OPP_UPDATE", {
    x01: id,
    x02: data.titulo,
    x03: data.id_tipo_oportunidad,
    x04: data.id_estado_oportunidad,
    x05: data.valor_estimado,
    x06: data.probabilidad_cierre,
    x07: data.id_sector,
    x08: data.id_empresa,
    x09: data.fecha_cierre_estimada,
    // falta x10: data.descripcion
  })
```

---

## Estructura de archivos clave

```
vite-project/src/
  api/
    apexClient.js          # Cliente HTTP para procesos APEX
    utils.js               # Helpers (unwrap, unwrapOne)
  features/
    leads/
      api.js               # Mock + API para leads
      components/          # Componentes de leads
    oportunidades/
      api.js               # Mock + API para oportunidades
      components/          # Componentes de oportunidades
vite-project/sql/
  01_tables.sql           # Tablas demo (CLIENTES, VENTAS, etc - NO leads/oportunidades)
  05_apex_processes.sql   # Procesos APEX del dashboard (NO del CRM)
```

---

## Para continuar el trabajo

1. **Si hay backend APEX:** Crear los procesos APEX para `LEADS_*` y `OPP_*` siguiendo el patron en `docs/03-apex-configuracion.md` y los mapeos de parametros en `api.js`

2. **Si no hay backend APEX:** Seguir usando `USE_MOCKS=true` en `apexClient.js` y validar que los mocks coincidan con el ER

3. **Para el kanban de leads:** Implementar la columna "Convertido" como filtro/vista basada en `id_oportunidad_generada IS NOT NULL`

4. **Para probar cambios:** Ejecutar `npm run dev` y verificar en el navegador que los cambios en los mocks no rompan la UI

---

## Contacto / Contexto

Este proyecto es un CRM para una empresa de perfiles y tuberia PVC. El frontend React se conecta a Oracle APEX via Application Processes.
