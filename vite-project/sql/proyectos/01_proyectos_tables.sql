-- =====================================================================
-- 01_proyectos_tables.sql
-- CRM Proyectos: tablas, secuencias, triggers
-- =====================================================================

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN (
              'CRM_PROYECTOS','CRM_HITOS','CRM_ESTADO_PROYECTO',
              'CRM_PROYECTOS_SEQ','CRM_HITOS_SEQ','CRM_ESTADO_PROYECTO_SEQ'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN (
              'SEQ_CRM_PROYECTOS','SEQ_CRM_HITOS','SEQ_CRM_ESTADO_PROYECTO'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- CRM_ESTADO_PROYECTO
-- ---------------------------------------------------------------------
CREATE TABLE crm_estado_proyecto (
  id_estado_proyecto  NUMBER PRIMARY KEY,
  nombre              VARCHAR2(40) NOT NULL,
  color_hex           VARCHAR2(7) DEFAULT '#6366f1'
);

CREATE SEQUENCE seq_crm_estado_proyecto START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_estado_proyecto_bi
BEFORE INSERT ON crm_estado_proyecto FOR EACH ROW
BEGIN
  IF :new.id_estado_proyecto IS NULL THEN
    :new.id_estado_proyecto := seq_crm_estado_proyecto.NEXTVAL;
  END IF;
END;
/

INSERT INTO crm_estado_proyecto (id_estado_proyecto, nombre, color_hex) VALUES (1, 'ACTIVO',    '#10b981');
INSERT INTO crm_estado_proyecto (id_estado_proyecto, nombre, color_hex) VALUES (2, 'PAUSADO',   '#f59e0b');
INSERT INTO crm_estado_proyecto (id_estado_proyecto, nombre, color_hex) VALUES (3, 'FINALIZADO','#6366f1');
INSERT INTO crm_estado_proyecto (id_estado_proyecto, nombre, color_hex) VALUES (4, 'CANCELADO', '#ef4444');

-- ---------------------------------------------------------------------
-- CRM_PROYECTOS
-- ---------------------------------------------------------------------
CREATE TABLE crm_proyectos (
  id_proyecto       NUMBER PRIMARY KEY,
  nombre            VARCHAR2(200) NOT NULL,
  descripcion       VARCHAR2(1000),
  id_estado         NUMBER NOT NULL DEFAULT 1,
  fecha_inicio      DATE,
  fecha_fin         DATE,
  id_oportunidad    NUMBER,
  fecha_creacion    DATE DEFAULT SYSDATE,
  fecha_actualizacion DATE DEFAULT SYSDATE,
  CONSTRAINT fk_proy_estado FOREIGN KEY (id_estado) REFERENCES crm_estado_proyecto(id_estado_proyecto),
  CONSTRAINT fk_proy_opp    FOREIGN KEY (id_oportunidad) REFERENCES crm_oportunidades(id_oportunidad)
);

CREATE INDEX ix_proyectos_estado   ON crm_proyectos(id_estado);
CREATE INDEX ix_proyectos_opp     ON crm_proyectos(id_oportunidad);

CREATE SEQUENCE seq_crm_proyectos START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_proyectos_bi
BEFORE INSERT ON crm_proyectos FOR EACH ROW
BEGIN
  IF :new.id_proyecto IS NULL THEN
    :new.id_proyecto := seq_crm_proyectos.NEXTVAL;
  END IF;
  IF :new.fecha_creacion IS NULL THEN
    :new.fecha_creacion := SYSDATE;
  END IF;
  :new.fecha_actualizacion := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_crm_proyectos_bu
BEFORE UPDATE ON crm_proyectos FOR EACH ROW
BEGIN
  :new.fecha_actualizacion := SYSDATE;
END;
/

-- ---------------------------------------------------------------------
-- CRM_HITOS
-- ---------------------------------------------------------------------
CREATE TABLE crm_hitos (
  id_hito        NUMBER PRIMARY KEY,
  id_proyecto    NUMBER NOT NULL,
  nombre         VARCHAR2(200) NOT NULL,
  descripcion    VARCHAR2(500),
  fecha_limite   DATE,
  completado     CHAR(1) DEFAULT 'N' CHECK (completado IN ('S','N')),
  CONSTRAINT fk_hitos_proyecto FOREIGN KEY (id_proyecto) REFERENCES crm_proyectos(id_proyecto)
);

CREATE INDEX ix_hitos_proyecto ON crm_hitos(id_proyecto);

CREATE SEQUENCE seq_crm_hitos START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_hitos_bi
BEFORE INSERT ON crm_hitos FOR EACH ROW
BEGIN
  IF :new.id_hito IS NULL THEN
    :new.id_hito := seq_crm_hitos.NEXTVAL;
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- Datos demo
-- ---------------------------------------------------------------------
INSERT INTO crm_proyectos (id_proyecto, nombre, descripcion, id_estado, fecha_inicio, fecha_fin, id_oportunidad)
VALUES (1, 'Instalacion perfiles Bogota', 'Suministro e instalacion zona norte', 1,
  TO_DATE('2026-04-01','YYYY-MM-DD'), TO_DATE('2026-06-30','YYYY-MM-DD'), 1);

INSERT INTO crm_proyectos (id_proyecto, nombre, descripcion, id_estado, fecha_inicio, fecha_fin, id_oportunidad)
VALUES (2, 'Proyecto PVC Medellin', 'Tuberias residenciales barrio nuevo', 2,
  TO_DATE('2026-03-15','YYYY-MM-DD'), TO_DATE('2026-07-15','YYYY-MM-DD'), 2);

INSERT INTO crm_proyectos (id_proyecto, nombre, descripcion, id_estado, fecha_inicio, fecha_fin, id_oportunidad)
VALUES (3, 'Licitacion tuberia industrial', 'Tuberia de alta presion planta', 3,
  TO_DATE('2025-11-01','YYYY-MM-DD'), TO_DATE('2026-04-30','YYYY-MM-DD'), 3);

COMMIT;

PROMPT === Resumen CRM Proyectos ===
SELECT 'CRM_ESTADO_PROYECTO' AS tabla, COUNT(*) AS filas FROM crm_estado_proyecto
UNION ALL SELECT 'CRM_PROYECTOS', COUNT(*) FROM crm_proyectos
UNION ALL SELECT 'CRM_HITOS', COUNT(*) FROM crm_hitos;