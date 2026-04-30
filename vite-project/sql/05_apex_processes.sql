-- =====================================================================
-- 05_apex_processes.sql
-- REFERENCIA: codigo PL/SQL para pegar en cada Application Process
-- de APEX (App Builder -> Shared Components -> Application Processes).
--
-- Pasos en APEX Builder:
--   Shared Components -> Application Processes -> Create
--   Name:  (ver abajo)
--   Point: On Demand - Run this application process when requested by page
--   Type:  PL/SQL Anonymous Block
--   Body:  (pegar el bloque correspondiente)
-- =====================================================================

-- -----------------------------------------------------------------------
-- Process 1 | Name: DASH_KPIS
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_kpis(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process 2 | Name: DASH_VENTAS_MENSUALES
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_ventas_mensuales(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process 3 | Name: DASH_TOP_PRODUCTOS
--   Recibe el limit via APEX_APPLICATION.G_X01 (default 5)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur   SYS_REFCURSOR;
  l_limit NUMBER := NVL(TO_NUMBER(APEX_APPLICATION.G_X01), 5);
BEGIN
  pkg_dashboard.p_top_productos(l_limit, l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process 4 | Name: DASH_VENTAS_CATEGORIA
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_ventas_categoria(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process 5 | Name: DASH_VENTAS_REGION
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_dashboard.p_ventas_region(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process 6 | Name: DASH_ULTIMAS_VENTAS
--   Recibe el limit via APEX_APPLICATION.G_X01 (default 10)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur   SYS_REFCURSOR;
  l_limit NUMBER := NVL(TO_NUMBER(APEX_APPLICATION.G_X01), 10);
BEGIN
  pkg_dashboard.p_ultimas_ventas(l_limit, l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/
