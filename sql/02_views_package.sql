-- =====================================================================
-- 02_views_package.sql
-- Vistas analiticas + paquete PL/SQL para alimentar el dashboard.
-- =====================================================================

-- ---------------------------------------------------------------------
-- VISTAS
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_ventas_mensuales AS
SELECT TO_CHAR(fecha,'YYYY-MM')                AS periodo,
       TO_CHAR(fecha,'Mon YY','NLS_DATE_LANGUAGE=SPANISH') AS etiqueta,
       COUNT(*)                                AS num_ventas,
       SUM(total)                              AS total_ventas,
       ROUND(AVG(total),2)                     AS ticket_promedio
FROM   ventas
WHERE  estado = 'PAGADA'
  AND  fecha >= ADD_MONTHS(TRUNC(SYSDATE,'MM'), -11)
GROUP  BY TO_CHAR(fecha,'YYYY-MM'), TO_CHAR(fecha,'Mon YY','NLS_DATE_LANGUAGE=SPANISH')
ORDER  BY periodo;

CREATE OR REPLACE VIEW v_top_productos AS
SELECT p.id,
       p.nombre,
       p.categoria,
       SUM(d.cantidad)              AS unidades,
       SUM(d.subtotal)              AS ingresos
FROM   detalle_ventas d
       JOIN productos p ON p.id = d.producto_id
       JOIN ventas    v ON v.id = d.venta_id
WHERE  v.estado = 'PAGADA'
GROUP  BY p.id, p.nombre, p.categoria
ORDER  BY ingresos DESC;

CREATE OR REPLACE VIEW v_ventas_categoria AS
SELECT p.categoria,
       SUM(d.subtotal) AS ingresos,
       SUM(d.cantidad) AS unidades
FROM   detalle_ventas d
       JOIN productos p ON p.id = d.producto_id
       JOIN ventas    v ON v.id = d.venta_id
WHERE  v.estado = 'PAGADA'
GROUP  BY p.categoria
ORDER  BY ingresos DESC;

CREATE OR REPLACE VIEW v_ventas_region AS
SELECT vd.region,
       COUNT(v.id)  AS num_ventas,
       SUM(v.total) AS ingresos
FROM   ventas v
       JOIN vendedores vd ON vd.id = v.vendedor_id
WHERE  v.estado = 'PAGADA'
GROUP  BY vd.region
ORDER  BY ingresos DESC;

CREATE OR REPLACE VIEW v_ultimas_ventas AS
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
ORDER  BY v.fecha DESC, v.id DESC;

-- ---------------------------------------------------------------------
-- PAQUETE PL/SQL
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_dashboard AS
  --
  -- KPIs globales (un unico renglon JSON)
  --
  PROCEDURE p_kpis (p_cursor OUT SYS_REFCURSOR);

  -- Series y rankings
  PROCEDURE p_ventas_mensuales  (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_top_productos     (p_limit IN NUMBER DEFAULT 5,
                                 p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ventas_categoria  (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ventas_region     (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_ultimas_ventas    (p_limit IN NUMBER DEFAULT 10,
                                 p_cursor OUT SYS_REFCURSOR);
END pkg_dashboard;
/

CREATE OR REPLACE PACKAGE BODY pkg_dashboard AS

  PROCEDURE p_kpis (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT
        (SELECT NVL(SUM(total),0) FROM ventas
          WHERE estado='PAGADA')                           AS ingresos_total,
        (SELECT NVL(SUM(total),0) FROM ventas
          WHERE estado='PAGADA'
            AND fecha >= TRUNC(SYSDATE,'MM'))              AS ingresos_mes,
        (SELECT COUNT(*) FROM ventas
          WHERE estado='PAGADA')                           AS num_ventas,
        (SELECT COUNT(*) FROM ventas
          WHERE estado='PAGADA'
            AND TRUNC(fecha)=TRUNC(SYSDATE))               AS ventas_hoy,
        (SELECT COUNT(*) FROM clientes)                    AS num_clientes,
        (SELECT COUNT(*) FROM productos WHERE activo='Y')  AS num_productos,
        (SELECT NVL(ROUND(AVG(total),2),0) FROM ventas
          WHERE estado='PAGADA')                           AS ticket_promedio,
        (SELECT COUNT(*) FROM ventas
          WHERE estado='PENDIENTE')                        AS ventas_pendientes
      FROM dual;
  END;

  PROCEDURE p_ventas_mensuales (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT periodo, etiqueta, num_ventas, total_ventas, ticket_promedio
      FROM   v_ventas_mensuales;
  END;

  PROCEDURE p_top_productos (p_limit IN NUMBER DEFAULT 5,
                             p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id, nombre, categoria, unidades, ingresos
      FROM   v_top_productos
      WHERE  ROWNUM <= p_limit;
  END;

  PROCEDURE p_ventas_categoria (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT categoria, ingresos, unidades FROM v_ventas_categoria;
  END;

  PROCEDURE p_ventas_region (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT region, num_ventas, ingresos FROM v_ventas_region;
  END;

  PROCEDURE p_ultimas_ventas (p_limit IN NUMBER DEFAULT 10,
                              p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id, fecha, cliente, vendedor, region, total, estado
      FROM   v_ultimas_ventas
      WHERE  ROWNUM <= p_limit;
  END;

END pkg_dashboard;
/

SHOW ERRORS PACKAGE BODY pkg_dashboard;
