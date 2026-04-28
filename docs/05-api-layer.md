# 05 - Capa de API (api/)

La carpeta `vite-project/src/api/` contiene toda la logica de comunicacion entre el frontend y el servidor. Esta separacion es una buena practica: los componentes solo llaman funciones, sin saber como se hace la peticion HTTP.

```
api/
├── utils.js        — APEX_MODE, toLower(), unwrap()
├── apexClient.js   — Cliente para APEX On-Demand Processes
├── dashboardApi.js — API del dashboard (elige ORDS o APEX)
└── clientesApi.js  — API de clientes CRUD (elige ORDS o APEX)
```

---

## `utils.js`

Las tres exportaciones mas importantes del proyecto.

### `APEX_MODE`

```js
export const APEX_MODE = String(import.meta.env.VITE_APEX_MODE) === 'true'
```

Es una constante booleana calculada en tiempo de build a partir de la variable de entorno `VITE_APEX_MODE`.

- `APEX_MODE = true` → el codigo usa `apexClient` (POST a wwv_flow.ajax)
- `APEX_MODE = false` → el codigo usa `axios` (GET a ORDS endpoints)

Se evalua una sola vez cuando la app carga. No cambia en runtime.

> Por que `String(...)` en vez de solo comparar? Porque las variables de entorno de Vite siempre son strings. Si alguien pone `VITE_APEX_MODE=true` en el .env, el valor llega como `"true"` (string), no como `true` (booleano).

### `toLower(val)`

```js
export const toLower = (val) => {
  if (Array.isArray(val)) return val.map(toLower)
  if (val !== null && typeof val === 'object') {
    return Object.fromEntries(
      Object.entries(val).map(([k, v]) => [k.toLowerCase(), toLower(v)])
    )
  }
  return val
}
```

Convierte **recursivamente** todas las claves de un objeto a minusculas. Funciona con objetos anidados y arrays de objetos.

**Ejemplo:**
```js
toLower({ INGRESOS_TOTAL: 450000, VENTAS: [{ ID: 1 }] })
// → { ingresos_total: 450000, ventas: [{ id: 1 }] }
```

**Por que es necesario?**
Oracle devuelve nombres de columna en MAYUSCULAS por defecto. Sin esta funcion, el componente tendria que escribir `k.INGRESOS_TOTAL` en vez de `k.ingresos_total`, lo cual es incomodo y puede variar entre versiones de ORDS.

### `unwrap(payload)`

```js
export const unwrap = (payload) => {
  if (!payload) return null
  const p = toLower(payload)
  if (Array.isArray(p))       return p
  if (Array.isArray(p.data))  return p.data
  if (Array.isArray(p.items)) return p.items
  if (Array.isArray(p.rows))  return p.rows
  return p
}
```

Extrae el array de datos del payload, sin importar como lo envuelva el servidor.

| Payload recibido | Lo que devuelve `unwrap` |
|-----------------|--------------------------|
| `[{...}, {...}]` | `[{...}, {...}]` — ya es un array |
| `{ "data": [{...}] }` | `[{...}]` — extrae `data` |
| `{ "items": [{...}] }` | `[{...}]` — extrae `items` (formato ORDS) |
| `{ "rows": [{...}] }` | `[{...}]` — extrae `rows` |
| `{ "kpi": 42 }` | `{ "kpi": 42 }` — objeto plano, lo devuelve tal cual |

---

## `apexClient.js`

Unico archivo que sabe como hablar con el motor APEX.

### `getApexEnv()`

```js
const getApexEnv = () => {
  const env = window.apex?.env || {}

  const appId = String(env.APP_ID || '')
             || document.querySelector('[name="p_flow_id"]')?.value
             || ''
  // ... similar para pageId y session
  return { appId, pageId, session }
}
```

Lee tres valores que APEX inyecta en la pagina:
- `APP_ID` — ID de la aplicacion APEX (ej. `100`)
- `APP_PAGE_ID` — ID de la pagina actual (ej. `1`)
- `APP_SESSION` — ID de sesion del usuario (token de autenticacion)

Primero intenta `window.apex.env` (objeto JS que APEX expone). Si no esta disponible, busca los campos ocultos del DOM que APEX siempre incluye. Esta doble estrategia garantiza compatibilidad con APEX 20.1 y versiones posteriores.

### `callProcess(processName, extras)`

```js
const callProcess = async (processName, extras = {}) => {
  const { appId, pageId, session } = getApexEnv()

  const body = new URLSearchParams({
    p_request:      `APPLICATION_PROCESS=${processName}`,
    p_flow_id:      appId,
    p_flow_step_id: pageId,
    p_instance:     session,
  })

  // Agregar parametros extras (x01, x02, etc.)
  Object.entries(extras).forEach(([k, v]) => {
    if (v !== undefined && v !== null) body.append(k, String(v))
  })

  const res = await fetch('/apex/wwv_flow.ajax', {
    method:      'POST',
    body,
    credentials: 'include',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':       'application/json',
    },
  })

  if (!res.ok) throw new Error(`APEX process ${processName} HTTP ${res.status}`)
  return JSON.parse(await res.text())
}
```

