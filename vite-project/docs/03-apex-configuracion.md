# 03 - Configuracion de APEX (Application Processes)

Este documento explica paso a paso como crear los **Application Processes** en Oracle APEX Builder que el frontend React necesita para funcionar en modo produccion.

---

## Que es un Application Process?

Un Application Process es un bloque PL/SQL que APEX puede ejecutar en respuesta a una solicitud HTTP. Cuando el frontend hace:

```
POST /apex/wwv_flow.ajax
  p_request = APPLICATION_PROCESS=DASH_KPIS
```

APEX busca el proceso llamado `DASH_KPIS` en la aplicacion y lo ejecuta. El proceso escribe JSON en la respuesta usando `APEX_JSON`.

Son como mini-endpoints REST, pero dentro del motor APEX.

---

## Prerequisitos

1. Tener ejecutados los scripts SQL:
   - `sql/01_tables.sql`
   - `sql/02_views_package.sql`
   - `sql/07_crud_clientes.sql`
2. Tener acceso a APEX Builder con una aplicacion creada.
3. La aplicacion debe estar en el mismo esquema donde estan las tablas.

---

## Como crear cada proceso (pasos generales)

Repetir estos pasos para **cada uno de los 10 procesos** listados mas abajo.

### Paso 1 — Ir a Shared Components

En APEX Builder, en tu aplicacion:

```
App Builder  →  Tu Aplicacion  →  Shared Components
```

### Paso 2 — Ir a Application Processes

En la seccion "Logic":

```
Shared Components  →  Application Processes  →  Create
```

### Paso 3 — Completar el formulario

| Campo | Valor a ingresar |
|-------|-----------------|
| **Name** | El nombre exacto (ver tabla abajo, ejemplo: `DASH_KPIS`) |
| **Sequence** | Cualquier numero (ej. 10, 20, 30...) |
| **Point** | `On Demand - Run this application process when requested by page` |
| **Type** | `PL/SQL Anonymous Block` |
| **Source** | El codigo PL/SQL que aparece en la seccion del proceso |

### Paso 4 — Guardar y probar

Click en **Create Process** y luego puedes probarlo desde el frontend.

---

## Procesos del Dashboard (6 procesos)

Estos procesos proveen los datos de lectura del dashboard. Todos tienen la misma estructura: abrir un cursor y escribirlo como JSON.

### DASH_KPIS

Devuelve un objeto con 8 metricas globales.

