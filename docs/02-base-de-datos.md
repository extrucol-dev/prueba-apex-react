# 02 - Base de datos

Todos los scripts estan en la carpeta `sql/`. Se deben ejecutar **en orden numerico** conectado al esquema de Oracle donde corre la app APEX.

---

## Orden de ejecucion

```sql
@sql/01_tables.sql          -- 1. Tablas, secuencias, triggers y datos demo
@sql/02_views_package.sql   -- 2. Vistas analiticas + pkg_dashboard
@sql/07_crud_clientes.sql   -- 3. pkg_clientes (CRUD de clientes)
```

> Los scripts son idempotentes: si las tablas ya existen, las elimina y las recrea. Esto es util para resetear el entorno de pruebas.

---

## Tablas

### Diagrama de relaciones

```
CLIENTES ────────────────┐
                         │ cliente_id
VENDEDORES ──────────────┤ vendedor_id
                         ▼
                       VENTAS ──────────── DETALLE_VENTAS
                                venta_id        │
                                                │ producto_id
                                                ▼
                                           PRODUCTOS
```

### CLIENTES

Catalogo de empresas o personas que compran.

| Columna     | Tipo           | Descripcion |
|-------------|----------------|-------------|
| ID          | NUMBER (PK)    | Generado automaticamente por trigger + secuencia |
| NOMBRE      | VARCHAR2(120)  | Razon social o nombre. Obligatorio |
| EMAIL       | VARCHAR2(120)  | Correo de contacto. Opcional |
| CIUDAD      | VARCHAR2(80)   | Ciudad del cliente |
| PAIS        | VARCHAR2(60)   | Codigo de pais. Default: 'MX' |
| FECHA_ALTA  | DATE           | Fecha de registro. Default: SYSDATE |

### VENDEDORES

Equipo comercial. No se modifica via la app React (solo datos demo).

| Columna       | Tipo           | Descripcion |
|---------------|----------------|-------------|
| ID            | NUMBER (PK)    | Auto-generado |
| NOMBRE        | VARCHAR2(120)  | Nombre completo |
| REGION        | VARCHAR2(60)   | Norte, Sur, Centro, Occidente, Sureste |
| META_MENSUAL  | NUMBER(12,2)   | Meta de ventas mensual en pesos |

### PRODUCTOS

Catalogo de productos.

| Columna    | Tipo          | Descripcion |
|------------|---------------|-------------|
| ID         | NUMBER (PK)   | Auto-generado |
| NOMBRE     | VARCHAR2(120) | Nombre del producto |
| CATEGORIA  | VARCHAR2(60)  | Computo, Accesorios, Telefonia, Audio, Oficina, Mobiliario |
| PRECIO     | NUMBER(10,2)  | Precio unitario en pesos |
| STOCK      | NUMBER(8)     | Unidades disponibles |
| ACTIVO     | CHAR(1)       | 'Y' activo, 'N' inactivo. Solo 'Y' aparece en graficos |

### VENTAS

Cabecera de cada venta.

| Columna     | Tipo          | Descripcion |
|-------------|---------------|-------------|
| ID          | NUMBER (PK)   | Auto-generado |
| CLIENTE_ID  | NUMBER (FK)   | Referencia a CLIENTES.ID |
| VENDEDOR_ID | NUMBER (FK)   | Referencia a VENDEDORES.ID |
| FECHA       | DATE          | Fecha de la venta. Default: SYSDATE |
| TOTAL       | NUMBER(12,2)  | Suma de todos los subtotales de DETALLE_VENTAS |
| ESTADO      | VARCHAR2(20)  | 'PAGADA', 'PENDIENTE' o 'CANCELADA' |

> Los KPIs y graficos solo consideran ventas con `ESTADO = 'PAGADA'`.

### DETALLE_VENTAS

Lineas de cada venta (que productos se vendieron).

