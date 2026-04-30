-- =====================================================================
-- 02_proyectos_package.sql
-- pkg_crm_proyectos: package + body para operaciones CRUD de proyectos
-- =====================================================================

CREATE OR REPLACE PACKAGE pkg_crm_proyectos AS
  PROCEDURE p_list       (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_get        (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create     (p_nombre IN VARCHAR2, p_descripcion IN VARCHAR2,
                          p_id_oportunidad IN NUMBER, p_fecha_inicio IN DATE,
                          p_fecha_fin IN DATE, p_id OUT NUMBER);
  PROCEDURE p_update     (p_id IN NUMBER, p_nombre IN VARCHAR2,
                          p_descripcion IN VARCHAR2, p_fecha_inicio IN DATE,
                          p_fecha_fin IN DATE, p_estado IN VARCHAR2);
END pkg_crm_proyectos;
/

CREATE OR REPLACE PACKAGE BODY pkg_crm_proyectos AS

  PROCEDURE p_list (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    IF p_id_usuario IS NULL THEN
      OPEN p_cursor FOR
        SELECT p.id_proyecto, p.nombre, p.descripcion,
               p.id_estado, e.nombre AS estado_nombre, e.color_hex AS estado_color,
               p.fecha_inicio, p.fecha_fin, p.id_oportunidad,
               p.fecha_creacion, p.fecha_actualizacion
        FROM crm_proyectos p
          JOIN crm_estado_proyecto e ON e.id_estado_proyecto = p.id_estado
        ORDER BY p.fecha_creacion DESC;
    ELSE
      OPEN p_cursor FOR
        SELECT p.id_proyecto, p.nombre, p.descripcion,
               p.id_estado, e.nombre AS estado_nombre, e.color_hex AS estado_color,
               p.fecha_inicio, p.fecha_fin, p.id_oportunidad,
               p.fecha_creacion, p.fecha_actualizacion
        FROM crm_proyectos p
          JOIN crm_estado_proyecto e ON e.id_estado_proyecto = p.id_estado
          JOIN crm_oportunidades o ON o.id_oportunidad = p.id_oportunidad
        WHERE o.id_usuario = p_id_usuario
        ORDER BY p.fecha_creacion DESC;
    END IF;
  END p_list;

  PROCEDURE p_get (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT p.id_proyecto, p.nombre, p.descripcion,
             p.id_estado, e.nombre AS estado_nombre, e.color_hex AS estado_color,
             p.fecha_inicio, p.fecha_fin, p.id_oportunidad,
             p.fecha_creacion, p.fecha_actualizacion
      FROM crm_proyectos p
        JOIN crm_estado_proyecto e ON e.id_estado_proyecto = p.id_estado
      WHERE p.id_proyecto = p_id;
  END p_get;

  PROCEDURE p_create (p_nombre IN VARCHAR2, p_descripcion IN VARCHAR2,
                      p_id_oportunidad IN NUMBER, p_fecha_inicio IN DATE,
                      p_fecha_fin IN DATE, p_id OUT NUMBER) IS
  BEGIN
    INSERT INTO crm_proyectos (nombre, descripcion, id_oportunidad, fecha_inicio, fecha_fin)
    VALUES (p_nombre, p_descripcion, p_id_oportunidad, p_fecha_inicio, p_fecha_fin)
    RETURNING id_proyecto INTO p_id;
    COMMIT;
  END p_create;

  PROCEDURE p_update (p_id IN NUMBER, p_nombre IN VARCHAR2,
                      p_descripcion IN VARCHAR2, p_fecha_inicio IN DATE,
                      p_fecha_fin IN DATE, p_estado IN VARCHAR2) IS
    v_estado_id NUMBER;
  BEGIN
    SELECT id_estado_proyecto INTO v_estado_id
    FROM crm_estado_proyecto WHERE UPPER(nombre) = UPPER(p_estado);

    UPDATE crm_proyectos SET
      nombre        = p_nombre,
      descripcion   = p_descripcion,
      fecha_inicio  = p_fecha_inicio,
      fecha_fin     = p_fecha_fin,
      id_estado     = v_estado_id
    WHERE id_proyecto = p_id;
    COMMIT;
  END p_update;

END pkg_crm_proyectos;
/