-- =====================================================================
-- 03_usuarios_apex_processes.sql
-- Application Processes para APEX Builder
-- =====================================================================

-- -----------------------------------------------------------------------
-- ADMIN_USUARIOS_LIST  |  Lista todos los usuarios
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_crm_usuarios.p_list(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- ADMIN_USUARIOS_CREATE  |  Crea un usuario
--   x01=nombre, x02=email, x03=rol, x04=id_departamento
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id NUMBER;
BEGIN
  pkg_crm_usuarios.p_create(
    p_nombre         => APEX_APPLICATION.G_X01,
    p_email          => APEX_APPLICATION.G_X02,
    p_rol            => APEX_APPLICATION.G_X03,
    p_id_departamento=> TO_NUMBER(APEX_APPLICATION.G_X04),
    p_id             => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id_usuario', l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- ADMIN_USUARIOS_TOGGLE  |  Activa/inactiva un usuario
--   x01=id_usuario, x02=activo (S/N)
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_crm_usuarios.p_toggle_activo(
    p_id     => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_activo => APEX_APPLICATION.G_X02
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- ========================================================================
-- Resumen de Application Processes a crear en APEX Builder
-- ========================================================================
-- | Nombre                | Parametros                          |
-- |-----------------------|--------------------------------------|
-- | ADMIN_USUARIOS_LIST   | ninguno                             |
-- | ADMIN_USUARIOS_CREATE | x01=nombre, x02=email, x03=rol,    |
-- |                       | x04=id_departamento                |
-- | ADMIN_USUARIOS_TOGGLE | x01=id_usuario, x02=activo (S/N)  |
-- ========================================================================