| Columna          | Tipo          | Descripcion |
|------------------|---------------|-------------|
| ID               | NUMBER (PK)   | Auto-generado |
| VENTA_ID         | NUMBER (FK)   | Referencia a VENTAS.ID (CASCADE DELETE) |
| PRODUCTO_ID      | NUMBER (FK)   | Referencia a PRODUCTOS.ID |
| CANTIDAD         | NUMBER(8)     | Unidades vendidas |
| PRECIO_UNITARIO  | NUMBER(10,2)  | Precio al momento de la venta |
| SUBTOTAL         | NUMBER(12,2)  | Calculado automaticamente: CANTIDAD * PRECIO_UNITARIO |

> El trigger `trg_detalle_ventas_bi` calcula el SUBTOTAL automaticamente antes de cada INSERT.

---

## Secuencias y Triggers

Oracle 11g/12c no soporta columnas IDENTITY (eso llego en 12c Release 2). Por eso se usan **secuencias + triggers** para generar PKs automaticas.

```
seq_clientes     -> trg_clientes_bi     -> CLIENTES.ID
seq_vendedores   -> trg_vendedores_bi   -> VENDEDORES.ID
seq_productos    -> trg_productos_bi    -> PRODUCTOS.ID
seq_ventas       -> trg_ventas_bi       -> VENTAS.ID
seq_detalle_ventas -> trg_detalle_ventas_bi -> DETALLE_VENTAS.ID
```

Patron de cada trigger:
```sql
CREATE OR REPLACE TRIGGER trg_clientes_bi
BEFORE INSERT ON clientes FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN            -- Solo asigna si no se paso un ID explicito
    :new.id := seq_clientes.NEXTVAL;
  END IF;
END;
```

---

## Vistas analiticas

Las vistas pre-calculan los datos que consume el dashboard. Los paquetes PL/SQL simplemente abren cursores sobre estas vistas.

### V_VENTAS_MENSUALES

Serie de ingresos por mes para los ultimos 12 meses.

```sql
SELECT TO_CHAR(fecha,'YYYY-MM')    AS periodo,      -- '2025-04'
       TO_CHAR(fecha,'Mon YY',...) AS etiqueta,     -- 'Abr 25'
       COUNT(*)                    AS num_ventas,
       SUM(total)                  AS total_ventas,
       ROUND(AVG(total),2)         AS ticket_promedio
FROM   ventas
WHERE  estado = 'PAGADA'
  AND  fecha >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -11)  -- Ultimos 12 meses
GROUP  BY periodo, etiqueta
ORDER  BY periodo
```

Uso en el frontend: `VentasMensualesChart` (grafico de area).

### V_TOP_PRODUCTOS

Ranking de productos por ingresos totales.

```sql
SELECT p.id, p.nombre, p.categoria,
       SUM(d.cantidad)  AS unidades,
       SUM(d.subtotal)  AS ingresos
FROM   detalle_ventas d
       JOIN productos p ON p.id = d.producto_id
       JOIN ventas    v ON v.id = d.venta_id
WHERE  v.estado = 'PAGADA'
GROUP  BY p.id, p.nombre, p.categoria
ORDER  BY ingresos DESC
```

Uso: `TopProductosChart` (barras horizontales, top 5).

### V_VENTAS_CATEGORIA

Participacion de cada categoria de producto en los ingresos.

```sql
SELECT p.categoria, SUM(d.subtotal) AS ingresos, SUM(d.cantidad) AS unidades
FROM   detalle_ventas d
       JOIN productos p ON p.id = d.producto_id
       JOIN ventas    v ON v.id = d.venta_id
WHERE  v.estado = 'PAGADA'
GROUP  BY p.categoria
```

Uso: `CategoriasDonut` (grafico donut).

### V_VENTAS_REGION

Ingresos agrupados por region del vendedor.

```sql
SELECT vd.region, COUNT(v.id) AS num_ventas, SUM(v.total) AS ingresos
FROM   ventas v
       JOIN vendedores vd ON vd.id = v.vendedor_id
WHERE  v.estado = 'PAGADA'
GROUP  BY vd.region
```

Uso: `RegionBarChart` (barras verticales).

### V_ULTIMAS_VENTAS

