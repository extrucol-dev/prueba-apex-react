# Prueba APEX + React + ORDS

Dashboard de ventas y CRUD de clientes construido con **Oracle APEX**, **React (Vite)** y **Oracle ORDS/PL/SQL**.

## Que hace este proyecto

- Muestra un dashboard con KPIs, graficos y tabla de ventas en tiempo real.
- Permite crear, editar y eliminar clientes desde una interfaz React.
- El frontend puede comunicarse con Oracle de dos formas segun el entorno:
  - **Desarrollo**: via ORDS REST endpoints (con proxy de Vite).
  - **Produccion**: via APEX On-Demand Application Processes.

## Arquitectura rapida

```
Usuario
  │
  ▼
React (Vite)                    ← UI: componentes, graficos, formularios
  │
  ├─ APEX_MODE=true  ──POST /apex/wwv_flow.ajax──►  APEX Application Process
  │
  └─ APEX_MODE=false ──GET /api/dashboard/kpis──►  ORDS REST Endpoint
                                                          │
                                                          ▼
                                                   PL/SQL Packages
                                                (pkg_dashboard, pkg_clientes)
                                                          │
                                                          ▼
                                                   Oracle DB
                                              (tablas, vistas, triggers)
```

## Estructura de carpetas

```
prueba-apex-react/
├── README.md                  ← Este archivo
├── docs/                      ← Documentacion detallada para el equipo
│   ├── 01-arquitectura.md     ← Como se conectan todas las capas
│   ├── 02-base-de-datos.md    ← Tablas, vistas y paquetes PL/SQL
│   ├── 03-apex-configuracion.md ← Como crear los procesos en APEX Builder
│   ├── 04-frontend-componentes.md ← Cada componente React explicado
│   ├── 05-api-layer.md        ← La capa de API (utils, apexClient, etc.)
│   └── 06-entorno-y-despliegue.md ← Variables de entorno y deploy a APEX
├── sql/                       ← Scripts SQL y PL/SQL (ejecutar en orden)
│   ├── 01_tables.sql          ← Tablas, secuencias, triggers y datos demo
│   ├── 02_views_package.sql   ← Vistas analiticas + pkg_dashboard
│   ├── 05_apex_processes.sql  ← Referencia PL/SQL para APEX processes
│   └── 07_crud_clientes.sql   ← pkg_clientes + referencia APEX processes
└── vite-project/              ← Aplicacion React
    ├── src/
    │   ├── api/               ← Capa de comunicacion con el servidor
    │   ├── components/        ← Componentes React (UI)
    │   └── utils/             ← Funciones de formateo de numeros
    ├── .env.development       ← Variables para desarrollo local
    ├── .env.production        ← Variables para produccion (APEX)
    └── vite.config.js         ← Configuracion de Vite + proxy anti-CORS
```

## Inicio rapido

### 1. Preparar la base de datos

Conectarse al esquema Oracle con SQL*Plus o SQL Developer y ejecutar los scripts en orden:

```sql
@sql/01_tables.sql          -- Crea tablas y carga ~250 ventas demo
@sql/02_views_package.sql   -- Crea vistas y pkg_dashboard
@sql/07_crud_clientes.sql   -- Crea pkg_clientes
```

### 2. Configurar APEX (solo para produccion)

Ver [docs/03-apex-configuracion.md](docs/03-apex-configuracion.md) para el paso a paso de como crear los 10 Application Processes en APEX Builder.

### 3. Desarrollo local

```bash
cd vite-project
npm install
cp .env.example .env.development
# Editar VITE_ORDS_BASE con la URL de tu instancia ORDS
npm run dev
# La app queda en http://localhost:5173
```

### 4. Build para produccion (embeber en APEX)

```bash
cd vite-project
npm run build
# Los archivos quedan en vite-project/dist/
```

Ver [docs/06-entorno-y-despliegue.md](docs/06-entorno-y-despliegue.md) para subir los archivos a APEX.

## Tecnologias

| Tecnologia | Version | Para que se usa |
|-----------|---------|-----------------|
| React | 19 | Interfaz de usuario |
| Vite | 8 | Bundler y servidor de desarrollo |
| Recharts | 3 | Graficos (area, donut, barras) |
| Axios | 1 | Peticiones HTTP a ORDS en desarrollo |
| Oracle APEX | 20.1+ | Hosting de la app y Application Processes |
| Oracle ORDS | cualquiera | REST API sobre la base de datos |
| PL/SQL | Oracle 11g+ | Logica de negocio en la base de datos |

## Documentacion detallada

| Documento | Contenido |
|-----------|-----------|
| [01-arquitectura.md](docs/01-arquitectura.md) | Diagrama completo de capas y flujo de datos |
| [02-base-de-datos.md](docs/02-base-de-datos.md) | Tablas, vistas, paquetes PL/SQL y datos demo |
| [03-apex-configuracion.md](docs/03-apex-configuracion.md) | Paso a paso para crear procesos en APEX Builder |
| [04-frontend-componentes.md](docs/04-frontend-componentes.md) | Cada componente React con sus props y estado |
| [05-api-layer.md](docs/05-api-layer.md) | utils.js, apexClient.js, dashboardApi.js explicados |
| [06-entorno-y-despliegue.md](docs/06-entorno-y-despliegue.md) | Variables .env, proxy Vite y checklist de despliegue |
