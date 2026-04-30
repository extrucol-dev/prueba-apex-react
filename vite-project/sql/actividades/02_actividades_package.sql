-- =====================================================================
-- 02_actividades_package.sql
-- pkg_crm_actividades: package + body para operaciones CRUD de actividades
-- =====================================================================

CREATE OR REPLACE PACKAGE pkg_crm_actividades AS
  PROCEDURE p_list           (p_id_usuario IN NUMBER, p_fecha_desde IN DATE,
                               p_fecha_hasta IN DATE, p_tipo IN VARCHAR2,
                               p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_list_todas      (p_fecha_desde IN DATE, p_fecha_hasta IN DATE,
                               p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_get             (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create          (p_tipo IN VARCHAR2, p_asunto IN VARCHAR2,
                               p_descripcion IN VARCHAR2, p_id_lead IN NUMBER,
                               p_id_oportunidad IN NUMBER, p_fecha IN DATE,
                               p_virtual IN VARCHAR2, p_id_usuario IN NUMBER,
                               p_id OUT NUMBER);
  PROCEDURE p_completar       (p_id IN NUMBER, p_resultado IN VARCHAR2,
                               p_latitud IN NUMBER, p_longitud IN NUMBER);
END pkg_crm_actividades;
/

CREATE OR REPLACE PACKAGE BODY pkg_crm_actividades AS

  PROCEDURE p_list (p_id_usuario IN NUMBER, p_fecha_desde IN DATE,
                    p_fecha_hasta IN DATE, p_tipo IN VARCHAR2,
                    p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT a.id_actividad, a.tipo, a.asunto, a.descripcion,
             TO_CHAR(a.fecha,'YYYY-MM-DD') AS fecha,
             a.virtual, a.completada,
             a.id_lead, a.id_oportunidad, a.id_usuario,
             a.resultado, a.latitud, a.longitud,
             a.fecha_creacion,
             u.nombre AS ejecutivo_nombre
      FROM crm_actividades a
        LEFT JOIN vendedores u ON u.id = a.id_usuario
      WHERE (p_id_usuario IS NULL OR a.id_usuario = p_id_usuario)
        AND (p_fecha_desde IS NULL OR a.fecha >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR a.fecha <= p_fecha_hasta)
        AND (p_tipo IS NULL OR a.tipo = p_tipo)
      ORDER BY a.fecha DESC;
  END p_list;

  PROCEDURE p_list_todas (p_fecha_desde IN DATE, p_fecha_hasta IN DATE,
                          p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT a.id_actividad, a.tipo, a.asunto, a.descripcion,
             TO_CHAR(a.fecha,'YYYY-MM-DD') AS fecha,
             a.virtual, a.completada,
             a.id_lead, a.id_oportunidad, a.id_usuario,
             a.resultado, a.latitud, a.longitud,
             a.fecha_creacion,
             u.nombre AS ejecutivo_nombre
      FROM crm_actividades a
        LEFT JOIN vendedores u ON u.id = a.id_usuario
      WHERE (p_fecha_desde IS NULL OR a.fecha >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR a.fecha <= p_fecha_hasta)
      ORDER BY a.fecha DESC;
  END p_list_todas;

  PROCEDURE p_get (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT a.id_actividad, a.tipo, a.asunto, a.descripcion,
             TO_CHAR(a.fecha,'YYYY-MM-DD') AS fecha,
             a.virtual, a.completada,
             a.id_lead, a.id_oportunidad, a.id_usuario,
             a.resultado, a.latitud, a.longitud,
             a.fecha_creacion,
             u.nombre AS ejecutivo_nombre
      FROM crm_actividades a
        LEFT JOIN vendedores u ON u.id = a.id_usuario
      WHERE a.id_actividad = p_id;
  END p_get;

  PROCEDURE p_create (p_tipo IN VARCHAR2, p_asunto IN VARCHAR2,
                      p_descripcion IN VARCHAR2, p_id_lead IN NUMBER,
                      p_id_oportunidad IN NUMBER, p_fecha IN DATE,
                      p_virtual IN VARCHAR2, p_id_usuario IN NUMBER,
                      p_id OUT NUMBER) IS
  BEGIN
    INSERT INTO crm_actividades (
      tipo, asunto, descripcion, fecha, virtual,
      id_lead, id_oportunidad, id_usuario
    ) VALUES (
      p_tipo, p_asunto, p_descripcion, p_fecha, p_virtual,
      p_id_lead, p_id_oportunidad, p_id_usuario
    ) RETURNING id_actividad INTO p_id;
    COMMIT;
  END p_create;

  PROCEDURE p_completar (p_id IN NUMBER, p_resultado IN VARCHAR2,
                          p_latitud IN NUMBER, p_longitud IN NUMBER) IS
  BEGIN
    UPDATE crm_actividades SET
      completada = 'S',
      resultado   = p_resultado,
      latitud     = p_latitud,
      longitud    = p_longitud
    WHERE id_actividad = p_id;
    COMMIT;
  END p_completar;

END pkg_crm_actividades;
/