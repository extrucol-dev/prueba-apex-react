-- =====================================================================
-- 03_proyectos_apex_processes.sql
-- Application Processes para APEX Builder
-- =====================================================================

-- -----------------------------------------------------------------------
-- PROYECTOS_LIST  |  Lista proyectos (opcional: x01 = id_usuario)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur        SYS_REFCURSOR;
  l_id_usuario NUMBER := TO_NUMBER(NVL(APEX_APPLICATION.G_X01, 'NULL'));
BEGIN
  IF l_id_usuario IS NULL THEN
    pkg_crm_proyectos.p_list(NULL, l_cur);
  ELSE
    pkg_crm_proyectos.p_list(l_id_usuario, l_cur);
  END IF;
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- PROYECTOS_GET  |  Obtiene un proyecto por ID (x01 = id_proyecto)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_proyectos.p_get(TO_NUMBER(APEX_APPLICATION.G_X01), l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- PROYECTOS_CREATE  |  Crea un proyecto
--   x01=nombre, x02=descripcion, x03=id_oportunidad,
--   x04=fecha_inicio, x05=fecha_fin
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id NUMBER;
BEGIN
  pkg_crm_proyectos.p_create(
    p_nombre         => APEX_APPLICATION.G_X01,
    p_descripcion    => APEX_APPLICATION.G_X02,
    p_id_oportunidad => TO_NUMBER(NVL(APEX_APPLICATION.G_X03, 'NULL')),
    p_fecha_inicio   => TO_DATE(APEX_APPLICATION.G_X04, 'YYYY-MM-DD'),
    p_fecha_fin      => TO_DATE(APEX_APPLICATION.G_X05, 'YYYY-MM-DD'),
    p_id             => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id_proyecto', l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- PROYECTOS_UPDATE  |  Actualiza un proyecto
--   x01=id_proyecto, x02=nombre, x03=descripcion,
--   x04=fecha_inicio, x05=fecha_fin, x06=estado
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_proyectos.p_update(
    p_id            => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_nombre        => APEX_APPLICATION.G_X02,
    p_descripcion   => APEX_APPLICATION.G_X03,
    p_fecha_inicio  => TO_DATE(APEX_APPLICATION.G_X04, 'YYYY-MM-DD'),
    p_fecha_fin     => TO_DATE(APEX_APPLICATION.G_X05, 'YYYY-MM-DD'),
    p_estado        => APEX_APPLICATION.G_X06
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- ========================================================================
-- Resumen de Application Processes a crear en APEX Builder
-- ========================================================================
-- | Nombre           | Parametros                               |
-- |------------------|------------------------------------------|
-- | PROYECTOS_LIST   | x01=id_usuario (opcional)                |
-- | PROYECTOS_GET    | x01=id_proyecto                          |
-- | PROYECTOS_CREATE | x01-x05 (ver arriba)                    |
-- | PROYECTOS_UPDATE | x01-x06 (ver arriba)                    |
-- ========================================================================