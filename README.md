# Prueba APEX + React + ORDS

Ejercicio practico end-to-end del flujo:

```
Usuario  ->  APEX (host de la app)
             |
             v
        React (Vite)  -- HTTP/JSON -->  ORDS  --> PL/SQL --> Oracle (tablas)
                                                      |
                                                      v
                                                JSON al cliente
```

## Que incluye

| Capa | Donde | Descripcion |
|------|-------|-------------|
| Tablas + datos demo | `sql/01_tables.sql` | 5 tablas (CLIENTES, VENDEDORES, PRODUCTOS, VENTAS, DETALLE_VENTAS) y 250 ventas generadas |
| Vistas + paquete | `sql/02_views_package.sql` | Vistas analiticas y `PKG_DASHBOARD` con 6 procedimientos `SYS_REFCURSOR` |
| API REST (sin seguridad) | `sql/03_ords.sql` | Modulo ORDS `dashboard.api` con 6 endpoints |
| Frontend | `vite-project/` | Dashboard React con KPIs y graficos (recharts) |

## 1. Backend Oracle / ORDS

> Ejecutar conectado al esquema APEX donde correra la app (ej. `WKSP_VENTAS`).

```sql
@sql/01_tables.sql
@sql/02_views_package.sql
-- Solo si el esquema aun no esta publicado en ORDS:
BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => USER,
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'ventas',
    p_auto_rest_auth      => FALSE);
  COMMIT;
END;
/
@sql/03_ords.sql
```

### Endpoints publicados

Base: `http://<host>:<puerto>/ords/ventas/dashboard/`

| Metodo | Path                       | Descripcion |
|--------|----------------------------|-------------|
| GET    | `kpis`                     | KPIs globales (un objeto) |
| GET    | `ventas-mensuales`         | Serie mensual ultimos 12 meses |
| GET    | `top-productos?limit=5`    | Top productos por ingresos |
| GET    | `ventas-categoria`         | Ingresos por categoria |
| GET    | `ventas-region`            | Ingresos por region comercial |
| GET    | `ultimas-ventas?limit=10`  | Ultimas N ventas |

Todos devuelven `{ "data": [ ... ] }`. Se usa `APEX_JSON.WRITE` sobre `SYS_REFCURSOR`.

Prueba rapida:

```bash
curl http://localhost:8080/ords/ventas/dashboard/kpis
```

## 2. Frontend React

```bash
cd vite-project
npm install        # ya hecho si clonaste con node_modules
npm run dev        # http://localhost:5173
npm run build      # bundle de produccion en dist/
```

### Variables de entorno (`vite-project/.env`)

```
VITE_ORDS_BASE=http://localhost:8080/ords/ventas
VITE_USE_MOCKS=true
```

- `VITE_USE_MOCKS=true` -> el frontend usa datos mock locales (puedes ver el dashboard sin Oracle).
- `VITE_USE_MOCKS=false` -> llama a ORDS via el proxy de Vite (`/api` -> `VITE_ORDS_BASE`).

> En produccion (cuando se hostea desde APEX o detras de un reverse proxy), exponer ORDS bajo el mismo origen en `/api/dashboard/*` evita CORS sin tocar el codigo.

### Estructura

```
vite-project/src/
  api/client.js              <- axios + fallback a mocks
  mocks/dashboardMocks.js    <- datos demo con la misma forma que ORDS
  utils/format.js            <- formatos de moneda/numero
  components/
    Dashboard.jsx            <- pagina principal
    KpiCard.jsx
    ChartCard.jsx
    UltimasVentasTable.jsx
    charts/
      VentasMensualesChart.jsx   (Area chart)
      TopProductosChart.jsx      (Bar horizontal)
      CategoriasDonut.jsx        (Donut)
      RegionBarChart.jsx         (Bar vertical)
  App.jsx, App.css, index.css, main.jsx
```

## 3. Hostear dentro de APEX

Una vez hecho `npm run build`, copiar el contenido de `dist/` a los Static Application Files (o Static Workspace Files) y referenciar `index.html` desde una pagina APEX usando una region tipo "URL" o un iframe que apunte al recurso estatico. La app React seguira hablando con ORDS via `VITE_ORDS_BASE` o un path relativo (`/ords/ventas/...`).

## 4. Estado actual del demo

- `VITE_USE_MOCKS=true` por defecto -> el dashboard se ve y funciona sin backend.
- Cambia a `false` cuando ORDS este publicado para conectar al Oracle real.
- Si ORDS responde error o no esta disponible, el cliente cae automaticamente a los mocks (con warning en consola).
