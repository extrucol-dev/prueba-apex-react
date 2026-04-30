-- =====================================================================
-- 01_usuarios_tables.sql
-- CRM Usuarios: tablas, secuencias, triggers
-- =====================================================================

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN (
              'CRM_USUARIOS','CRM_DEPARTAMENTO',
              'CRM_USUARIOS_SEQ','CRM_DEPARTAMENTO_SEQ'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN (
              'SEQ_CRM_USUARIOS','SEQ_CRM_DEPARTAMENTO'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- CRM_DEPARTAMENTO
-- ---------------------------------------------------------------------
CREATE TABLE crm_departamento (
  id_departamento  NUMBER PRIMARY KEY,
  nombre            VARCHAR2(80) NOT NULL
);

CREATE SEQUENCE seq_crm_departamento START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_departamento_bi
BEFORE INSERT ON crm_departamento FOR EACH ROW
BEGIN
  IF :new.id_departamento IS NULL THEN
    :new.id_departamento := seq_crm_departamento.NEXTVAL;
  END IF;
END;
/

INSERT INTO crm_departamento (id_departamento, nombre) VALUES (1, 'Ventas');
INSERT INTO crm_departamento (id_departamento, nombre) VALUES (2, 'Coordinacion');
INSERT INTO crm_departamento (id_departamento, nombre) VALUES (3, 'Direccion');
INSERT INTO crm_departamento (id_departamento, nombre) VALUES (4, 'Administracion');

-- ---------------------------------------------------------------------
-- CRM_USUARIOS
-- ---------------------------------------------------------------------
CREATE TABLE crm_usuarios (
  id_usuario       NUMBER PRIMARY KEY,
  nombre           VARCHAR2(120) NOT NULL,
  email            VARCHAR2(120) NOT NULL,
  rol              VARCHAR2(20) NOT NULL CHECK (rol IN ('EJECUTIVO','COORDINADOR','DIRECTOR','ADMIN')),
  activo           CHAR(1) DEFAULT 'S' CHECK (activo IN ('S','N')),
  id_departamento  NUMBER,
  fecha_creacion    DATE DEFAULT SYSDATE,
  CONSTRAINT fk_usuarios_depto FOREIGN KEY (id_departamento) REFERENCES crm_departamento(id_departamento)
);

CREATE INDEX ix_usuarios_rol      ON crm_usuarios(rol);
CREATE INDEX ix_usuarios_depto    ON crm_usuarios(id_departamento);
CREATE INDEX ix_usuarios_activo   ON crm_usuarios(activo);

CREATE SEQUENCE seq_crm_usuarios START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_crm_usuarios_bi
BEFORE INSERT ON crm_usuarios FOR EACH ROW
BEGIN
  IF :new.id_usuario IS NULL THEN
    :new.id_usuario := seq_crm_usuarios.NEXTVAL;
  END IF;
  IF :new.fecha_creacion IS NULL THEN
    :new.fecha_creacion := SYSDATE;
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- Datos demo
-- ---------------------------------------------------------------------
INSERT INTO crm_usuarios (id_usuario, nombre, email, rol, activo, id_departamento)
VALUES (1, 'Ana Martinez',  'ana@extrucol.com',    'EJECUTIVO',   'S', 1);

INSERT INTO crm_usuarios (id_usuario, nombre, email, rol, activo, id_departamento)
VALUES (2, 'Luis Perez',    'luis@extrucol.com',   'EJECUTIVO',   'S', 1);

INSERT INTO crm_usuarios (id_usuario, nombre, email, rol, activo, id_departamento)
VALUES (3, 'Carlos Ruiz',   'carlos@extrucol.com', 'COORDINADOR', 'S', 2);

INSERT INTO crm_usuarios (id_usuario, nombre, email, rol, activo, id_departamento)
VALUES (4, 'Sofia Diaz',    'sofia@extrucol.com',  'DIRECTOR',    'S', 3);

INSERT INTO crm_usuarios (id_usuario, nombre, email, rol, activo, id_departamento)
VALUES (5, 'Admin Sistema', 'admin@extrucol.com',  'ADMIN',       'S', 4);

COMMIT;

PROMPT === Resumen CRM Usuarios ===
SELECT 'CRM_DEPARTAMENTO' AS tabla, COUNT(*) AS filas FROM crm_departamento
UNION ALL SELECT 'CRM_USUARIOS', COUNT(*) FROM crm_usuarios;