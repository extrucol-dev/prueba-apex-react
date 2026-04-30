-- =====================================================================
-- 01_actividades_tables.sql
-- CRM Actividades: tablas, secuencias, triggers
-- =====================================================================

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN (
              'CRM_ACTIVIDADES','CRM_TIPO_ACTIVIDAD',
              'CRM_ACTIVIDADES_SEQ','CRM_TIPO_ACTIVIDAD_SEQ'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN (
              'SEQ_CRM_ACTIVIDADES','SEQ_CRM_TIPO_ACTIVIDAD'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- CRM_TIPO_ACTIVIDAD
-- ---------------------------------------------------------------------
CREATE TABLE crm_tipo_actividad (
  id_tipo_actividad  NUMBER PRIMARY KEY,
  nombre             VARCHAR2(40) NOT NULL,
  color_hex          VARCHAR2(7) DEFAULT '#6366f1'
);

CREATE SEQUENCE seq_crm_tipo_actividad START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_tipo_actividad_bi
BEFORE INSERT ON crm_tipo_actividad FOR EACH ROW
BEGIN
  IF :new.id_tipo_actividad IS NULL THEN
    :new.id_tipo_actividad := seq_crm_tipo_actividad.NEXTVAL;
  END IF;
END;
/

INSERT INTO crm_tipo_actividad (id_tipo_actividad, nombre, color_hex) VALUES (1, 'Llamada',   '#3b82f6');
INSERT INTO crm_tipo_actividad (id_tipo_actividad, nombre, color_hex) VALUES (2, 'Visita',    '#10b981');
INSERT INTO crm_tipo_actividad (id_tipo_actividad, nombre, color_hex) VALUES (3, 'Reunion',   '#f59e0b');
INSERT INTO crm_tipo_actividad (id_tipo_actividad, nombre, color_hex) VALUES (4, 'Email',     '#6366f1');
INSERT INTO crm_tipo_actividad (id_tipo_actividad, nombre, color_hex) VALUES (5, 'Demo',      '#ec4899');

-- ---------------------------------------------------------------------
-- CRM_ACTIVIDADES
-- ---------------------------------------------------------------------
CREATE TABLE crm_actividades (
  id_actividad       NUMBER PRIMARY KEY,
  tipo               VARCHAR2(40) NOT NULL,
  asunto             VARCHAR2(200) NOT NULL,
  descripcion        VARCHAR2(500),
  fecha              DATE DEFAULT SYSDATE NOT NULL,
  virtual            CHAR(1) DEFAULT 'N' CHECK (virtual IN ('S','N')),
  completada         CHAR(1) DEFAULT 'N' CHECK (completada IN ('S','N')),
  id_lead            NUMBER,
  id_oportunidad     NUMBER,
  id_usuario         NUMBER,
  resultado          VARCHAR2(500),
  latitud            NUMBER(10,6),
  longitud           NUMBER(10,6),
  fecha_creacion     DATE DEFAULT SYSDATE,
  CONSTRAINT fk_act_lead        FOREIGN KEY (id_lead)       REFERENCES crm_leads(id_lead),
  CONSTRAINT fk_act_oportunidad FOREIGN KEY (id_oportunidad) REFERENCES crm_oportunidades(id_oportunidad)
);

CREATE INDEX ix_actividades_lead    ON crm_actividades(id_lead);
CREATE INDEX ix_actividades_opp     ON crm_actividades(id_oportunidad);
CREATE INDEX ix_actividades_usuario ON crm_actividades(id_usuario);
CREATE INDEX ix_actividades_fecha   ON crm_actividades(fecha);

CREATE SEQUENCE seq_crm_actividades START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_actividades_bi
BEFORE INSERT ON crm_actividades FOR EACH ROW
BEGIN
  IF :new.id_actividad IS NULL THEN
    :new.id_actividad := seq_crm_actividades.NEXTVAL;
  END IF;
  IF :new.fecha_creacion IS NULL THEN
    :new.fecha_creacion := SYSDATE;
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- Datos demo
-- ---------------------------------------------------------------------
INSERT INTO crm_actividades (id_actividad, tipo, asunto, descripcion, fecha, virtual, completada, id_oportunidad, id_usuario, resultado)
VALUES (1, 'Llamada', 'Seguimiento propuesta PVC', 'Llamada de seguimiento', TO_DATE('2026-05-02','YYYY-MM-DD'), 'N', 'N', 2, 1, NULL);

INSERT INTO crm_actividades (id_actividad, tipo, asunto, descripcion, fecha, virtual, completada, id_oportunidad, id_usuario, resultado)
VALUES (2, 'Visita', 'Presentacion portafolio', 'Visita presencial', TO_DATE('2026-05-05','YYYY-MM-DD'), 'N', 'N', 1, 1, NULL);

INSERT INTO crm_actividades (id_actividad, tipo, asunto, descripcion, fecha, virtual, completada, id_oportunidad, id_usuario, resultado)
VALUES (3, 'Reunion', 'Revision propuesta tecnica', 'Reunion virtual', TO_DATE('2026-04-28','YYYY-MM-DD'), 'S', 'S', 3, 2, 'Cliente interesado en continuar');

INSERT INTO crm_actividades (id_actividad, tipo, asunto, descripcion, fecha, virtual, completada, id_oportunidad, id_usuario, resultado)
VALUES (4, 'Email', 'Envio cotizacion oficial', 'Cotizacion enviada por email', TO_DATE('2026-04-25','YYYY-MM-DD'), 'S', 'S', 1, 1, 'Cotizacion aceptada');

INSERT INTO crm_actividades (id_actividad, tipo, asunto, descripcion, fecha, virtual, completada, id_oportunidad, id_usuario, resultado)
VALUES (5, 'Llamada', 'Segunda llamada seguimiento', 'Sin respuesta anterior', TO_DATE('2026-04-20','YYYY-MM-DD'), 'N', 'N', 2, 1, NULL);

COMMIT;

PROMPT === Resumen CRM Actividades ===
SELECT 'CRM_TIPO_ACTIVIDAD' AS tabla, COUNT(*) AS filas FROM crm_tipo_actividad
UNION ALL SELECT 'CRM_ACTIVIDADES', COUNT(*) FROM crm_actividades;