```sql
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_kpis(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

Respuesta esperada:
```json
{
  "data": [{
    "INGRESOS_TOTAL": 450000,
    "INGRESOS_MES": 38500,
    "NUM_VENTAS": 215,
    "VENTAS_HOY": 3,
    "NUM_CLIENTES": 8,
    "NUM_PRODUCTOS": 10,
    "TICKET_PROMEDIO": 2093.02,
    "VENTAS_PENDIENTES": 12
  }]
}
```

### DASH_VENTAS_MENSUALES

Serie mensual de ingresos para los ultimos 12 meses.

```sql
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_ventas_mensuales(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

### DASH_TOP_PRODUCTOS

Top N productos por ingresos. Recibe el limite via `x01`.

```sql
DECLARE
  l_cur   SYS_REFCURSOR;
  l_limit NUMBER := NVL(TO_NUMBER(APEX_APPLICATION.G_X01), 5);
BEGIN
  pkg_dashboard.p_top_productos(l_limit, l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

> `APEX_APPLICATION.G_X01` contiene el valor del parametro `x01` que el frontend envia. Si no lo envia, el default es 5.

### DASH_VENTAS_CATEGORIA

Ingresos por categoria de producto.

```sql
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_ventas_categoria(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

### DASH_VENTAS_REGION

Ingresos agrupados por region del vendedor.

```sql
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_ventas_region(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

### DASH_ULTIMAS_VENTAS

Las N ventas mas recientes. Recibe el limite via `x01`.

```sql
DECLARE
  l_cur   SYS_REFCURSOR;
  l_limit NUMBER := NVL(TO_NUMBER(APEX_APPLICATION.G_X01), 10);
BEGIN
  pkg_dashboard.p_ultimas_ventas(l_limit, l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

---

## Procesos de Clientes CRUD (4 procesos)

Estos procesos manejan las operaciones de escritura de la tabla CLIENTES.

### CLIENTES_LIST

Devuelve todos los clientes ordenados por nombre.

```sql
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_clientes.p_list(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
```

### CLIENTES_CREATE

Inserta un nuevo cliente. Los campos vienen en `x01` a `x04`.

```sql
DECLARE
  l_id NUMBER;
BEGIN
  pkg_clientes.p_create(
    p_nombre => APEX_APPLICATION.G_X01,  -- nombre
    p_email  => APEX_APPLICATION.G_X02,  -- email
    p_ciudad => APEX_APPLICATION.G_X03,  -- ciudad
    p_pais   => APEX_APPLICATION.G_X04,  -- pais
    p_id     => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id',      l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
```

### CLIENTES_UPDATE

Actualiza un cliente existente. El ID va en `x01`, los campos en `x02` a `x05`.

```sql
BEGIN
  pkg_clientes.p_update(
    p_id     => TO_NUMBER(APEX_APPLICATION.G_X01),  -- id
    p_nombre => APEX_APPLICATION.G_X02,              -- nombre
    p_email  => APEX_APPLICATION.G_X03,              -- email
    p_ciudad => APEX_APPLICATION.G_X04,              -- ciudad
    p_pais   => APEX_APPLICATION.G_X05               -- pais
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
```

### CLIENTES_DELETE

Elimina un cliente. El ID va en `x01`.

```sql
BEGIN
  pkg_clientes.p_delete(TO_NUMBER(APEX_APPLICATION.G_X01));
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
```

---

## Resumen: los 10 procesos a crear

| Nombre | Parametros recibidos | Para que sirve |
|--------|----------------------|----------------|
| `DASH_KPIS` | ninguno | KPIs del dashboard |
| `DASH_VENTAS_MENSUALES` | ninguno | Serie mensual de ventas |
| `DASH_TOP_PRODUCTOS` | x01=limit (default 5) | Top productos por ingresos |
| `DASH_VENTAS_CATEGORIA` | ninguno | Ventas por categoria |
| `DASH_VENTAS_REGION` | ninguno | Ventas por region |
| `DASH_ULTIMAS_VENTAS` | x01=limit (default 10) | Ultimas N ventas |
| `CLIENTES_LIST` | ninguno | Lista todos los clientes |
| `CLIENTES_CREATE` | x01=nombre, x02=email, x03=ciudad, x04=pais | Crea un cliente |
| `CLIENTES_UPDATE` | x01=id, x02=nombre, x03=email, x04=ciudad, x05=pais | Actualiza cliente |
| `CLIENTES_DELETE` | x01=id | Elimina cliente |

---

## Como el frontend envia los parametros

El archivo `apexClient.js` construye el cuerpo del POST:

```js
// Para DASH_TOP_PRODUCTOS con limit=5:
const body = new URLSearchParams({
  p_request:      'APPLICATION_PROCESS=DASH_TOP_PRODUCTOS',
  p_flow_id:      appId,      // ID de la app APEX
  p_flow_step_id: pageId,     // ID de la pagina actual
  p_instance:     session,    // ID de sesion APEX
  x01:            '5',        // parametro extra
})

fetch('/apex/wwv_flow.ajax', {
  method:  'POST',
  body,
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
})
```

Los valores de `p_flow_id`, `p_flow_step_id` y `p_instance` se obtienen del objeto `window.apex.env` que APEX inyecta automaticamente en la pagina, o de campos ocultos del DOM.

---

## Verificar que funciona

Desde la consola del navegador (cuando la app React esta cargada dentro de APEX):

```js
// Verificar que APEX esta disponible:
console.log(window.apex?.env)
// Debe mostrar { APP_ID: "100", APP_PAGE_ID: "1", APP_SESSION: "..." }

// Hacer una llamada manual:
fetch('/apex/wwv_flow.ajax', {
  method: 'POST',
  body: new URLSearchParams({
    p_request: 'APPLICATION_PROCESS=DASH_KPIS',
    p_flow_id: apex.env.APP_ID,
    p_flow_step_id: apex.env.APP_PAGE_ID,
    p_instance: apex.env.APP_SESSION
  }),
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  credentials: 'include'
}).then(r => r.json()).then(console.log)
```

Si el proceso esta bien configurado, debe responder con el JSON de los KPIs.
