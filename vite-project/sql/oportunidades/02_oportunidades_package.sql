-- =====================================================================
-- 02_oportunidades_package.sql
-- pkg_crm_oportunidades: package + body para CRUD de oportunidades
-- =====================================================================

CREATE OR REPLACE PACKAGE pkg_crm_oportunidades AS
  PROCEDURE p_list             (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_get              (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_actividades      (p_id_oportunidad IN NUMBER, p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_catalogos        (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_productos        (p_cursor OUT SYS_REFCURSOR);
  PROCEDURE p_create           (p_titulo IN VARCHAR2, p_descripcion IN VARCHAR2,
                                 p_id_tipo_opp IN NUMBER, p_id_estado_opp IN NUMBER,
                                 p_valor_estimado IN NUMBER, p_probabilidad IN NUMBER,
                                 p_id_sector IN NUMBER, p_id_empresa IN NUMBER,
                                 p_fecha_cierre IN DATE, p_id_usuario IN NUMBER,
                                 p_id OUT NUMBER);
  PROCEDURE p_update           (p_id IN NUMBER, p_titulo IN VARCHAR2,
                                 p_descripcion IN VARCHAR2, p_id_tipo_opp IN NUMBER,
                                 p_id_estado_opp IN NUMBER, p_valor_estimado IN NUMBER,
                                 p_probabilidad IN NUMBER, p_id_sector IN NUMBER,
                                 p_id_empresa IN NUMBER, p_fecha_cierre IN DATE);
  PROCEDURE p_avanzar_estado   (p_id IN NUMBER, p_id_estado_nuevo IN NUMBER,
                                 p_comentario IN VARCHAR2);
  PROCEDURE p_cerrar_ganada    (p_id IN NUMBER, p_valor_final IN NUMBER,
                                 p_id_motivo IN NUMBER, p_descripcion IN VARCHAR2);
  PROCEDURE p_cerrar_perdida   (p_id IN NUMBER, p_id_motivo IN NUMBER,
                                 p_descripcion IN VARCHAR2);
  PROCEDURE p_estancados       (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR);
END pkg_crm_oportunidades;
/

CREATE OR REPLACE PACKAGE BODY pkg_crm_oportunidades AS

  PROCEDURE p_list (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    IF p_id_usuario IS NULL THEN
      OPEN p_cursor FOR
        SELECT o.id_oportunidad, o.titulo, o.descripcion,
               o.id_tipo_oportunidad, t.nombre AS tipo_nombre,
               o.id_estado_oportunidad, e.nombre AS estado_nombre, e.tipo AS estado_tipo,
               o.valor_estimado, o.probabilidad_cierre,
               o.id_sector, s.nombre AS sector_nombre,
               o.id_empresa, o.fecha_cierre_estimada,
               o.id_usuario, o.fecha_creacion, o.fecha_actualizacion,
               o.valor_final, o.id_motivo_cierre, o.observacion_cierre
        FROM crm_oportunidades o
          JOIN crm_estado_oportunidad e ON e.id_estado_oportunidad = o.id_estado_oportunidad
          JOIN crm_tipo_oportunidad   t ON t.id_tipo_oportunidad   = o.id_tipo_oportunidad
          LEFT JOIN crm_sector s ON s.id_sector = o.id_sector
        ORDER BY o.fecha_creacion DESC;
    ELSE
      OPEN p_cursor FOR
        SELECT o.id_oportunidad, o.titulo, o.descripcion,
               o.id_tipo_oportunidad, t.nombre AS tipo_nombre,
               o.id_estado_oportunidad, e.nombre AS estado_nombre, e.tipo AS estado_tipo,
               o.valor_estimado, o.probabilidad_cierre,
               o.id_sector, s.nombre AS sector_nombre,
               o.id_empresa, o.fecha_cierre_estimada,
               o.id_usuario, o.fecha_creacion, o.fecha_actualizacion,
               o.valor_final, o.id_motivo_cierre, o.observacion_cierre
        FROM crm_oportunidades o
          JOIN crm_estado_oportunidad e ON e.id_estado_oportunidad = o.id_estado_oportunidad
          JOIN crm_tipo_oportunidad   t ON t.id_tipo_oportunidad   = o.id_tipo_oportunidad
          LEFT JOIN crm_sector s ON s.id_sector = o.id_sector
        WHERE o.id_usuario = p_id_usuario
        ORDER BY o.fecha_creacion DESC;
    END IF;
  END p_list;

  PROCEDURE p_get (p_id IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT o.id_oportunidad, o.titulo, o.descripcion,
             o.id_tipo_oportunidad, t.nombre AS tipo_nombre,
             o.id_estado_oportunidad, e.nombre AS estado_nombre, e.tipo AS estado_tipo,
             o.valor_estimado, o.probabilidad_cierre,
             o.id_sector, s.nombre AS sector_nombre,
             o.id_empresa, o.fecha_cierre_estimada,
             o.id_usuario, o.fecha_creacion, o.fecha_actualizacion,
             o.valor_final, o.id_motivo_cierre, o.observacion_cierre
      FROM crm_oportunidades o
        JOIN crm_estado_oportunidad e ON e.id_estado_oportunidad = o.id_estado_oportunidad
        JOIN crm_tipo_oportunidad   t ON t.id_tipo_oportunidad   = o.id_tipo_oportunidad
        LEFT JOIN crm_sector s ON s.id_sector = o.id_sector
      WHERE o.id_oportunidad = p_id;
  END p_get;

  PROCEDURE p_actividades (p_id_oportunidad IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id_actividad, id_oportunidad, tipo_actividad,
             descripcion, TO_CHAR(fecha_actividad,'YYYY-MM-DD HH24:MI') AS fecha_actividad,
             id_usuario
      FROM crm_oportunidades_actividades
      WHERE id_oportunidad = p_id_oportunidad
      ORDER BY fecha_actividad DESC;
  END p_actividades;

  PROCEDURE p_catalogos (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_estado_oportunidad' VALUE e.id_estado_oportunidad,
                      'nombre' VALUE e.nombre,
                      'tipo' VALUE e.tipo)
        ) FROM crm_estado_oportunidad e ORDER BY e.orden) AS estados,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_tipo_oportunidad' VALUE t.id_tipo_oportunidad,
                      'nombre' VALUE t.nombre)
        ) FROM crm_tipo_oportunidad t ORDER BY t.id_tipo_oportunidad) AS tipos,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_sector' VALUE s.id_sector,
                      'nombre' VALUE s.nombre)
        ) FROM crm_sector s ORDER BY s.id_sector) AS sectores,
        (SELECT JSON_ARRAYAGG(
          JSON_OBJECT('id_motivo_cierre' VALUE m.id_motivo_cierre,
                      'tipo' VALUE m.tipo,
                      'nombre' VALUE m.nombre)
        ) FROM crm_motivo_cierre m ORDER BY m.id_motivo_cierre) AS motivos_cierre
      FROM DUAL;
  END p_catalogos;

  PROCEDURE p_productos (p_cursor OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id_producto, nombre, precio_referencia
      FROM crm_productos_opp
      ORDER BY id_producto;
  END p_productos;

  PROCEDURE p_create (
    p_titulo IN VARCHAR2, p_descripcion IN VARCHAR2,
    p_id_tipo_opp IN NUMBER, p_id_estado_opp IN NUMBER,
    p_valor_estimado IN NUMBER, p_probabilidad IN NUMBER,
    p_id_sector IN NUMBER, p_id_empresa IN NUMBER,
    p_fecha_cierre IN DATE, p_id_usuario IN NUMBER,
    p_id OUT NUMBER
  ) IS
  BEGIN
    INSERT INTO crm_oportunidades (
      titulo, descripcion, id_tipo_oportunidad, id_estado_oportunidad,
      valor_estimado, probabilidad_cierre, id_sector, id_empresa,
      fecha_cierre_estimada, id_usuario
    ) VALUES (
      p_titulo, p_descripcion, p_id_tipo_opp, p_id_estado_opp,
      p_valor_estimado, p_probabilidad, p_id_sector, p_id_empresa,
      p_fecha_cierre, p_id_usuario
    ) RETURNING id_oportunidad INTO p_id;
    COMMIT;
  END p_create;

  PROCEDURE p_update (
    p_id IN NUMBER, p_titulo IN VARCHAR2,
    p_descripcion IN VARCHAR2, p_id_tipo_opp IN NUMBER,
    p_id_estado_opp IN NUMBER, p_valor_estimado IN NUMBER,
    p_probabilidad IN NUMBER, p_id_sector IN NUMBER,
    p_id_empresa IN NUMBER, p_fecha_cierre IN DATE
  ) IS
  BEGIN
    UPDATE crm_oportunidades SET
      titulo                = p_titulo,
      descripcion           = p_descripcion,
      id_tipo_oportunidad   = p_id_tipo_opp,
      id_estado_oportunidad = p_id_estado_opp,
      valor_estimado        = p_valor_estimado,
      probabilidad_cierre   = p_probabilidad,
      id_sector             = p_id_sector,
      id_empresa            = p_id_empresa,
      fecha_cierre_estimada = p_fecha_cierre
    WHERE id_oportunidad = p_id;
    COMMIT;
  END p_update;

  PROCEDURE p_avanzar_estado (
    p_id IN NUMBER, p_id_estado_nuevo IN NUMBER,
    p_comentario IN VARCHAR2
  ) IS
  BEGIN
    UPDATE crm_oportunidades SET id_estado_oportunidad = p_id_estado_nuevo
    WHERE id_oportunidad = p_id;

    INSERT INTO crm_oportunidades_actividades (id_oportunidad, tipo_actividad, descripcion)
    VALUES (p_id, 'CAMBIO_ESTADO', p_comentario);

    COMMIT;
  END p_avanzar_estado;

  PROCEDURE p_cerrar_ganada (
    p_id IN NUMBER, p_valor_final IN NUMBER,
    p_id_motivo IN NUMBER, p_descripcion IN VARCHAR2
  ) IS
  BEGIN
    UPDATE crm_oportunidades SET
      id_estado_oportunidad = 5,
      valor_final           = p_valor_final,
      id_motivo_cierre      = p_id_motivo,
      observacion_cierre    = p_descripcion,
      probabilidad_cierre   = 100
    WHERE id_oportunidad = p_id;

    INSERT INTO crm_oportunidades_actividades (id_oportunidad, tipo_actividad, descripcion)
    VALUES (p_id, 'CIERRE_GANADA', p_descripcion);

    COMMIT;
  END p_cerrar_ganada;

  PROCEDURE p_cerrar_perdida (
    p_id IN NUMBER, p_id_motivo IN NUMBER,
    p_descripcion IN VARCHAR2
  ) IS
  BEGIN
    UPDATE crm_oportunidades SET
      id_estado_oportunidad = 6,
      id_motivo_cierre      = p_id_motivo,
      observacion_cierre    = p_descripcion,
      probabilidad_cierre   = 0
    WHERE id_oportunidad = p_id;

    INSERT INTO crm_oportunidades_actividades (id_oportunidad, tipo_actividad, descripcion)
    VALUES (p_id, 'CIERRE_PERDIDA', p_descripcion);

    COMMIT;
  END p_cerrar_perdida;

  PROCEDURE p_estancados (p_id_usuario IN NUMBER, p_cursor OUT SYS_REFCURSOR) IS
    v_fecha_limite DATE := TRUNC(SYSDATE) - 30;
  BEGIN
    IF p_id_usuario IS NULL THEN
      OPEN p_cursor FOR
        SELECT o.id_oportunidad, o.titulo, o.estado_nombre, o.fecha_actualizacion
        FROM (
          SELECT oo.id_oportunidad, oo.titulo, e.nombre AS estado_nombre,
                 oo.fecha_actualizacion,
                 ROW_NUMBER() OVER (ORDER BY oo.fecha_actualizacion ASC) AS rn
          FROM crm_oportunidades oo
            JOIN crm_estado_oportunidad e ON e.id_estado_oportunidad = oo.id_estado_oportunidad
          WHERE e.tipo = 'ABIERTO'
            AND oo.fecha_actualizacion < v_fecha_limite
        ) o
        WHERE o.rn <= 10;
    ELSE
      OPEN p_cursor FOR
        SELECT o.id_oportunidad, o.titulo, o.estado_nombre, o.fecha_actualizacion
        FROM (
          SELECT oo.id_oportunidad, oo.titulo, e.nombre AS estado_nombre,
                 oo.fecha_actualizacion,
                 ROW_NUMBER() OVER (ORDER BY oo.fecha_actualizacion ASC) AS rn
          FROM crm_oportunidades oo
            JOIN crm_estado_oportunidad e ON e.id_estado_oportunidad = oo.id_estado_oportunidad
          WHERE e.tipo = 'ABIERTO'
            AND oo.fecha_actualizacion < v_fecha_limite
            AND oo.id_usuario = p_id_usuario
        ) o
        WHERE o.rn <= 10;
    END IF;
  END p_estancados;

END pkg_crm_oportunidades;
/
