-- =====================================================================
-- 07_crud_clientes.sql
-- 1. Package pkg_clientes  (spec + body)
-- 2. Referencia PL/SQL para 4 Application Processes en APEX Builder:
--    CLIENTES_LIST | CLIENTES_CREATE | CLIENTES_UPDATE | CLIENTES_DELETE
-- =====================================================================

-- ---------------------------------------------------------------------
-- Package spec
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_clientes AS
  PROCEDURE p_list   (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create (p_nombre IN VARCHAR2,
                      p_email  IN VARCHAR2,
                      p_ciudad IN VARCHAR2,
                      p_pais   IN VARCHAR2,
                      p_id     OUT NUMBER);
  PROCEDURE p_update (p_id     IN NUMBER,
                      p_nombre IN VARCHAR2,
                      p_email  IN VARCHAR2,
                      p_ciudad IN VARCHAR2,
                      p_pais   IN VARCHAR2);
  PROCEDURE p_delete (p_id IN NUMBER);
END pkg_clientes;
/

-- ---------------------------------------------------------------------
-- Package body
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_clientes AS

  PROCEDURE p_list(p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id, nombre, email, ciudad, pais
      FROM   clientes
      ORDER  BY nombre;
  END;

  PROCEDURE p_create(p_nombre IN VARCHAR2,
                     p_email  IN VARCHAR2,
                     p_ciudad IN VARCHAR2,
                     p_pais   IN VARCHAR2,
                     p_id     OUT NUMBER) IS
  BEGIN
    INSERT INTO clientes (nombre, email, ciudad, pais)
    VALUES (p_nombre, p_email, p_ciudad, p_pais)
    RETURNING id INTO p_id;
    COMMIT;
  END;

  PROCEDURE p_update(p_id     IN NUMBER,
                     p_nombre IN VARCHAR2,
                     p_email  IN VARCHAR2,
                     p_ciudad IN VARCHAR2,
                     p_pais   IN VARCHAR2) IS
  BEGIN
    UPDATE clientes
    SET    nombre = p_nombre,
           email  = p_email,
           ciudad = p_ciudad,
           pais   = p_pais
    WHERE  id = p_id;
    COMMIT;
  END;

  PROCEDURE p_delete(p_id IN NUMBER) IS
  BEGIN
    DELETE FROM clientes WHERE id = p_id;
    COMMIT;
  END;

END pkg_clientes;
/

-- =====================================================================
-- REFERENCIA: PL/SQL para pegar en cada Application Process de APEX
-- App Builder -> Shared Components -> Application Processes -> Create
-- Point: On Demand | Type: PL/SQL Anonymous Block
-- =====================================================================

-- -----------------------------------------------------------------------
-- Process: CLIENTES_LIST
-- -----------------------------------------------------------------------
/*
DECLARE
  l_cur SYS_REFCURSOR;
BEGIN
  pkg_clientes.p_list(l_cur);
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('data', l_cur);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process: CLIENTES_CREATE
--   x01=nombre | x02=email | x03=ciudad | x04=pais
-- -----------------------------------------------------------------------
/*
DECLARE
  l_id NUMBER;
BEGIN
  pkg_clientes.p_create(
    p_nombre => APEX_APPLICATION.G_X01,
    p_email  => APEX_APPLICATION.G_X02,
    p_ciudad => APEX_APPLICATION.G_X03,
    p_pais   => APEX_APPLICATION.G_X04,
    p_id     => l_id
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('id',      l_id);
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process: CLIENTES_UPDATE
--   x01=id | x02=nombre | x03=email | x04=ciudad | x05=pais
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_clientes.p_update(
    p_id     => TO_NUMBER(APEX_APPLICATION.G_X01),
    p_nombre => APEX_APPLICATION.G_X02,
    p_email  => APEX_APPLICATION.G_X03,
    p_ciudad => APEX_APPLICATION.G_X04,
    p_pais   => APEX_APPLICATION.G_X05
  );
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/

-- -----------------------------------------------------------------------
-- Process: CLIENTES_DELETE
--   x01=id
-- -----------------------------------------------------------------------
/*
BEGIN
  pkg_clientes.p_delete(TO_NUMBER(APEX_APPLICATION.G_X01));
  APEX_JSON.OPEN_OBJECT;
  APEX_JSON.WRITE('success', TRUE);
  APEX_JSON.CLOSE_OBJECT;
END;
*/
