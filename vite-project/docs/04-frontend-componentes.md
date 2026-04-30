# 04 - Frontend: Componentes React

La aplicacion React esta en `vite-project/src/`. Esta seccion explica cada archivo y componente.

---

## Punto de entrada

### `main.jsx`

Monta la app React en el elemento `#root` del HTML. No tiene logica propia.

```jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
```

### `App.jsx`

Componente raiz. Maneja la navegacion entre las dos vistas principales con un `useState`.

```
App
├── <aside>  — Barra lateral con botones de navegacion
└── <main>
    ├── <Dashboard />    — si view === 'dashboard'
    └── <ClientesCrud /> — si view === 'clientes'
```

**Estado:**
- `view` — string: `'dashboard'` o `'clientes'`

**No usa React Router.** La navegacion es simple y local; no hay rutas en la URL.

---

## Pagina: Dashboard

### `components/Dashboard.jsx`

Orquesta todas las llamadas de datos del dashboard y renderiza los subcomponentes.

**Estado interno:**
```js
data = {
  kpis:       null,    // objeto con 8 metricas
  mensual:    [],      // array de { periodo, etiqueta, total_ventas, ... }
  productos:  [],      // array de { nombre, ingresos, ... }
  categorias: [],      // array de { categoria, ingresos, ... }
  regiones:   [],      // array de { region, ingresos, ... }
  ventas:     [],      // array de ultimas ventas
}
loading = true         // muestra skeletons mientras carga
error   = null         // muestra banner de error si falla
updatedAt = null       // hora de la ultima actualizacion
```

**Funcion `load()`:**
- Llama a las 6 funciones de `dashboardApi` en **paralelo** con `Promise.all`.
- Si todas tienen exito, actualiza `data` y `updatedAt`.
- Si alguna falla, muestra el mensaje de error en el banner rojo.

**Estructura del JSX:**
```
Dashboard
├── <header>  — Titulo, modo (APEX live / ORDS live), boton Refrescar
├── {error}   — Banner rojo si hay error
├── <section .kpi-grid>  — 6 KpiCard
├── <section .grid-2>    — VentasMensualesChart + CategoriasDonut
├── <section .grid-2>    — TopProductosChart + RegionBarChart
└── <ChartCard>          — UltimasVentasTable
```

---

## Pagina: Clientes CRUD

### `components/ClientesCrud.jsx`

Lista todos los clientes y permite crear, editar y eliminar.

**Estado interno:**
```js
clientes = []          // array de clientes del servidor
loading  = true        // muestra skeletons
error    = null        // banner de error
modal    = { open: false, data: null }  // controla el modal
deleting = null        // ID del cliente que se esta eliminando
```

**Flujo de crear un cliente:**
1. Usuario hace click en "+ Nuevo Cliente".
2. `openCreate()` pone `modal = { open: true, data: null }`.
3. Se renderiza `<ClienteModal data={null} />` (formulario vacio).
4. Usuario llena el formulario y hace click en "Crear".
5. `handleSave(formData)` detecta que `formData.id` no existe → llama `clientesApi.create(formData)`.
6. Al completar: cierra el modal y recarga la lista.

**Flujo de editar un cliente:**
1. Usuario hace click en "Editar" en una fila.
2. `openEdit(cliente)` pone `modal = { open: true, data: cliente }`.
3. Se renderiza `<ClienteModal data={cliente} />` (formulario pre-llenado).
4. Usuario modifica y hace click en "Actualizar".
5. `handleSave(formData)` detecta que `formData.id` existe → llama `clientesApi.update(formData)`.

**Flujo de eliminar un cliente:**
1. Usuario hace click en "Eliminar".
2. Se muestra `window.confirm(...)` — si el usuario cancela, no pasa nada.
3. Si confirma, se llama `clientesApi.delete(id)` y se recarga la lista.
4. Mientras se elimina, el boton muestra `...` y esta deshabilitado.

### `components/ClienteModal.jsx`

Modal con formulario para crear o editar un cliente.

**Props:**
| Prop | Tipo | Descripcion |
|------|------|-------------|
| `data` | objeto o null | Si es null: modo "crear". Si tiene datos: modo "editar" |
| `onSave` | funcion | Se llama con el objeto del formulario al hacer submit |
| `onClose` | funcion | Se llama al cancelar o cerrar el modal |

**Estado interno:**
```js
form   = { nombre: '', email: '', ciudad: '', pais: 'MX' }
saving = false  // deshabilita el boton mientras guarda
error  = null   // error de la operacion de guardado
```

**Comportamiento:**
- El `useEffect` sincroniza `form` con la prop `data` cada vez que cambia. Esto es para que al abrir "Editar", el formulario muestre los datos actuales.
- El campo `nombre` es obligatorio (`required` en el input). El navegador lo valida.
- El modal se cierra al hacer click en el overlay exterior (gracias a `onClick={onClose}` en el div del overlay). El `e.stopPropagation()` en el div interior evita que el click dentro del modal lo cierre.

