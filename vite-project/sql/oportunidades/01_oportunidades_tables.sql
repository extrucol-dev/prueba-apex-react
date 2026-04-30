-- =====================================================================
-- 01_oportunidades_tables.sql
-- CRM Oportunidades: tablas, secuencias, triggers
-- =====================================================================

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN (
              'CRM_MOTIVO_CIERRE','CRM_OPORTUNIDADES_ACTIVIDADES',
              'CRM_OPORTUNIDADES','CRM_ESTADO_OPORTUNIDAD',
              'CRM_TIPO_OPORTUNIDAD','CRM_SECTOR',
              'SEQ_CRM_OPORTUNIDADES','SEQ_CRM_ESTADO_OPP',
              'SEQ_CRM_TIPO_OPP','SEQ_CRM_SECTOR','SEQ_CRM_MOTIVO_CIERRE',
              'SEQ_CRM_OPP_ACTIVIDADES'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN (
              'SEQ_CRM_OPORTUNIDADES','SEQ_CRM_ESTADO_OPP',
              'SEQ_CRM_TIPO_OPP','SEQ_CRM_SECTOR','SEQ_CRM_MOTIVO_CIERRE',
              'SEQ_CRM_OPP_ACTIVIDADES'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- CRM_SECTOR
-- ---------------------------------------------------------------------
CREATE TABLE crm_sector (
  id_sector  NUMBER PRIMARY KEY,
  nombre     VARCHAR2(80) NOT NULL
);

CREATE SEQUENCE seq_crm_sector START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_sector_bi
BEFORE INSERT ON crm_sector FOR EACH ROW
BEGIN
  IF :new.id_sector IS NULL THEN :new.id_sector := seq_crm_sector.NEXTVAL; END IF;
END;
/

INSERT INTO crm_sector (id_sector, nombre) VALUES (1, 'Construccion');
INSERT INTO crm_sector (id_sector, nombre) VALUES (2, 'Industrial');
INSERT INTO crm_sector (id_sector, nombre) VALUES (3, 'Residencial');
INSERT INTO crm_sector (id_sector, nombre) VALUES (4, 'Infraestructura');
INSERT INTO crm_sector (id_sector, nombre) VALUES (5, 'Agricultura');
INSERT INTO crm_sector (id_sector, nombre) VALUES (6, 'Comercial');

-- ---------------------------------------------------------------------
-- CRM_TIPO_OPORTUNIDAD
-- ---------------------------------------------------------------------
CREATE TABLE crm_tipo_oportunidad (
  id_tipo_oportunidad  NUMBER PRIMARY KEY,
  nombre               VARCHAR2(60) NOT NULL
);

CREATE SEQUENCE seq_crm_tipo_opp START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_tipo_opp_bi
BEFORE INSERT ON crm_tipo_oportunidad FOR EACH ROW
BEGIN
  IF :new.id_tipo_oportunidad IS NULL THEN :new.id_tipo_oportunidad := seq_crm_tipo_opp.NEXTVAL; END IF;
END;
/

INSERT INTO crm_tipo_oportunidad (id_tipo_oportunidad, nombre) VALUES (1, 'Nuevo negocio');
INSERT INTO crm_tipo_oportunidad (id_tipo_oportunidad, nombre) VALUES (2, 'Expansion');
INSERT INTO crm_tipo_oportunidad (id_tipo_oportunidad, nombre) VALUES (3, 'Renovacion');
INSERT INTO crm_tipo_oportunidad (id_tipo_oportunidad, nombre) VALUES (4, 'Licitacion');

-- ---------------------------------------------------------------------
-- CRM_ESTADO_OPORTUNIDAD  (tipo: ABIERTO | CERRADO_GANADO | CERRADO_PERDIDO)
-- ---------------------------------------------------------------------
CREATE TABLE crm_estado_oportunidad (
  id_estado_oportunidad  NUMBER PRIMARY KEY,
  nombre                 VARCHAR2(60) NOT NULL,
  tipo                   VARCHAR2(20) NOT NULL CHECK (tipo IN ('ABIERTO','CERRADO_GANADO','CERRADO_PERDIDO')),
  orden                  NUMBER NOT NULL
);

CREATE SEQUENCE seq_crm_estado_opp START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_estado_opp_bi
BEFORE INSERT ON crm_estado_oportunidad FOR EACH ROW
BEGIN
  IF :new.id_estado_oportunidad IS NULL THEN :new.id_estado_oportunidad := seq_crm_estado_opp.NEXTVAL; END IF;
END;
/

INSERT INTO crm_estado_oportunidad (id_estado_oportunidad, nombre, tipo, orden)
VALUES (1, 'Prospecto',     'ABIERTO',          1);
INSERT INTO crm_estado_oportunidad (id_estado_oportunidad, nombre, tipo, orden)
VALUES (2, 'Calificacion',  'ABIERTO',          2);
INSERT INTO crm_estado_oportunidad (id_estado_oportunidad, nombre, tipo, orden)
VALUES (3, 'Propuesta',     'ABIERTO',          3);
INSERT INTO crm_estado_oportunidad (id_estado_oportunidad, nombre, tipo, orden)
VALUES (4, 'Negociacion',   'ABIERTO',          4);
INSERT INTO crm_estado_oportunidad (id_estado_oportunidad, nombre, tipo, orden)
VALUES (5, 'Ganada',        'CERRADO_GANADO',   5);
INSERT INTO crm_estado_oportunidad (id_estado_oportunidad, nombre, tipo, orden)
VALUES (6, 'Perdida',       'CERRADO_PERDIDO',  6);

-- ---------------------------------------------------------------------
-- CRM_MOTIVO_CIERRE
-- ---------------------------------------------------------------------
CREATE TABLE crm_motivo_cierre (
  id_motivo_cierre  NUMBER PRIMARY KEY,
  tipo              VARCHAR2(20) NOT NULL CHECK (tipo IN ('GANADA','PERDIDA')),
  nombre            VARCHAR2(120) NOT NULL
);

CREATE SEQUENCE seq_crm_motivo_cierre START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_motivo_cierre_bi
BEFORE INSERT ON crm_motivo_cierre FOR EACH ROW
BEGIN
  IF :new.id_motivo_cierre IS NULL THEN :new.id_motivo_cierre := seq_crm_motivo_cierre.NEXTVAL; END IF;
END;
/

INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (1, 'GANADA',  'Proyecto ganado');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (2, 'GANADA',  'Licitacion adjudicada');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (3, 'GANADA',  'Renovacion de contrato');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (4, 'PERDIDA', 'Presupuesto insuficiente');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (5, 'PERDIDA', 'Competidor con menor precio');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (6, 'PERDIDA', 'No cumple requisitos tecnicos');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (7, 'PERDIDA', 'Cliente no responde');
INSERT INTO crm_motivo_cierre (id_motivo_cierre, tipo, nombre) VALUES (8, 'PERDIDA', 'Proyecto cancelado');

-- ---------------------------------------------------------------------
-- CRM_OPORTUNIDADES
-- ---------------------------------------------------------------------
CREATE TABLE crm_oportunidades (
  id_oportunidad          NUMBER PRIMARY KEY,
  titulo                  VARCHAR2(200) NOT NULL,
  descripcion             VARCHAR2(1000),
  id_tipo_oportunidad     NUMBER NOT NULL,
  id_estado_oportunidad   NUMBER NOT NULL,
  valor_estimado          NUMBER(14,2),
  probabilidad_cierre     NUMBER(3) DEFAULT 50 CHECK (probabilidad_cierre BETWEEN 0 AND 100),
  id_sector               NUMBER,
  id_empresa              NUMBER,
  fecha_cierre_estimada   DATE,
  fecha_creacion          DATE DEFAULT SYSDATE,
  fecha_actualizacion     DATE DEFAULT SYSDATE,
  id_usuario              NUMBER,
  valor_final             NUMBER(14,2),
  id_motivo_cierre        NUMBER,
  observacion_cierre      VARCHAR2(500),
  CONSTRAINT fk_opp_estado    FOREIGN KEY (id_estado_oportunidad) REFERENCES crm_estado_oportunidad(id_estado_oportunidad),
  CONSTRAINT fk_opp_tipo       FOREIGN KEY (id_tipo_oportunidad)   REFERENCES crm_tipo_oportunidad(id_tipo_oportunidad),
  CONSTRAINT fk_opp_sector     FOREIGN KEY (id_sector)             REFERENCES crm_sector(id_sector),
  CONSTRAINT fk_opp_motivo     FOREIGN KEY (id_motivo_cierre)      REFERENCES crm_motivo_cierre(id_motivo_cierre)
);

CREATE INDEX ix_opp_estado    ON crm_oportunidades(id_estado_oportunidad);
CREATE INDEX ix_opp_usuario   ON crm_oportunidades(id_usuario);
CREATE INDEX ix_opp_fecha_cierre ON crm_oportunidades(fecha_cierre_estimada);

CREATE SEQUENCE seq_crm_oportunidades START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_oportunidades_bi
BEFORE INSERT ON crm_oportunidades FOR EACH ROW
BEGIN
  IF :new.id_oportunidad IS NULL THEN :new.id_oportunidad := seq_crm_oportunidades.NEXTVAL; END IF;
  IF :new.fecha_creacion IS NULL THEN :new.fecha_creacion := SYSDATE; END IF;
  :new.fecha_actualizacion := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER trg_crm_oportunidades_bu
BEFORE UPDATE ON crm_oportunidades FOR EACH ROW
BEGIN
  :new.fecha_actualizacion := SYSDATE;
END;
/

-- ---------------------------------------------------------------------
-- CRM_OPORTUNIDADES_ACTIVIDADES
-- ---------------------------------------------------------------------
CREATE TABLE crm_oportunidades_actividades (
  id_actividad      NUMBER PRIMARY KEY,
  id_oportunidad    NUMBER NOT NULL,
  tipo_actividad    VARCHAR2(40) NOT NULL,
  descripcion       VARCHAR2(500),
  fecha_actividad   DATE DEFAULT SYSDATE,
  id_usuario        NUMBER
);

CREATE INDEX ix_opp_act_opp  ON crm_oportunidades_actividades(id_oportunidad);

CREATE SEQUENCE seq_crm_opp_actividades START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_opp_actividades_bi
BEFORE INSERT ON crm_oportunidades_actividades FOR EACH ROW
BEGIN
  IF :new.id_actividad IS NULL THEN :new.id_actividad := seq_crm_opp_actividades.NEXTVAL; END IF;
END;
/

-- ---------------------------------------------------------------------
-- Productos (catalogo paraOPP_PRODUCTOS_CATALOGO)
-- ---------------------------------------------------------------------
CREATE TABLE crm_productos_opp (
  id_producto         NUMBER PRIMARY KEY,
  nombre              VARCHAR2(120) NOT NULL,
  precio_referencia   NUMBER(12,2)
);

CREATE SEQUENCE seq_crm_productos_opp START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_productos_opp_bi
BEFORE INSERT ON crm_productos_opp FOR EACH ROW
BEGIN
  IF :new.id_producto IS NULL THEN :new.id_producto := seq_crm_productos_opp.NEXTVAL; END IF;
END;
/

INSERT INTO crm_productos_opp (id_producto, nombre, precio_referencia) VALUES (1, 'Perfil U 40x40', 15000);
INSERT INTO crm_productos_opp (id_producto, nombre, precio_referencia) VALUES (2, 'Tubo PVC 4"', 8500);
INSERT INTO crm_productos_opp (id_producto, nombre, precio_referencia) VALUES (3, 'Perfil L 50x50', 18000);
INSERT INTO crm_productos_opp (id_producto, nombre, precio_referencia) VALUES (4, 'Tuberia CPVC 1"', 12000);

-- ---------------------------------------------------------------------
-- Datos demo
-- ---------------------------------------------------------------------
INSERT INTO crm_oportunidades (id_oportunidad, titulo, descripcion, id_tipo_oportunidad,
  id_estado_oportunidad, valor_estimado, probabilidad_cierre, id_sector,
  fecha_cierre_estimada, id_usuario)
VALUES (1,
  'Suministro perfiles estructurales', 'Proyecto para obra de construccion en Bogota',
  1, 1, 45000000, 70, 1,
  TO_DATE('2026-06-30','YYYY-MM-DD'), 1);

INSERT INTO crm_oportunidades (id_oportunidad, titulo, descripcion, id_tipo_oportunidad,
  id_estado_oportunidad, valor_estimado, probabilidad_cierre, id_sector,
  fecha_cierre_estimada, id_usuario)
VALUES (2,
  'Proyecto PVC residencial Medellin', 'Instalacion de perfiles PVC en conjunto residencial',
  2, 2, 28000000, 50, 3,
  TO_DATE('2026-07-15','YYYY-MM-DD'), 1);

INSERT INTO crm_oportunidades (id_oportunidad, titulo, descripcion, id_tipo_oportunidad,
  id_estado_oportunidad, valor_estimado, probabilidad_cierre, id_sector,
  fecha_cierre_estimada, id_usuario)
VALUES (3,
  'Licitacion tuberia industrial', 'Provision de tuberia para proyecto de infraestructura',
  4, 3, 120000000, 30, 4,
  TO_DATE('2026-05-20','YYYY-MM-DD'), 2);

INSERT INTO crm_oportunidades (id_oportunidad, titulo, descripcion, id_tipo_oportunidad,
  id_estado_oportunidad, valor_estimado, probabilidad_cierre, id_sector,
  fecha_cierre_estimada, id_usuario)
VALUES (4,
  'Renovacion contrato anual', 'Renovacion de suministro anual con cliente existente',
  3, 4, 65000000, 80, 2,
  TO_DATE('2026-05-10','YYYY-MM-DD'), 2);

COMMIT;

PROMPT === Resumen CRM Oportunidades ===
SELECT 'CRM_SECTOR'              AS tabla, COUNT(*) AS filas FROM crm_sector
UNION ALL SELECT 'CRM_TIPO_OPORTUNIDAD',  COUNT(*) FROM crm_tipo_oportunidad
UNION ALL SELECT 'CRM_ESTADO_OPORTUNIDAD',COUNT(*) FROM crm_estado_oportunidad
UNION ALL SELECT 'CRM_MOTIVO_CIERRE',     COUNT(*) FROM crm_motivo_cierre
UNION ALL SELECT 'CRM_OPORTUNIDADES',     COUNT(*) FROM crm_oportunidades
UNION ALL SELECT 'CRM_OPP_ACTIVIDADES',  COUNT(*) FROM crm_oportunidades_actividades
UNION ALL SELECT 'CRM_PRODUCTOS_OPP',    COUNT(*) FROM crm_productos_opp;
