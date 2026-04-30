-- =====================================================================
-- 02_leads_package.sql
-- pkg_crm_leads: package + body para operaciones CRUD de leads
-- =====================================================================

CREATE OR REPLACE PACKAGE pkg_crm_leads AS
  PROCEDURE p_catalogos    (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_list         (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_get          (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_historial    (p_id_lead IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create       (p_titulo IN VARCHAR2, p_descripcion IN VARCHAR2,
                            p_score IN NUMBER, p_id_estado_lead IN NUMBER,
                            p_id_origen_lead IN NUMBER, p_id_usuario IN NUMBER,
                            p_nombre_empresa IN VARCHAR2, p_nombre_contacto IN VARCHAR2,
                            p_telefono_contacto IN VARCHAR2, p_email_contacto IN VARCHAR2,
                            p_id OUT NUMBER);
  PROCEDURE p_update       (p_id IN NUMBER, p_titulo IN VARCHAR2,
                            p_descripcion IN VARCHAR2, p_score IN NUMBER,
                            p_id_estado_lead IN NUMBER, p_id_origen_lead IN NUMBER,
                            p_id_usuario IN NUMBER, p_nombre_empresa IN VARCHAR2,
                            p_nombre_contacto IN VARCHAR2, p_telefono_contacto IN VARCHAR2,
                            p_email_contacto IN VARCHAR2);
  PROCEDURE p_descalificar (p_id IN NUMBER, p_id_motivo IN NUMBER, p_observacion IN VARCHAR2);
  PROCEDURE p_convertir    (p_id_lead IN NUMBER, p_titulo_opp IN VARCHAR2,
                            p_id_tipo_opp IN NUMBER, p_id_sector IN NUMBER,
                            p_descripcion IN VARCHAR2, p_id_empresa IN NUMBER,
                            p_id_usuario IN NUMBER, p_valor_estimado IN NUMBER,
                            p_fecha_cierre IN DATE, p_probabilidad IN NUMBER,
                            p_id_oportunidad OUT NUMBER);
END pkg_crm_leads;
/

CREATE OR REPLACE PACKAGE BODY pkg_crm_leads AS

  PROCEDURE p_catalogos (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_estado_lead' VALUE e.id_estado_lead,
                      'nombre' VALUE e.nombre,
                      'tipo' VALUE e.tipo,
                      'orden' VALUE e.orden,
                      'color_hex' VALUE e.color_hex)
        ) FROM crm_estado_lead e ORDER BY e.orden) AS estados,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_origen_lead' VALUE o.id_origen_lead,
                      'nombre' VALUE o.nombre,
                      'color_hex' VALUE o.color_hex)
        ) FROM crm_origen_lead o ORDER BY o.id_origen_lead) AS origenes,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_interes' VALUE i.id_interes,
                      'nombre' VALUE i.nombre)
        ) FROM crm_interes i ORDER BY i.id_interes) AS intereses,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_motivo_descalificacion' VALUE m.id_motivo_descalificacion,
                      'nombre' VALUE m.nombre)
        ) FROM crm_motivo_descalificacion m ORDER BY m.id_motivo_descalificacion) AS motivos_descalificacion
      FROM DUAL;
  END p_catalogos;

  PROCEDURE p_list (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    IF p_id_usuario IS NULL THEN
      OPEN p_cursor FOR
        SELECT l.id_lead, l.titulo, l.descripcion, l.score,
               l.id_estado_lead, e.nombre AS estado_nombre, e.tipo AS estado_tipo,
               l.id_origen_lead, o.nombre AS origen_nombre,
               l.nombre_empresa, l.nombre_contacto,
               l.telefono_contacto, l.email_contacto,
               l.id_usuario, l.fecha_creacion, l.fecha_actualizacion,
               l.id_oportunidad_generada, l.id_motivo_descalificacion
        FROM crm_leads l
          JOIN crm_estado_lead e ON e.id_estado_lead = l.id_estado_lead
          JOIN crm_origen_lead o ON o.id_origen_lead = l.id_origen_lead
        ORDER BY l.fecha_creacion DESC;
    ELSE
      OPEN p_cursor FOR
        SELECT l.id_lead, l.titulo, l.descripcion, l.score,
               l.id_estado_lead, e.nombre AS estado_nombre, e.tipo AS estado_tipo,
               l.id_origen_lead, o.nombre AS origen_nombre,
               l.nombre_empresa, l.nombre_contacto,
               l.telefono_contacto, l.email_contacto,
               l.id_usuario, l.fecha_creacion, l.fecha_actualizacion,
               l.id_oportunidad_generada, l.id_motivo_descalificacion
        FROM crm_leads l
          JOIN crm_estado_lead e ON e.id_estado_lead = l.id_estado_lead
          JOIN crm_origen_lead o ON o.id_origen_lead = l.id_origen_lead
        WHERE l.id_usuario = p_id_usuario
        ORDER BY l.fecha_creacion DESC;
    END IF;
  END p_list;

  PROCEDURE p_get (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT l.id_lead, l.titulo, l.descripcion, l.score,
             l.id_estado_lead, e.nombre AS estado_nombre, e.tipo AS estado_tipo,
             l.id_origen_lead, o.nombre AS origen_nombre,
             l.nombre_empresa, l.nombre_contacto,
             l.telefono_contacto, l.email_contacto,
             l.id_usuario, l.fecha_creacion, l.fecha_actualizacion,
             l.id_oportunidad_generada, l.id_motivo_descalificacion
      FROM crm_leads l
        JOIN crm_estado_lead e ON e.id_estado_lead = l.id_estado_lead
        JOIN crm_origen_lead o ON o.id_origen_lead = l.id_origen_lead
      WHERE l.id_lead = p_id;
  END p_get;

  PROCEDURE p_historial (p_id_lead IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id_lead, fecha_creacion AS fecha, 'Creacion del lead' AS accion
      FROM crm_leads WHERE id_lead = p_id_lead
      UNION ALL
      SELECT id_lead, fecha_actualizacion AS fecha,
             'Actualizacion de estado a ' || estado_nombre AS accion
      FROM crm_leads l
        JOIN crm_estado_lead e ON e.id_estado_lead = l.id_estado_lead
      WHERE l.id_lead = p_id_lead
      ORDER BY fecha;
  END p_historial;

  PROCEDURE p_create (
    p_titulo IN VARCHAR2, p_descripcion IN VARCHAR2,
    p_score IN NUMBER, p_id_estado_lead IN NUMBER,
    p_id_origen_lead IN NUMBER, p_id_usuario IN NUMBER,
    p_nombre_empresa IN VARCHAR2, p_nombre_contacto IN VARCHAR2,
    p_telefono_contacto IN VARCHAR2, p_email_contacto IN VARCHAR2,
    p_id OUT NUMBER
  ) IS
  BEGIN
    INSERT INTO crm_leads (
      titulo, descripcion, score, id_estado_lead, id_origen_lead,
      id_usuario, nombre_empresa, nombre_contacto,
      telefono_contacto, email_contacto
    ) VALUES (
      p_titulo, p_descripcion, p_score, p_id_estado_lead, p_id_origen_lead,
      p_id_usuario, p_nombre_empresa, p_nombre_contacto,
      p_telefono_contacto, p_email_contacto
    ) RETURNING id_lead INTO p_id;
    COMMIT;
  END p_create;

  PROCEDURE p_update (
    p_id IN NUMBER, p_titulo IN VARCHAR2,
    p_descripcion IN VARCHAR2, p_score IN NUMBER,
    p_id_estado_lead IN NUMBER, p_id_origen_lead IN NUMBER,
    p_id_usuario IN NUMBER, p_nombre_empresa IN VARCHAR2,
    p_nombre_contacto IN VARCHAR2, p_telefono_contacto IN VARCHAR2,
    p_email_contacto IN VARCHAR2
  ) IS
  BEGIN
    UPDATE crm_leads SET
      titulo              = p_titulo,
      descripcion         = p_descripcion,
      score               = p_score,
      id_estado_lead      = p_id_estado_lead,
      id_origen_lead      = p_id_origen_lead,
      id_usuario          = p_id_usuario,
      nombre_empresa      = p_nombre_empresa,
      nombre_contacto     = p_nombre_contacto,
      telefono_contacto   = p_telefono_contacto,
      email_contacto      = p_email_contacto
    WHERE id_lead = p_id;
    COMMIT;
  END p_update;

  PROCEDURE p_descalificar (p_id IN NUMBER, p_id_motivo IN NUMBER, p_observacion IN VARCHAR2) IS
  BEGIN
    UPDATE crm_leads SET
      id_estado_lead           = 4,
      id_motivo_descalificacion = p_id_motivo
    WHERE id_lead = p_id;
    COMMIT;
  END p_descalificar;

  PROCEDURE p_convertir (
    p_id_lead IN NUMBER, p_titulo_opp IN VARCHAR2,
    p_id_tipo_opp IN NUMBER, p_id_sector IN NUMBER,
    p_descripcion IN VARCHAR2, p_id_empresa IN NUMBER,
    p_id_usuario IN NUMBER, p_valor_estimado IN NUMBER,
    p_fecha_cierre IN DATE, p_probabilidad IN NUMBER,
    p_id_oportunidad OUT NUMBER
  ) IS
    v_id_estado_opp NUMBER := 1;
  BEGIN
    INSERT INTO crm_oportunidades (
      titulo, descripcion, id_tipo_oportunidad, id_estado_oportunidad,
      valor_estimado, probabilidad_cierre, id_sector, id_empresa,
      fecha_cierre_estimada, id_usuario
    ) VALUES (
      p_titulo_opp, p_descripcion, p_id_tipo_opp, v_id_estado_opp,
      p_valor_estimado, p_probabilidad, p_id_sector, p_id_empresa,
      p_fecha_cierre, p_id_usuario
    ) RETURNING id_oportunidad INTO p_id_oportunidad;

    UPDATE crm_leads SET
      id_estado_lead         = 3,
      id_oportunidad_generada = p_id_oportunidad
    WHERE id_lead = p_id_lead;

    COMMIT;
  END p_convertir;

END pkg_crm_leads;
/