Las N ventas mas recientes con datos desnormalizados (nombres en vez de IDs).

```sql
SELECT v.id,
       TO_CHAR(v.fecha,'YYYY-MM-DD') AS fecha,
       c.nombre  AS cliente,
       vd.nombre AS vendedor,
       vd.region,
       v.total,
       v.estado
FROM   ventas v
       JOIN clientes   c  ON c.id  = v.cliente_id
       JOIN vendedores vd ON vd.id = v.vendedor_id
ORDER  BY v.fecha DESC, v.id DESC
```

Uso: `UltimasVentasTable` (tabla).

---

## Paquete PKG_DASHBOARD

Encapsula toda la logica de consulta del dashboard. Cada procedimiento abre un `SYS_REFCURSOR` que los Application Processes de APEX convierten a JSON.

### Especificacion (API publica)

```sql
PACKAGE pkg_dashboard AS
  PROCEDURE p_kpis               (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ventas_mensuales   (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_top_productos      (p_limit IN NUMBER DEFAULT 5,
                                  p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ventas_categoria   (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ventas_region      (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ultimas_ventas     (p_limit IN NUMBER DEFAULT 10,
                                  p_cursor OUT SYS_REFCURSOR);
END pkg_dashboard;
```

### p_kpis: detalle especial

A diferencia de los otros, no consulta una vista. Calcula 8 metricas en un solo `SELECT FROM DUAL` con subconsultas:

| Columna            | Que calcula |
|--------------------|-------------|
| INGRESOS_TOTAL     | SUM(total) de ventas PAGADAS |
| INGRESOS_MES       | SUM(total) del mes en curso |
| NUM_VENTAS         | COUNT de ventas PAGADAS |
| VENTAS_HOY         | COUNT de ventas PAGADAS hoy |
| NUM_CLIENTES       | COUNT de todos los clientes |
| NUM_PRODUCTOS      | COUNT de productos activos (activo='Y') |
| TICKET_PROMEDIO    | AVG(total) de ventas PAGADAS |
| VENTAS_PENDIENTES  | COUNT de ventas PENDIENTES |

---

## Paquete PKG_CLIENTES

Maneja el CRUD completo de la tabla CLIENTES.

### Especificacion

```sql
PACKAGE pkg_clientes AS
  PROCEDURE p_list   (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create (p_nombre IN VARCHAR2, p_email IN VARCHAR2,
                      p_ciudad IN VARCHAR2, p_pais  IN VARCHAR2,
                      p_id OUT NUMBER);
  PROCEDURE p_update (p_id IN NUMBER, p_nombre IN VARCHAR2, p_email IN VARCHAR2,
                      p_ciudad IN VARCHAR2, p_pais IN VARCHAR2);
  PROCEDURE p_delete (p_id IN NUMBER);
END pkg_clientes;
```

### Comportamiento de cada procedimiento

| Procedimiento | SQL que ejecuta | Notas |
|--------------|-----------------|-------|
| `p_list` | `SELECT id, nombre, email, ciudad, pais FROM clientes ORDER BY nombre` | Devuelve todos los clientes ordenados por nombre |
| `p_create` | `INSERT INTO clientes ... RETURNING id INTO p_id` | El ID se genera por trigger y se devuelve al caller |
| `p_update` | `UPDATE clientes SET ... WHERE id = p_id` | Actualiza los 4 campos editables |
| `p_delete` | `DELETE FROM clientes WHERE id = p_id` | Eliminacion permanente |

Todos hacen `COMMIT` al final.

---

## Datos de ejemplo

El script `01_tables.sql` carga:

- 5 vendedores (Norte, Sur, Centro, Occidente, Sureste)
- 8 clientes en distintas ciudades de Mexico
- 10 productos en 6 categorias
- ~250 ventas aleatorias distribuidas en los ultimos 12 meses, generadas con `DBMS_RANDOM`

El generador de ventas asigna estados con esta probabilidad:
- `PAGADA` → 80% de los casos
- `PENDIENTE` → 10%
- `CANCELADA` → 10%
