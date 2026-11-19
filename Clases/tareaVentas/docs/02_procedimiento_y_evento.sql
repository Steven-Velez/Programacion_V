USE laboratorio_ventas;

DROP EVENT IF EXISTS ev_actualizar_resumen_ventas;
DROP PROCEDURE IF EXISTS sp_actualizar_resumen_ventas;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_resumen_ventas()
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  DELETE FROM resumen_ventas_diarias;

  INSERT INTO resumen_ventas_diarias
    (fecha, cantidad_ventas, unidades_vendidas,
     ingresos, ticket_promedio, ultima_actualizacion)
  SELECT
    DATE(v.fecha_venta),
    COUNT(DISTINCT v.id_venta),
    SUM(d.cantidad),
    SUM(d.cantidad * d.precio_unitario),
    ROUND(SUM(d.cantidad * d.precio_unitario) / COUNT(DISTINCT v.id_venta), 2),
    NOW()
  FROM ventas AS v
  INNER JOIN detalle_venta AS d ON d.id_venta = v.id_venta
  WHERE v.estado = 'CONFIRMADA'
  GROUP BY DATE(v.fecha_venta);

  UPDATE estado_consolidacion
  SET pendiente = FALSE, ultima_operacion = CURRENT_TIMESTAMP
  WHERE id = 1;

  COMMIT;
END$$

CREATE EVENT ev_actualizar_resumen_ventas
ON SCHEDULE EVERY 5 MINUTE
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
ENABLE
DO
  CALL sp_actualizar_resumen_ventas();
DELIMITER ;

SET GLOBAL event_scheduler = ON;

CALL sp_actualizar_resumen_ventas();

-- Inspección
SELECT * FROM resumen_ventas_diarias ORDER BY fecha;
SHOW EVENTS FROM laboratorio_ventas;