Es la funcion central del cliente APEX. Hace el POST a `wwv_flow.ajax` con los parametros correctos y devuelve el JSON parseado.

**`credentials: 'include'`** es importante: envia las cookies de sesion APEX en la peticion. Sin esto, APEX rechazaria la llamada por no estar autenticado.

### APIs exportadas

```js
export const apexDashboardApi = {
  kpis:            ()           => callProcess('DASH_KPIS'),
  ventasMensuales: ()           => callProcess('DASH_VENTAS_MENSUALES'),
  topProductos:    (limit = 5)  => callProcess('DASH_TOP_PRODUCTOS', { x01: limit }),
  ventasCategoria: ()           => callProcess('DASH_VENTAS_CATEGORIA'),
  ventasRegion:    ()           => callProcess('DASH_VENTAS_REGION'),
  ultimasVentas:   (limit = 10) => callProcess('DASH_ULTIMAS_VENTAS', { x01: limit }),
}

export const apexClientesApi = {
  list:   ()     => callProcess('CLIENTES_LIST'),
  create: (data) => callProcess('CLIENTES_CREATE', {
    x01: data.nombre, x02: data.email, x03: data.ciudad, x04: data.pais,
  }),
  update: (data) => callProcess('CLIENTES_UPDATE', {
    x01: data.id, x02: data.nombre, x03: data.email, x04: data.ciudad, x05: data.pais,
  }),
  delete: (id) => callProcess('CLIENTES_DELETE', { x01: id }),
}
```

Cada funcion devuelve una Promesa con el JSON crudo del servidor.

---

## `dashboardApi.js`

Exporta un objeto `dashboardApi` con los mismos metodos independientemente del modo.

```js
export const dashboardApi = APEX_MODE
  ? {
      // En modo APEX: llama a apexClient y normaliza con unwrap
      kpis: () => apexGet(apexDashboardApi.kpis),
      // ...
    }
  : {
      // En modo ORDS: llama a axios y normaliza con unwrap
      kpis: () => ordsGet('/kpis'),
      // ...
    }
```

**Funcion `ordsGet(path, params)`:**
```js
const ordsGet = async (path, params) => {
  try {
    const { data } = await http.get(`/dashboard${path}`, { params })
    return unwrap(data)
  } catch (err) {
    console.warn(`[dashboardApi] Error en ${path}:`, err.message)
    throw err   // re-lanza para que Dashboard.jsx lo maneje
  }
}
```

Usa axios con `baseURL` apuntando a `/api` (en desarrollo) o a `VITE_ORDS_BASE` (en produccion sin APEX).

**Funcion `apexGet(apexFn)`:**
```js
const apexGet = async (apexFn) => {
  try {
    const data = await apexFn()
    return unwrap(data)
  } catch (err) {
    console.warn('[dashboardApi] Error en proceso APEX:', err.message)
    throw err
  }
}
```

Llama a la funcion APEX y normaliza con `unwrap`.

**Resultado:** los componentes (como `Dashboard.jsx`) siempre reciben un array normalizado, sin importar el modo. No necesitan saber si los datos vienen de ORDS o de APEX.

---

## `clientesApi.js`

Mismo patron que `dashboardApi.js`, pero para el CRUD de clientes.

```js
export const clientesApi = APEX_MODE
  ? {
      list:   () => apexClientesApi.list().then(fromApex),
      create: (data) => apexClientesApi.create(data).then(toLower),
      update: (data) => apexClientesApi.update(data).then(toLower),
      delete: (id)   => apexClientesApi.delete(id).then(toLower),
    }
  : {
      // Modo desarrollo sin APEX: retorna arrays vacios (no conecta a ORDS para CRUD)
      list:   () => Promise.resolve([]),
      create: () => Promise.resolve({}),
      update: () => Promise.resolve({}),
      delete: () => Promise.resolve({}),
    }
```

> En `APEX_MODE=false`, las operaciones CRUD devuelven datos vacios. Para el dashboard esto no es problema porque los datos de lectura si van a ORDS. Si necesitas probar el CRUD sin APEX, tendrias que agregar endpoints ORDS para los clientes.

---

## Como fluye una llamada completa (ejemplo: crear cliente)

```
ClientesCrud.jsx
  handleSave({ nombre: 'Acme', email: 'info@acme.com', ciudad: 'CDMX', pais: 'MX' })
    |
    v
clientesApi.create(data)
    |
    v  [APEX_MODE=true]
apexClientesApi.create(data)
    |
    v
callProcess('CLIENTES_CREATE', { x01: 'Acme', x02: 'info@acme.com', x03: 'CDMX', x04: 'MX' })
    |
    v
POST /apex/wwv_flow.ajax
  p_request=APPLICATION_PROCESS=CLIENTES_CREATE
  x01=Acme
  x02=info@acme.com
  x03=CDMX
  x04=MX
    |
    v
APEX ejecuta CLIENTES_CREATE -> pkg_clientes.p_create(...)
    |
    v
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES (...)
RETURNING id INTO l_id
    |
    v
APEX_JSON: { "id": 9, "success": true }
    |
    v
toLower({ id: 9, success: true })
    |
    v
ClientesCrud.jsx: closeModal() + load()  -> recarga la lista
```
