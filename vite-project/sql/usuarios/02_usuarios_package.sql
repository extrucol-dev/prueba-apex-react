-- =====================================================================
-- 02_usuarios_package.sql
-- pkg_crm_usuarios: package + body para operaciones CRUD de usuarios
-- =====================================================================

CREATE OR REPLACE PACKAGE pkg_crm_usuarios AS
  PROCEDURE p_list         (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create       (p_nombre IN VARCHAR2, p_email IN VARCHAR2,
                             p_rol IN VARCHAR2, p_id_departamento IN NUMBER,
                             p_id OUT NUMBER);
  PROCEDURE p_toggle_activo (p_id IN NUMBER, p_activo IN VARCHAR2);
END pkg_crm_usuarios;
/

CREATE OR REPLACE PACKAGE BODY pkg_crm_usuarios AS

  PROCEDURE p_list (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT u.id_usuario, u.nombre, u.email, u.rol, u.activo,
             u.id_departamento, d.nombre AS departamento_nombre,
             u.fecha_creacion
      FROM crm_usuarios u
        LEFT JOIN crm_departamento d ON d.id_departamento = u.id_departamento
      ORDER BY u.nombre;
  END p_list;

  PROCEDURE p_create (p_nombre IN VARCHAR2, p_email IN VARCHAR2,
                      p_rol IN VARCHAR2, p_id_departamento IN NUMBER,
                      p_id OUT NUMBER) IS
  BEGIN
    INSERT INTO crm_usuarios (nombre, email, rol, id_departamento)
    VALUES (p_nombre, p_email, p_rol, p_id_departamento)
    RETURNING id_usuario INTO p_id;
    COMMIT;
  END p_create;

  PROCEDURE p_toggle_activo (p_id IN NUMBER, p_activo IN VARCHAR2) IS
  BEGIN
    UPDATE crm_usuarios SET activo = p_activo WHERE id_usuario = p_id;
    COMMIT;
  END p_toggle_activo;

END pkg_crm_usuarios;
/