-- =====================================================================
-- 03_leads_apex_processes.sql
-- Application Processes para APEX Builder
-- =====================================================================

-- -----------------------------------------------------------------------
-- LEADS_CATALOGOS  |  Devuelve todos los catalogos de leads
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_leads.p_catalogos(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_LIST  |  Lista leads (opcional: x01 = id_usuario)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur       SYS_REFCURSOR;
  l_id_usuario NUMBER := TO_NUMBER(NVL(APEX_APPLICATION.G_X01, 'NULL'));
BEGIN
  IF l_id_usuario IS NULL THEN
    pkg_crm_leads.p_list(NULL, l_cur);
  ELSE
    pkg_crm_leads.p_list(l_id_usuario, l_cur);
  END IF;
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_GET  |  Obtiene un lead por ID (x01 = id_lead)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_leads.p_get(TO_NUMBER(APEX_APPLICATION.G_X01), l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_HISTORIAL  |  Historial de cambios de un lead (x01 = id_lead)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_leads.p_historial(TO_NUMBER(APEX_APPLICATION.G_X01), l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_CREATE  |  Crea un lead
--   x01=titulo, x02=descripcion, x03=score, x04=id_estado_lead,
--   x05=id_origen_lead, x06=id_usuario, x07=nombre_empresa,
--   x08=nombre_contacto, x09=telefono_contacto, x10=email_contacto
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id NUMBER;
BEGIN
  pkg_crm_leads.p_create(
    p_titulo              => APEX_APPLICATION.G_X01,
    p_descripcion         => APEX_APPLICATION.G_X02,
    p_score               => TO_NUMBER(APEX_APPLICATION.G_X03),
    p_id_estado_lead      => TO_NUMBER(APEX_APPLICATION.G_X04),
    p_id_origen_lead      => TO_NUMBER(APEX_APPLICATION.G_X05),
    p_id_usuario          => TO_NUMBER(APEX_APPLICATION.G_X06),
    p_nombre_empresa      => APEX_APPLICATION.G_X07,
    p_nombre_contacto     => APEX_APPLICATION.G_X08,
    p_telefono_contacto   => APEX_APPLICATION.G_X09,
    p_email_contacto      => APEX_APPLICATION.G_X10,
    p_id                  => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id_lead', l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_UPDATE  |  Actualiza un lead
--   x01=id_lead, x02=titulo, x03=descripcion, x04=score,
--   x05=id_estado_lead, x06=id_origen_lead, x07=id_usuario,
--   x08=nombre_empresa, x09=nombre_contacto, x10=telefono_contacto,
--   x11=email_contacto
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_leads.p_update(
    p_id                  => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_titulo              => APEX_APPLICATION.G_X02,
    p_descripcion         => APEX_APPLICATION.G_X03,
    p_score               => TO_NUMBER(APEX_APPLICATION.G_X04),
    p_id_estado_lead      => TO_NUMBER(APEX_APPLICATION.G_X05),
    p_id_origen_lead      => TO_NUMBER(APEX_APPLICATION.G_X06),
    p_id_usuario          => TO_NUMBER(APEX_APPLICATION.G_X07),
    p_nombre_empresa      => APEX_APPLICATION.G_X08,
    p_nombre_contacto     => APEX_APPLICATION.G_X09,
    p_telefono_contacto   => APEX_APPLICATION.G_X10,
    p_email_contacto      => APEX_APPLICATION.G_X11
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_DESCALIFICAR  |  Descalifica un lead
--   x01=id_lead, x02=id_motivo, x03=observacion
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_leads.p_descalificar(
    p_id         => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_id_motivo  => TO_NUMBER(APEX_APPLICATION.G_X02),
    p_observacion => APEX_APPLICATION.G_X03
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- LEADS_CONVERTIR  |  Convierte un lead en oportunidad
--   x01=id_lead, x02=titulo_opp, x03=id_tipo, x04=id_sector,
--   x05=descripcion, x06=id_empresa, x07=id_usuario,
--   x08=id_usuario_asignado, x09=valor_estimado, x10=fecha_cierre,
--   x11=probabilidad, x12=id_estado_opp (default 1)
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id_opp NUMBER;
BEGIN
  pkg_crm_leads.p_convertir(
    p_id_lead           => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_titulo_opp        => APEX_APPLICATION.G_X02,
    p_id_tipo_opp       => TO_NUMBER(APEX_APPLICATION.G_X03),
    p_id_sector         => TO_NUMBER(APEX_APPLICATION.G_X04),
    p_descripcion       => APEX_APPLICATION.G_X05,
    p_id_empresa        => TO_NUMBER(APEX_APPLICATION.G_X06),
    p_id_usuario        => TO_NUMBER(APEX_APPLICATION.G_X07),
    p_valor_estimado    => TO_NUMBER(APEX_APPLICATION.G_X09),
    p_fecha_cierre      => TO_DATE(APEX_APPLICATION.G_X10, 'YYYY-MM-DD'),
    p_probabilidad      => TO_NUMBER(APEX_APPLICATION.G_X11),
    p_id_oportunidad    => l_id_opp
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id_oportunidad', l_id_opp);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- ========================================================================
-- Resumen de Application Processes a crear en APEX Builder
-- ========================================================================
-- | Nombre              | Parametros                          |
-- |---------------------|-------------------------------------|
-- | LEADS_CATALOGOS     | ninguno                             |
-- | LEADS_LIST          | x01=id_usuario (opcional)           |
-- | LEADS_GET           | x01=id_lead                         |
-- | LEADS_HISTORIAL     | x01=id_lead                          |
-- | LEADS_CREATE        | x01-x10 (ver arriba)                |
-- | LEADS_UPDATE        | x01-x11 (ver arriba)                |
-- | LEADS_DESCALIFICAR  | x01=id_lead, x02=id_motivo, x03=obs |
-- | LEADS_CONVERTIR     | x01-x12 (ver arriba)                |
-- ========================================================================
