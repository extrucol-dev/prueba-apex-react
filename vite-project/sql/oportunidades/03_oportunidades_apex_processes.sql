-- =====================================================================
-- 03_oportunidades_apex_processes.sql
-- Application Processes para APEX Builder
-- =====================================================================

-- -----------------------------------------------------------------------
-- OPP_LIST  |  Lista oportunidades (opcional: x01 = id_usuario)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur       SYS_REFCURSOR;
  l_id_usuario NUMBER := TO_NUMBER(NVL(APEX_APPLICATION.G_X01, 'NULL'));
BEGIN
  IF l_id_usuario IS NULL THEN
    pkg_crm_oportunidades.p_list(NULL, l_cur);
  ELSE
    pkg_crm_oportunidades.p_list(l_id_usuario, l_cur);
  END IF;
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_GET  |  Obtiene una oportunidad por ID (x01 = id_oportunidad)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_oportunidades.p_get(TO_NUMBER(APEX_APPLICATION.G_X01), l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_ACTIVIDADES  |  Lista actividades (x01 = id_oportunidad)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_oportunidades.p_actividades(TO_NUMBER(APEX_APPLICATION.G_X01), l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_CATALOGOS  |  Devuelve catalogos de oportunidades
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_oportunidades.p_catalogos(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_PRODUCTOS_CATALOGO  |  Lista productos
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_oportunidades.p_productos(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_CREATE  |  Crea oportunidad
--   x01=titulo, x02=descripcion, x03=id_tipo_oportunidad,
--   x04=id_estado_oportunidad, x05=valor_estimado, x06=probabilidad_cierre,
--   x07=id_sector, x08=id_empresa, x09=fecha_cierre_estimada, x10=id_usuario
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id NUMBER;
BEGIN
  pkg_crm_oportunidades.p_create(
    p_titulo              => APEX_APPLICATION.G_X01,
    p_descripcion         => APEX_APPLICATION.G_X02,
    p_id_tipo_opp         => TO_NUMBER(APEX_APPLICATION.G_X03),
    p_id_estado_opp       => TO_NUMBER(APEX_APPLICATION.G_X04),
    p_valor_estimado       => TO_NUMBER(APEX_APPLICATION.G_X05),
    p_probabilidad        => TO_NUMBER(APEX_APPLICATION.G_X06),
    p_id_sector           => TO_NUMBER(APEX_APPLICATION.G_X07),
    p_id_empresa          => TO_NUMBER(APEX_APPLICATION.G_X08),
    p_fecha_cierre        => TO_DATE(APEX_APPLICATION.G_X09, 'YYYY-MM-DD'),
    p_id_usuario          => TO_NUMBER(APEX_APPLICATION.G_X10),
    p_id                  => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id_oportunidad', l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_UPDATE  |  Actualiza oportunidad
--   x01=id_oportunidad, x02=titulo, x03=descripcion, x04=id_tipo_oportunidad,
--   x05=id_estado_oportunidad, x06=valor_estimado, x07=probabilidad_cierre,
--   x08=id_sector, x09=id_empresa, x10=fecha_cierre_estimada
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_oportunidades.p_update(
    p_id                  => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_titulo              => APEX_APPLICATION.G_X02,
    p_descripcion         => APEX_APPLICATION.G_X03,
    p_id_tipo_opp         => TO_NUMBER(APEX_APPLICATION.G_X04),
    p_id_estado_opp       => TO_NUMBER(APEX_APPLICATION.G_X05),
    p_valor_estimado      => TO_NUMBER(APEX_APPLICATION.G_X06),
    p_probabilidad        => TO_NUMBER(APEX_APPLICATION.G_X07),
    p_id_sector           => TO_NUMBER(APEX_APPLICATION.G_X08),
    p_id_empresa          => TO_NUMBER(APEX_APPLICATION.G_X09),
    p_fecha_cierre        => TO_DATE(APEX_APPLICATION.G_X10, 'YYYY-MM-DD')
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_AVANZAR_ESTADO  |  Avanza estado de oportunidad
--   x01=id_oportunidad, x02=id_estado_nuevo, x03=comentario
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_oportunidades.p_avanzar_estado(
    p_id             => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_id_estado_nuevo => TO_NUMBER(APEX_APPLICATION.G_X02),
    p_comentario     => APEX_APPLICATION.G_X03
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_CERRAR_GANADA  |  Cierra oportunidad como ganada
--   x01=id_oportunidad, x02=valor_final, x03=id_motivo, x04=descripcion
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_oportunidades.p_cerrar_ganada(
    p_id          => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_valor_final => TO_NUMBER(APEX_APPLICATION.G_X02),
    p_id_motivo   => TO_NUMBER(APEX_APPLICATION.G_X03),
    p_descripcion => APEX_APPLICATION.G_X04
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_CERRAR_PERDIDA  |  Cierra oportunidad como perdida
--   x01=id_oportunidad, x02=id_motivo, x03=descripcion
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_oportunidades.p_cerrar_perdida(
    p_id          => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_id_motivo   => TO_NUMBER(APEX_APPLICATION.G_X02),
    p_descripcion => APEX_APPLICATION.G_X03
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- OPP_ESTANCADOS  |  Oportunidades sin actividad > 30 dias (opcional: x01=id_usuario)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur       SYS_REFCURSOR;
  l_id_usuario NUMBER := TO_NUMBER(NVL(APEX_APPLICATION.G_X01, 'NULL'));
BEGIN
  IF l_id_usuario IS NULL THEN
    pkg_crm_oportunidades.p_estancados(NULL, l_cur);
  ELSE
    pkg_crm_oportunidades.p_estancados(l_id_usuario, l_cur);
  END IF;
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- ========================================================================
-- Resumen de Application Processes a crear en APEX Builder
-- ========================================================================
-- | Nombre              | Parametros                          |
-- |---------------------|-------------------------------------|
-- | OPP_LIST            | x01=id_usuario (opcional)           |
-- | OPP_GET             | x01=id_oportunidad                  |
-- | OPP_ACTIVIDADES     | x01=id_oportunidad                  |
-- | OPP_CATALOGOS       | ninguno                             |
-- | OPP_PRODUCTOS_CATALOGO | ninguno                          |
-- | OPP_CREATE          | x01-x10 (ver arriba)                |
-- | OPP_UPDATE          | x01-x10 (ver arriba)                |
-- | OPP_AVANZAR_ESTADO  | x01=id, x02=estado, x03=comentario |
-- | OPP_CERRAR_GANADA   | x01=id, x02=valor, x03=motivo, x04=desc |
-- | OPP_CERRAR_PERDIDA  | x01=id, x02=motivo, x03=desc       |
-- | OPP_ESTANCADOS      | x01=id_usuario (opcional)           |
-- ========================================================================
