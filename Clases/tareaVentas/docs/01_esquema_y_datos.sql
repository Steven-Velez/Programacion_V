CREATE DATABASE IF NOT EXISTS laboratorio_ventas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE laboratorio_ventas;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS estado_consolidacion;
DROP TABLE IF EXISTS resumen_ventas_diarias;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE clientes (
  id_cliente INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE productos (
  id_producto INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  precio_catalogo DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (id_producto),
  CONSTRAINT ck_precio_catalogo CHECK (precio_catalogo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ventas (
  id_venta INT NOT NULL AUTO_INCREMENT,
  id_cliente INT NOT NULL,
  fecha_venta DATETIME NOT NULL,
  estado ENUM('CONFIRMADA','ANULADA') NOT NULL DEFAULT 'CONFIRMADA',
  fecha_modificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
    REFERENCES clientes(id_cliente),
  INDEX idx_ventas_estado_fecha (estado, fecha_venta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE detalle_venta (
  id_detalle INT NOT NULL AUTO_INCREMENT,
  id_venta INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (id_detalle),
  CONSTRAINT ck_cantidad CHECK (cantidad > 0),
  CONSTRAINT ck_precio_venta CHECK (precio_unitario >= 0),
  CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
    REFERENCES ventas(id_venta) ON DELETE CASCADE,
  CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
    REFERENCES productos(id_producto),
  INDEX idx_detalle_venta (id_venta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE resumen_ventas_diarias (
  fecha DATE NOT NULL,
  cantidad_ventas INT NOT NULL,
  unidades_vendidas INT NOT NULL,
  ingresos DECIMAL(14,2) NOT NULL,
  ticket_promedio DECIMAL(14,2) NOT NULL,
  ultima_actualizacion DATETIME NOT NULL,
  PRIMARY KEY (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estado_consolidacion (
  id TINYINT NOT NULL PRIMARY KEY,
  pendiente BOOLEAN NOT NULL DEFAULT TRUE,
  ultima_operacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO estado_consolidacion (id, pendiente, ultima_operacion)
VALUES (1, TRUE, CURRENT_TIMESTAMP);

INSERT INTO clientes (nombre) VALUES
('Ana Torres'), ('Luis Pérez'), ('María Gómez'), ('Carlos Ruiz'),
('Sofía Díaz'), ('Andrés Mora'), ('Laura Silva');

INSERT INTO productos (nombre, precio_catalogo) VALUES
('Teclado', 100.00), ('Mouse', 50.00), ('Monitor', 600.00),
('Audífonos', 200.00), ('Cable HDMI', 35.00), ('Webcam', 180.00),
('Impresora', 450.00);

INSERT INTO ventas (id_venta, id_cliente, fecha_venta, estado) VALUES
(1,1,'2026-10-28 10:15:00','CONFIRMADA'),
(2,2,'2026-10-28 12:00:00','CONFIRMADA'),
(3,3,'2026-10-29 08:15:00','CONFIRMADA'),
(4,1,'2026-10-29 18:10:00','ANULADA'),
(5,2,'2026-11-01 09:00:00','CONFIRMADA'),
(6,3,'2026-11-02 07:20:00','CONFIRMADA'),
(7,1,'2026-11-02 08:00:00','CONFIRMADA'),
(8,4,'2026-11-02 15:11:20','CONFIRMADA'),
(9,5,'2026-11-03 09:10:00','CONFIRMADA'),
(10,6,'2026-11-03 11:25:00','CONFIRMADA'),
(11,7,'2026-11-04 08:40:00','ANULADA'),
(12,1,'2026-11-04 13:05:00','CONFIRMADA'),
(13,2,'2026-11-05 09:30:00','CONFIRMADA'),
(14,3,'2026-11-05 17:15:00','CONFIRMADA'),
(15,4,'2026-11-06 10:20:00','CONFIRMADA'),
(16,5,'2026-11-07 12:45:00','CONFIRMADA'),
(17,6,'2026-11-07 16:00:00','ANULADA'),
(18,7,'2026-11-08 09:35:00','CONFIRMADA'),
(19,1,'2026-11-09 10:10:00','CONFIRMADA'),
(20,2,'2026-11-09 14:50:00','CONFIRMADA'),
(21,3,'2026-11-10 08:25:00','CONFIRMADA'),
(22,4,'2026-11-10 18:05:00','CONFIRMADA'),
(23,5,'2026-11-11 09:15:00','ANULADA'),
(24,6,'2026-11-11 12:30:00','CONFIRMADA'),
(25,7,'2026-11-12 10:00:00','CONFIRMADA'),
(26,1,'2026-11-12 15:45:00','CONFIRMADA'),
(27,2,'2026-11-13 09:20:00','CONFIRMADA'),
(28,3,'2026-11-13 16:30:00','CONFIRMADA'),
(29,4,'2026-11-14 11:40:00','CONFIRMADA'),
(30,5,'2026-11-14 17:55:00','CONFIRMADA');

INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1,2,2,50),(1,1,1,100),(2,3,1,600),(3,4,1,200),(3,2,1,50),
(4,3,1,600),(5,1,3,100),(6,2,1,50),(6,4,1,200),(7,3,2,600),
(8,5,4,35),(8,2,2,50),(9,6,1,180),(10,1,2,100),(10,5,3,35),
(12,3,1,600),(13,7,1,450),(14,2,5,50),(14,5,2,35),(15,6,2,180),
(16,4,2,200),(18,1,1,100),(18,2,3,50),(19,3,1,600),(20,5,6,35),
(21,7,1,450),(21,2,2,50),(22,6,1,180),(24,4,3,200),(25,1,4,100),
(25,5,2,35),(26,3,2,600),(27,7,1,450),(27,6,1,180),(28,2,4,50),
(29,4,2,200),(29,5,5,35),(30,1,2,100),(30,3,1,600);

DELIMITER $$
CREATE TRIGGER ventas_marcar_consolidacion_iu
AFTER INSERT ON ventas FOR EACH ROW
BEGIN
  UPDATE estado_consolidacion
  SET pendiente = TRUE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;
END$$

CREATE TRIGGER ventas_marcar_consolidacion_uu
AFTER UPDATE ON ventas FOR EACH ROW
BEGIN
  UPDATE estado_consolidacion
  SET pendiente = TRUE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;
END$$

CREATE TRIGGER ventas_marcar_consolidacion_du
AFTER DELETE ON ventas FOR EACH ROW
BEGIN
  UPDATE estado_consolidacion
  SET pendiente = TRUE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;
END$$

CREATE TRIGGER detalle_marcar_consolidacion_iu
AFTER INSERT ON detalle_venta FOR EACH ROW
BEGIN
  UPDATE estado_consolidacion
  SET pendiente = TRUE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;
END$$

CREATE TRIGGER detalle_marcar_consolidacion_uu
AFTER UPDATE ON detalle_venta FOR EACH ROW
BEGIN
  UPDATE estado_consolidacion
  SET pendiente = TRUE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;
END$$

CREATE TRIGGER detalle_marcar_consolidacion_du
AFTER DELETE ON detalle_venta FOR EACH ROW
BEGIN
  UPDATE estado_consolidacion
  SET pendiente = TRUE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;
END$$
DELIMITER ;
