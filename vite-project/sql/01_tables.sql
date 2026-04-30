-- =====================================================================
-- 01_tables.sql  (compatible Oracle 11g / 12c / 19c / 21c / 23c)
-- Esquema: VENTAS_DEMO  (ejecutar conectado al usuario/esquema APEX)
-- Crea tablas, secuencias, triggers de PK, FKs y datos de ejemplo.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Limpieza idempotente
-- ---------------------------------------------------------------------
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('DETALLE_VENTAS','VENTAS','PRODUCTOS','CLIENTES','VENDEDORES'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||t.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN ('SEQ_CLIENTES','SEQ_VENDEDORES','SEQ_PRODUCTOS','SEQ_VENTAS','SEQ_DETALLE_VENTAS'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- TABLAS  (PK como NUMBER, se llena via trigger desde la secuencia)
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
  id          NUMBER PRIMARY KEY,
  nombre      VARCHAR2(120) NOT NULL,
  email       VARCHAR2(120),
  ciudad      VARCHAR2(80),
  pais        VARCHAR2(60) DEFAULT 'MX',
  fecha_alta  DATE DEFAULT SYSDATE
);

CREATE TABLE vendedores (
  id           NUMBER PRIMARY KEY,
  nombre       VARCHAR2(120) NOT NULL,
  region       VARCHAR2(60)  NOT NULL,
  meta_mensual NUMBER(12,2) DEFAULT 100000
);

CREATE TABLE productos (
  id         NUMBER PRIMARY KEY,
  nombre     VARCHAR2(120) NOT NULL,
  categoria  VARCHAR2(60)  NOT NULL,
  precio     NUMBER(10,2)  NOT NULL,
  stock      NUMBER(8)     DEFAULT 0,
  activo     CHAR(1)       DEFAULT 'Y' CHECK (activo IN ('Y','N'))
);

CREATE TABLE ventas (
  id           NUMBER PRIMARY KEY,
  cliente_id   NUMBER NOT NULL,
  vendedor_id  NUMBER NOT NULL,
  fecha        DATE   DEFAULT SYSDATE NOT NULL,
  total        NUMBER(12,2) NOT NULL,
  estado       VARCHAR2(20) DEFAULT 'PAGADA'
                 CHECK (estado IN ('PAGADA','PENDIENTE','CANCELADA')),
  CONSTRAINT fk_ventas_cliente   FOREIGN KEY (cliente_id)  REFERENCES clientes(id),
  CONSTRAINT fk_ventas_vendedor  FOREIGN KEY (vendedor_id) REFERENCES vendedores(id)
);

CREATE INDEX ix_ventas_fecha    ON ventas(fecha);
CREATE INDEX ix_ventas_cliente  ON ventas(cliente_id);

CREATE TABLE detalle_ventas (
  id              NUMBER PRIMARY KEY,
  venta_id        NUMBER NOT NULL,
  producto_id     NUMBER NOT NULL,
  cantidad        NUMBER(8)    NOT NULL,
  precio_unitario NUMBER(10,2) NOT NULL,
  subtotal        NUMBER(12,2) NOT NULL,
  CONSTRAINT fk_det_venta    FOREIGN KEY (venta_id)    REFERENCES ventas(id) ON DELETE CASCADE,
  CONSTRAINT fk_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE INDEX ix_det_venta    ON detalle_ventas(venta_id);
CREATE INDEX ix_det_producto ON detalle_ventas(producto_id);

-- ---------------------------------------------------------------------
-- SECUENCIAS
-- ---------------------------------------------------------------------
CREATE SEQUENCE seq_clientes        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_vendedores      START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_productos       START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_ventas          START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_detalle_ventas  START WITH 1 INCREMENT BY 1 NOCACHE;

-- ---------------------------------------------------------------------
-- TRIGGERS  (asignan PK + calculan subtotal)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_clientes_bi
BEFORE INSERT ON clientes FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN :new.id := seq_clientes.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_vendedores_bi
BEFORE INSERT ON vendedores FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN :new.id := seq_vendedores.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_productos_bi
BEFORE INSERT ON productos FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN :new.id := seq_productos.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_ventas_bi
BEFORE INSERT ON ventas FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN :new.id := seq_ventas.NEXTVAL; END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_detalle_ventas_bi
BEFORE INSERT ON detalle_ventas FOR EACH ROW
BEGIN
  IF :new.id IS NULL THEN :new.id := seq_detalle_ventas.NEXTVAL; END IF;
  -- Calculamos el subtotal (sin columnas virtuales para max compatibilidad)
  :new.subtotal := NVL(:new.cantidad,0) * NVL(:new.precio_unitario,0);
END;
/

-- =====================================================================
-- DATOS DE EJEMPLO
-- =====================================================================

-- Vendedores
INSERT INTO vendedores (nombre, region, meta_mensual) VALUES ('Ana Martinez',  'Norte',     150000);
INSERT INTO vendedores (nombre, region, meta_mensual) VALUES ('Luis Perez',    'Sur',       120000);
INSERT INTO vendedores (nombre, region, meta_mensual) VALUES ('Carla Lopez',   'Centro',    180000);
INSERT INTO vendedores (nombre, region, meta_mensual) VALUES ('Jorge Ramirez', 'Occidente', 130000);
INSERT INTO vendedores (nombre, region, meta_mensual) VALUES ('Sofia Diaz',    'Sureste',   110000);

-- Clientes
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Comercial Aurora SA',   'aurora@demo.com',  'Monterrey',   'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Distribuidora Maya',    'maya@demo.com',    'Merida',      'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Industrias Halcon',     'halcon@demo.com',  'CDMX',        'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Grupo Pacifico',        'pacifico@demo.com','Guadalajara', 'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Servicios Andinos',     'andinos@demo.com', 'Puebla',      'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Tecnologias del Sur',   'tsur@demo.com',    'Oaxaca',      'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Mercantil del Bajio',   'bajio@demo.com',   'Queretaro',   'MX');
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES ('Suministros del Golfo', 'golfo@demo.com',   'Veracruz',    'MX');

-- Productos
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Laptop Pro 14',       'Computo',     28999.00, 25);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Monitor 27" 4K',      'Computo',     7990.00,  40);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Teclado Mecanico',    'Accesorios',  1599.00,  120);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Mouse Inalambrico',   'Accesorios',  599.00,   200);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Smartphone X',        'Telefonia',   15990.00, 60);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Audifonos BT',        'Audio',       1299.00,  150);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Bocina Portatil',     'Audio',       899.00,   90);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Tablet 11"',          'Computo',     8990.00,  35);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Impresora Multif.',   'Oficina',     4590.00,  20);
INSERT INTO productos (nombre, categoria, precio, stock) VALUES ('Silla Ergonomica',    'Mobiliario',  3290.00,  15);

