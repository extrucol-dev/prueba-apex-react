-- =====================================================================
-- 03_actividades_apex_processes.sql
-- Application Processes para APEX Builder
-- =====================================================================

-- -----------------------------------------------------------------------
-- ACTIVIDADES_LIST  |  Lista actividades (x01=id_usuario, x02=fecha_desde,
--                       x03=fecha_hasta, x04=tipo)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur        SYS_REFCURSOR;
  l_id_usuario NUMBER := TO_NUMBER(NVL(APEX_APPLICATION.G_X01, 'NULL'));
  l_fecha_desde DATE  := TO_DATE(APEX_APPLICATION.G_X02, 'YYYY-MM-DD');
  l_fecha_hasta DATE  := TO_DATE(APEX_APPLICATION.G_X03, 'YYYY-MM-DD');
BEGIN
  IF l_id_usuario IS NULL THEN
    pkg_crm_actividades.p_list(NULL, l_fecha_desde, l_fecha_hasta, APEX_APPLICATION.G_X04, l_cur);
  ELSE
    pkg_crm_actividades.p_list(l_id_usuario, l_fecha_desde, l_fecha_hasta, APEX_APPLICATION.G_X04, l_cur);
  END IF;
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- ACTIVIDADES_ALL_FOR_COORD  |  Lista todas para coordinadores
--   x01=fecha_desde, x02=fecha_hasta
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur         SYS_REFCURSOR;
  l_fecha_desde DATE := TO_DATE(APEX_APPLICATION.G_X01, 'YYYY-MM-DD');
  l_fecha_hasta DATE := TO_DATE(APEX_APPLICATION.G_X02, 'YYYY-MM-DD');
BEGIN
  pkg_crm_actividades.p_list_todas(l_fecha_desde, l_fecha_hasta, l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- ACTIVIDADES_GET  |  Obtiene una actividad por ID (x01 = id_actividad)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_actividades.p_get(TO_NUMBER(APEX_APPLICATION.G_X01), l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- ACTIVIDADES_CREATE  |  Crea una actividad
--   x01=tipo, x02=asunto, x03=descripcion, x04=id_lead,
--   x05=id_oportunidad, x06=fecha, x07=virtual (S/N)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id NUMBER;
BEGIN
  pkg_crm_actividades.p_create(
    p_tipo          => APEX_APPLICATION.G_X01,
    p_asunto        => APEX_APPLICATION.G_X02,
    p_descripcion   => APEX_APPLICATION.G_X03,
    p_id_lead       => TO_NUMBER(NVL(APEX_APPLICATION.G_X04, 'NULL')),
    p_id_oportunidad=> TO_NUMBER(NVL(APEX_APPLICATION.G_X05, 'NULL')),
    p_fecha         => TO_DATE(APEX_APPLICATION.G_X06, 'YYYY-MM-DD'),
    p_virtual       => APEX_APPLICATION.G_X07,
    p_id_usuario    => TO_NUMBER(NVL(APEX_APPLICATION.G_X08, 'NULL')),
    p_id            => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id_actividad', l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- ACTIVIDADES_COMPLETAR  |  Completa una actividad
--   x01=id_actividad, x02=resultado, x03=latitud, x04=longitud
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_actividades.p_completar(
    p_id        => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_resultado => APEX_APPLICATION.G_X02,
    p_latitud   => TO_NUMBER(NVL(APEX_APPLICATION.G_X03, 'NULL')),
    p_longitud  => TO_NUMBER(NVL(APEX_APPLICATION.G_X04, 'NULL'))
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- ========================================================================
-- Resumen de Application Processes a crear en APEX Builder
-- ========================================================================
-- | Nombre                  | Parametros                             |
-- |-------------------------|----------------------------------------|
-- | ACTIVIDADES_LIST        | x01=id_usuario, x02=fecha_desde,      |
-- |                         | x03=fecha_hasta, x04=tipo             |
-- | ACTIVIDADES_ALL_FOR_COORD | x01=fecha_desde, x02=fecha_hasta    |
-- | ACTIVIDADES_GET         | x01=id_actividad                      |
-- | ACTIVIDADES_CREATE      | x01-x08 (ver arriba)                  |
-- | ACTIVIDADES_COMPLETAR   | x01=id, x02=resultado, x03=x04=coords |
-- ========================================================================