---

## Componentes reutilizables

### `components/KpiCard.jsx`

Tarjeta que muestra un KPI individual.

**Props:**
| Prop | Tipo | Descripcion |
|------|------|-------------|
| `title` | string | Nombre del KPI, ej. "Ingresos totales" |
| `value` | string | Valor formateado, ej. "$450,000" |
| `hint` | string | Texto secundario pequeño |
| `icon` | string | Caracter decorativo ($, #, @, etc.) |
| `accent` | string | Color: 'indigo', 'cyan', 'emerald', 'amber', 'violet', 'rose' |
| `loading` | boolean | Si es true, muestra un skeleton en lugar del valor |

**Colores disponibles** (definidos en `App.css`):
- `indigo` → Ingresos totales
- `cyan` → Ingresos del mes
- `emerald` → Ventas totales
- `amber` → Ticket promedio
- `violet` → Clientes
- `rose` → Productos

### `components/ChartCard.jsx`

Contenedor con cabecera para envolver cualquier grafico o tabla.

**Props:**
| Prop | Tipo | Descripcion |
|------|------|-------------|
| `title` | string | Titulo del grafico |
| `subtitle` | string | Subtitulo (opcional) |
| `action` | JSX | Elemento adicional en la cabecera (ej. un boton) |
| `children` | JSX | El grafico en si |
| `height` | number o 'auto' | Altura del area del grafico en px |
| `loading` | boolean | Si es true, muestra un skeleton rectangular |

### `components/UltimasVentasTable.jsx`

Tabla con las ultimas N ventas.

**Props:**
| Prop | Tipo | Descripcion |
|------|------|-------------|
| `data` | array | Array de objetos venta |
| `loading` | boolean | Muestra skeleton rows si es true |

Cada fila de la tabla muestra: ID, fecha, cliente, vendedor, region, total (formateado), estado (con badge de color).

Los badges de estado usan CSS:
- `PAGADA` → `badge-green`
- `PENDIENTE` → `badge-amber`
- `CANCELADA` → `badge-red`

---

## Graficos (Recharts)

Todos los graficos viven en `components/charts/` y reciben `data` como prop. Usan `ResponsiveContainer` de Recharts para adaptarse al contenedor padre.

### `VentasMensualesChart.jsx`

Grafico de area (AreaChart). Muestra la evolucion de ingresos mes a mes.

- Eje X: `etiqueta` (ej. "Abr 25")
- Eje Y: `total_ventas` formateado en modo compacto ($450k)
- Gradiente azul-violeta que se desvanece hacia abajo.

### `TopProductosChart.jsx`

Barras horizontales (BarChart con `layout="vertical"`). Muestra los 5 productos con mas ingresos.

- Eje Y: nombre del producto
- Eje X: ingresos formateados

### `CategoriasDonut.jsx`

Grafico de dona (PieChart con `innerRadius`). Muestra la participacion de cada categoria.

- Cada sector tiene un color diferente.
- Al pasar el mouse, muestra el nombre y el total.

### `RegionBarChart.jsx`

Barras verticales (BarChart). Muestra los ingresos por region del equipo comercial.

- Eje X: nombre de la region
- Eje Y: ingresos

---

## Utilidades

### `utils/format.js`

Funciones de formateo de numeros con el locale `es-MX`.

| Funcion | Entrada | Salida ejemplo |
|---------|---------|----------------|
| `fmtCurrency(n)` | 450000 | `$450,000` |
| `fmtCompact(n)` | 450000 | `450k` |
| `fmtInt(n)` | 2150 | `2,150` |
| `fmtCompactCurrency(n)` | 450000 | `$450k` |

Todas las funciones manejan `null`, `undefined` y strings numericos: devuelven `$0` o `0` si el valor no es un numero valido.

---

## Estilos

Los estilos estan en dos archivos CSS globales:

- `index.css` — Estilos base, variables CSS (colores del tema dark), reset
- `App.css` — Estilos de los componentes (clases: `.kpi-card`, `.chart-card`, `.modal`, `.ventas-table`, etc.)

No se usa ninguna libreria de UI (Bootstrap, Material UI, Tailwind). Todo es CSS vanilla con variables CSS.

Variables CSS principales (definidas en `:root`):
```css
--bg-base:    #0f172a  /* fondo principal, azul muy oscuro */
--bg-surface: #1e293b  /* fondo de cards */
--text:       #e2e8f0  /* texto principal */
--text-mute:  #94a3b8  /* texto secundario */
--border:     #1f2937  /* bordes */
--indigo:     #6366f1  /* color principal de accent */
```