COMMIT;

-- ---------------------------------------------------------------------
-- Generador de ventas (ultimos 12 meses, ~250 ventas)
-- ---------------------------------------------------------------------
DECLARE
  v_venta_id    ventas.id%TYPE;
  v_cliente     NUMBER;
  v_vendedor    NUMBER;
  v_fecha       DATE;
  v_total       NUMBER(12,2);
  v_lineas      NUMBER;
  v_prod        NUMBER;
  v_cant        NUMBER;
  v_precio      NUMBER;
  v_estado      VARCHAR2(20);
  v_n_clientes  NUMBER;
  v_n_vendedor  NUMBER;
  v_n_producto  NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_n_clientes FROM clientes;
  SELECT COUNT(*) INTO v_n_vendedor FROM vendedores;
  SELECT COUNT(*) INTO v_n_producto FROM productos;

  FOR i IN 1..250 LOOP
    v_cliente  := TRUNC(DBMS_RANDOM.VALUE(1, v_n_clientes  + 1));
    v_vendedor := TRUNC(DBMS_RANDOM.VALUE(1, v_n_vendedor  + 1));
    v_fecha    := TRUNC(SYSDATE) - TRUNC(DBMS_RANDOM.VALUE(0, 365));
    v_estado   := CASE TRUNC(DBMS_RANDOM.VALUE(0,10))
                    WHEN 0 THEN 'CANCELADA'
                    WHEN 1 THEN 'PENDIENTE'
                    ELSE 'PAGADA'
                  END;

    INSERT INTO ventas (cliente_id, vendedor_id, fecha, total, estado)
    VALUES (v_cliente, v_vendedor, v_fecha, 0, v_estado)
    RETURNING id INTO v_venta_id;

    v_total  := 0;
    v_lineas := TRUNC(DBMS_RANDOM.VALUE(1,5)) + 1;

    FOR j IN 1..v_lineas LOOP
      v_prod := TRUNC(DBMS_RANDOM.VALUE(1, v_n_producto + 1));
      v_cant := TRUNC(DBMS_RANDOM.VALUE(1,6)) + 1;

      SELECT precio INTO v_precio FROM productos WHERE id = v_prod;

      INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario)
      VALUES (v_venta_id, v_prod, v_cant, v_precio);

      v_total := v_total + (v_cant * v_precio);
    END LOOP;

    UPDATE ventas SET total = v_total WHERE id = v_venta_id;
  END LOOP;

  COMMIT;
END;
/

PROMPT === Resumen de carga ===
SELECT 'CLIENTES'       AS tabla, COUNT(*) AS filas FROM clientes
UNION ALL SELECT 'VENDEDORES',     COUNT(*) FROM vendedores
UNION ALL SELECT 'PRODUCTOS',      COUNT(*) FROM productos
UNION ALL SELECT 'VENTAS',         COUNT(*) FROM ventas
UNION ALL SELECT 'DETALLE_VENTAS', COUNT(*) FROM detalle_ventas;
