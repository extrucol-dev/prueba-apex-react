-- =====================================================================
-- 01_leads_tables.sql
-- CRM Leads: tablas, secuencias, triggers
-- =====================================================================

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN (
              'CRM_MOTIVO_DESCALIFICACION','CRM_INTERES',
              'CRM_ORIGEN_LEAD','CRM_ESTADO_LEAD','CRM_LEADS',
              'CRM_LEADS_SEQ','CRM_ESTADO_LEAD_SEQ','CRM_ORIGEN_LEAD_SEQ',
              'CRM_INTERES_SEQ','CRM_MOTIVO_DESC_SEQ'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN (
              'SEQ_CRM_LEADS','SEQ_CRM_ESTADO_LEAD','SEQ_CRM_ORIGEN_LEAD',
              'SEQ_CRM_INTERES','SEQ_CRM_MOTIVO_DESC'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- CRM_ESTADO_LEAD  (tipo: ABIERTO | CALIFICADO | DESCALIFICADO)
-- ---------------------------------------------------------------------
CREATE TABLE crm_estado_lead (
  id_estado_lead     NUMBER PRIMARY KEY,
  nombre             VARCHAR2(60) NOT NULL,
  tipo               VARCHAR2(20) NOT NULL CHECK (tipo IN ('ABIERTO','CALIFICADO','DESCALIFICADO')),
  orden              NUMBER NOT NULL,
  color_hex          VARCHAR2(7) DEFAULT '#3b82f6'
);

CREATE SEQUENCE seq_crm_estado_lead START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_estado_lead_bi
BEFORE INSERT ON crm_estado_lead FOR EACH ROW
BEGIN
  IF :new.id_estado_lead IS NULL THEN
    :new.id_estado_lead := seq_crm_estado_lead.NEXTVAL;
  END IF;
END;
/

-- catalogo inicial (4 estados kanban)
INSERT INTO crm_estado_lead (id_estado_lead, nombre, tipo, orden, color_hex)
VALUES (1, 'Nuevo',         'ABIERTO',        1, '#3b82f6');
INSERT INTO crm_estado_lead (id_estado_lead, nombre, tipo, orden, color_hex)
VALUES (2, 'Contactado',    'ABIERTO',        2, '#f59e0b');
INSERT INTO crm_estado_lead (id_estado_lead, nombre, tipo, orden, color_hex)
VALUES (3, 'Calificado',    'CALIFICADO',     3, '#10b981');
INSERT INTO crm_estado_lead (id_estado_lead, nombre, tipo, orden, color_hex)
VALUES (4, 'Descalificado', 'DESCALIFICADO',  4, '#ef4444');

-- ---------------------------------------------------------------------
-- CRM_ORIGEN_LEAD
-- ---------------------------------------------------------------------
CREATE TABLE crm_origen_lead (
  id_origen_lead  NUMBER PRIMARY KEY,
  nombre          VARCHAR2(60) NOT NULL,
  color_hex       VARCHAR2(7) DEFAULT '#6366f1'
);

CREATE SEQUENCE seq_crm_origen_lead START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_origen_lead_bi
BEFORE INSERT ON crm_origen_lead FOR EACH ROW
BEGIN
  IF :new.id_origen_lead IS NULL THEN
    :new.id_origen_lead := seq_crm_origen_lead.NEXTVAL;
  END IF;
END;
/

INSERT INTO crm_origen_lead (id_origen_lead, nombre, color_hex)
VALUES (1, 'Web',             '#6366f1');
INSERT INTO crm_origen_lead (id_origen_lead, nombre, color_hex)
VALUES (2, 'Referido',        '#f59e0b');
INSERT INTO crm_origen_lead (id_origen_lead, nombre, color_hex)
VALUES (3, 'Llamada fria',    '#64748b');
INSERT INTO crm_origen_lead (id_origen_lead, nombre, color_hex)
VALUES (4, 'Feria comercial', '#ec4899');
INSERT INTO crm_origen_lead (id_origen_lead, nombre, color_hex)
VALUES (5, 'WhatsApp',        '#22c55e');
INSERT INTO crm_origen_lead (id_origen_lead, nombre, color_hex)
VALUES (6, 'Instagram',       '#a855f7');

-- ---------------------------------------------------------------------
-- CRM_INTERES
-- ---------------------------------------------------------------------
CREATE TABLE crm_interes (
  id_interes  NUMBER PRIMARY KEY,
  nombre      VARCHAR2(120) NOT NULL
);

CREATE SEQUENCE seq_crm_interes START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_interes_bi
BEFORE INSERT ON crm_interes FOR EACH ROW
BEGIN
  IF :new.id_interes IS NULL THEN
    :new.id_interes := seq_crm_interes.NEXTVAL;
  END IF;
END;
/

INSERT INTO crm_interes (id_interes, nombre) VALUES (1, 'Perfiles estructurales');
INSERT INTO crm_interes (id_interes, nombre) VALUES (2, 'Tuberia PVC');
INSERT INTO crm_interes (id_interes, nombre) VALUES (3, 'Tuberia CPVC');
INSERT INTO crm_interes (id_interes, nombre) VALUES (4, 'Accesorios PE');
INSERT INTO crm_interes (id_interes, nombre) VALUES (5, 'Valvulas');
INSERT INTO crm_interes (id_interes, nombre) VALUES (6, 'Riego');

-- ---------------------------------------------------------------------
-- CRM_MOTIVO_DESCALIFICACION
-- ---------------------------------------------------------------------
CREATE TABLE crm_motivo_descalificacion (
  id_motivo_descalificacion  NUMBER PRIMARY KEY,
  nombre                      VARCHAR2(120) NOT NULL
);

CREATE SEQUENCE seq_crm_motivo_desc START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_motivo_desc_bi
BEFORE INSERT ON crm_motivo_descalificacion FOR EACH ROW
BEGIN
  IF :new.id_motivo_descalificacion IS NULL THEN
    :new.id_motivo_descalificacion := seq_crm_motivo_desc.NEXTVAL;
  END IF;
END;
/

INSERT INTO crm_motivo_descalificacion (id_motivo_descalificacion, nombre)
VALUES (1, 'Presupuesto insuficiente');
INSERT INTO crm_motivo_descalificacion (id_motivo_descalificacion, nombre)
VALUES (2, 'No es el decisor');
INSERT INTO crm_motivo_descalificacion (id_motivo_descalificacion, nombre)
VALUES (3, 'No tiene necesidad');
INSERT INTO crm_motivo_descalificacion (id_motivo_descalificacion, nombre)
VALUES (4, 'No responde');
INSERT INTO crm_motivo_descalificacion (id_motivo_descalificacion, nombre)
VALUES (5, 'Trasladado a distribuidor');

-- ---------------------------------------------------------------------
-- CRM_LEADS
-- ---------------------------------------------------------------------
CREATE TABLE crm_leads (
  id_lead                        NUMBER PRIMARY KEY,
  titulo                         VARCHAR2(200) NOT NULL,
  descripcion                    VARCHAR2(1000),
  score                          NUMBER(3) DEFAULT 60 CHECK (score BETWEEN 0 AND 100),
  id_estado_lead                 NUMBER NOT NULL,
  id_origen_lead                 NUMBER NOT NULL,
  nombre_empresa                 VARCHAR2(120),
  nombre_contacto                VARCHAR2(120),
  telefono_contacto              VARCHAR2(20),
  email_contacto                 VARCHAR2(120),
  id_usuario                     NUMBER,
  fecha_creacion                 DATE DEFAULT SYSDATE,
  fecha_actualizacion            DATE DEFAULT SYSDATE,
  id_oportunidad_generada        NUMBER,
  id_motivo_descalificacion      NUMBER,
  CONSTRAINT fk_leads_estado     FOREIGN KEY (id_estado_lead)  REFERENCES crm_estado_lead(id_estado_lead),
  CONSTRAINT fk_leads_origen     FOREIGN KEY (id_origen_lead)  REFERENCES crm_origen_lead(id_origen_lead),
  CONSTRAINT fk_leads_motivo     FOREIGN KEY (id_motivo_descalificacion) REFERENCES crm_motivo_descalificacion(id_motivo_descalificacion)
);

CREATE INDEX ix_leads_estado      ON crm_leads(id_estado_lead);
CREATE INDEX ix_leads_usuario     ON crm_leads(id_usuario);
CREATE INDEX ix_leads_oportunidad ON crm_leads(id_oportunidad_generada);

CREATE SEQUENCE seq_crm_leads START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_leads_bi
BEFORE INSERT ON crm_leads FOR EACH ROW
BEGIN
  IF :new.id_lead IS NULL THEN
    :new.id_lead := seq_crm_leads.NEXTVAL;
  END IF;
  IF :new.fecha_creacion IS NULL THEN
    :new.fecha_creacion := SYSDATE;
  END IF;
  :new.fecha_actualizacion := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_crm_leads_bu
BEFORE UPDATE ON crm_leads FOR EACH ROW
BEGIN
  :new.fecha_actualizacion := SYSDATE;
END;
/

-- ---------------------------------------------------------------------
-- Datos demo
-- ---------------------------------------------------------------------
INSERT INTO crm_leads (id_lead, titulo, descripcion, score, id_estado_lead, id_origen_lead,
  nombre_empresa, nombre_contacto, telefono_contacto, email_contacto, id_usuario,
  fecha_creacion, id_oportunidad_generada, id_motivo_descalificacion)
VALUES (1,
  'Constructora Oikos - perfiles PVC',
  'Interesados en perfiles estructurales para obra nueva.',
  80, 1, 1,
  'Constructora Oikos', 'Jorge Rueda', '3001234567', 'jrueda@oikos.com', 1,
  TO_DATE('2026-04-01','YYYY-MM-DD'), NULL, NULL);

INSERT INTO crm_leads (id_lead, titulo, descripcion, score, id_estado_lead, id_origen_lead,
  nombre_empresa, nombre_contacto, telefono_contacto, email_contacto, id_usuario,
  fecha_creacion, id_oportunidad_generada, id_motivo_descalificacion)
VALUES (2,
  'Ferreteria El Maestro - tuberia',
  'Requieren tuberia PVC para distribucion local.',
  60, 2, 2,
  'Ferreteria El Maestro', 'Maria Lopez', '3109876543', 'mlopez@maestro.co', 1,
  TO_DATE('2026-04-05','YYYY-MM-DD'), NULL, NULL);

INSERT INTO crm_leads (id_lead, titulo, descripcion, score, id_estado_lead, id_origen_lead,
  nombre_empresa, nombre_contacto, telefono_contacto, email_contacto, id_usuario,
  fecha_creacion, id_oportunidad_generada, id_motivo_descalificacion)
VALUES (3,
  'Ingenieria Vital - licitacion 2026',
  'Licitacion publica para tuberia de acueducto municipal.',
  75, 3, 4,
  'Ingenieria Vital', 'Carlos Diaz', '3154567890', 'cdiaz@vital.com.co', 2,
  TO_DATE('2026-03-20','YYYY-MM-DD'), NULL, NULL);

INSERT INTO crm_leads (id_lead, titulo, descripcion, score, id_estado_lead, id_origen_lead,
  nombre_empresa, nombre_contacto, telefono_contacto, email_contacto, id_usuario,
  fecha_creacion, id_oportunidad_generada, id_motivo_descalificacion)
VALUES (4,
  'Grupo Constructor Andino',
  'Proyecto residencial, pero presupuesto no alcanza.',
  15, 4, 3,
  'Grupo Andino', 'Sandra Torres', '3187654321', 'storres@andino.co', 2,
  TO_DATE('2026-03-10','YYYY-MM-DD'), NULL, 1);

COMMIT;

PROMPT === Resumen CRM Leads ===
SELECT 'CRM_ESTADO_LEAD'          AS tabla, COUNT(*) AS filas FROM crm_estado_lead
UNION ALL SELECT 'CRM_ORIGEN_LEAD',      COUNT(*) FROM crm_origen_lead
UNION ALL SELECT 'CRM_INTERES',          COUNT(*) FROM crm_interes
UNION ALL SELECT 'CRM_MOTIVO_DESC',      COUNT(*) FROM crm_motivo_descalificacion
UNION ALL SELECT 'CRM_LEADS',            COUNT(*) FROM crm_leads;
