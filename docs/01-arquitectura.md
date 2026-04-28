# 01 - Arquitectura del proyecto

## Vision general

Este proyecto conecta cuatro capas tecnologicas. Cada capa tiene una responsabilidad clara:

```
┌─────────────────────────────────────────────────────────────────┐
│  NAVEGADOR DEL USUARIO                                          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  React App (Vite)                                        │   │
│  │  - Dashboard con KPIs y graficos                         │   │
│  │  - CRUD de Clientes                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│         |                          |                             │
│    APEX_MODE=true             APEX_MODE=false                    │
│         |                          |                             │
│         v                          v                             │
│  POST /apex/wwv_flow.ajax    GET /api/dashboard/kpis             │
│  (Application Processes)     (via proxy Vite -> ORDS)            │
└─────────────────────────────────────────────────────────────────┘
         |                          |
         v                          v
┌─────────────────────────────────────────────────────────────────┐
│  ORACLE APEX / ORDS                                             │
│                                                                  │
│  APEX On-Demand Processes:        ORDS REST Endpoints:           │
│  - DASH_KPIS                      - /dashboard/kpis             │
│  - DASH_VENTAS_MENSUALES          - /dashboard/ventas-mensuales │
│  - DASH_TOP_PRODUCTOS             - /dashboard/top-productos    │
│  - etc.                           - etc.                        │
└─────────────────────────────────────────────────────────────────┘
         |                          |
         └────────────┬─────────────┘
                      v
┌─────────────────────────────────────────────────────────────────┐
│  PL/SQL PACKAGES                                                │
│                                                                  │
│  pkg_dashboard          pkg_clientes                            │
│  ├── p_kpis()           ├── p_list()                            │
│  ├── p_ventas_mensuales ├── p_create()                          │
│  ├── p_top_productos    ├── p_update()                          │
│  ├── p_ventas_categoria └── p_delete()                          │
│  ├── p_ventas_region                                            │
│  └── p_ultimas_ventas                                           │
└─────────────────────────────────────────────────────────────────┘
                      |
                      v
┌─────────────────────────────────────────────────────────────────┐
│  BASE DE DATOS ORACLE                                           │
│                                                                  │
│  Tablas: CLIENTES, VENDEDORES, PRODUCTOS, VENTAS, DETALLE_VENTAS│
│  Vistas: v_ventas_mensuales, v_top_productos, etc.              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Los dos modos de operacion

La variable de entorno `VITE_APEX_MODE` controla como se comunica el frontend.

### Modo ORDS (`VITE_APEX_MODE=false`) — para desarrollo local

```
React  --GET /api/dashboard/kpis-->  Vite Proxy  --GET http://host/ords/ventas/dashboard/kpis-->  ORDS  -->  PL/SQL
```

- Se usa cuando el desarrollador trabaja en su PC y tiene ORDS disponible.
- Vite actua como proxy: las llamadas a `/api/*` se redirigen a `VITE_ORDS_BASE`.
- Evita problemas de CORS porque el navegador siempre habla con `localhost:5173`.

### Modo APEX (`VITE_APEX_MODE=true`) — para produccion dentro de APEX

```
React  --POST /apex/wwv_flow.ajax-->  APEX Engine  -->  Application Process (PL/SQL)  -->  Oracle
```

- Se usa cuando la app React ya esta desplegada dentro de Oracle APEX.
- No necesita ORDS ni proxies. APEX maneja la autenticacion por sesion.
- Los datos viajan en el mismo dominio; no hay CORS.

---

## Por que dos modos y no uno?

| Aspecto | ORDS | APEX On-Demand |
|---------|------|----------------|
| Donde funciona | En cualquier lugar con acceso HTTP a ORDS | Solo dentro de una sesion APEX activa |
| Autenticacion | Configurable (publica o con token) | Sesion APEX (automatica) |
| CORS | Requiere configuracion | No aplica (mismo dominio) |
| Ideal para | Desarrollo local, integraciones externas | Produccion embebida en APEX |

---

## Flujo de una peticion: ejemplo Dashboard KPIs

### En modo ORDS

1. `Dashboard.jsx` llama `dashboardApi.kpis()`.
2. `dashboardApi.js` detecta `APEX_MODE=false` y usa `ordsGet('/kpis')`.
3. `axios` hace `GET /api/dashboard/kpis`.
4. El proxy de Vite reescribe la URL a `http://localhost:8080/ords/ventas/dashboard/kpis`.
5. ORDS ejecuta el endpoint REST, que llama a `pkg_dashboard.p_kpis()`.
6. La DB devuelve una fila con 8 columnas (ingresos_total, num_ventas, etc.).
7. ORDS serializa como `{ "items": [ {...} ] }`.
8. La funcion `unwrap()` extrae el array interior.
9. La funcion `toLower()` convierte las claves a minusculas.
10. `Dashboard.jsx` actualiza el estado y los `KpiCard` se re-renderizan.

### En modo APEX

1. `Dashboard.jsx` llama `dashboardApi.kpis()`.
2. `dashboardApi.js` detecta `APEX_MODE=true` y usa `apexGet(apexDashboardApi.kpis)`.
3. `apexClient.js` hace `POST /apex/wwv_flow.ajax` con `p_request=APPLICATION_PROCESS=DASH_KPIS`.
4. APEX ejecuta el Application Process `DASH_KPIS` (bloque PL/SQL anonimo).
5. El bloque llama `pkg_dashboard.p_kpis()` y serializa el cursor con `APEX_JSON`.
6. La respuesta es `{ "data": [ {...} ] }`.
7. `unwrap()` y `toLower()` normalizan igual que en ORDS.
8. Mismo resultado final en el componente.

---

## Por que la normalizacion de claves?

Oracle devuelve los nombres de columna en **MAYUSCULAS** (`INGRESOS_TOTAL`).
ORDS puede cambiar esto dependiendo de la version.

La funcion `toLower()` convierte todo a **minusculas** de forma recursiva:

```js
// Entrada de ORDS/APEX:
{ "INGRESOS_TOTAL": 450000, "NUM_VENTAS": 215 }

// Despues de toLower():
{ "ingresos_total": 450000, "num_ventas": 215 }
```

Esto hace que el codigo React sea consistente sin importar la fuente de datos.

---

## Por que `unwrap()`?

ORDS y APEX no devuelven JSON identico:

| Fuente | Estructura |
|--------|-----------|
| ORDS REST | `{ "items": [ {...}, {...} ] }` |
| APEX_JSON | `{ "data": [ {...}, {...} ] }` |
| Algunos endpoints | `[ {...}, {...} ]` (array directo) |

La funcion `unwrap()` maneja los tres casos y siempre devuelve un array o un objeto plano.

---

## Archivos clave y su rol

```
vite-project/src/
├── api/
│   ├── utils.js         APEX_MODE, toLower(), unwrap() — utilidades compartidas
│   ├── apexClient.js    callProcess() — POST a wwv_flow.ajax
│   ├── dashboardApi.js  dashboardApi — elige ORDS o APEX segun APEX_MODE
│   └── clientesApi.js   clientesApi  — elige ORDS o APEX segun APEX_MODE
├── components/
│   ├── Dashboard.jsx    Orquesta todas las llamadas al dashboard
│   ├── ClientesCrud.jsx Lista de clientes + acciones
│   ├── ClienteModal.jsx Formulario crear/editar en modal
│   ├── KpiCard.jsx      Tarjeta de un KPI individual
│   ├── ChartCard.jsx    Contenedor de un grafico
│   ├── UltimasVentasTable.jsx  Tabla de ultimas ventas
│   └── charts/          Graficos con Recharts
│       ├── VentasMensualesChart.jsx  Area chart
│       ├── TopProductosChart.jsx     Barras horizontales
│       ├── CategoriasDonut.jsx       Grafico donut
│       └── RegionBarChart.jsx        Barras verticales
└── utils/
    └── format.js        fmtCurrency, fmtInt, fmtCompact — formateo de numeros
```
