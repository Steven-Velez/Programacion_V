USE laboratorio_ventas;

-- P1 y control
CALL sp_actualizar_resumen_ventas();
SELECT DATE(v.fecha_venta) AS fecha,
       COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
       SUM(d.cantidad) AS unidades_vendidas,
       SUM(d.cantidad * d.precio_unitario) AS ingresos,
       ROUND(SUM(d.cantidad * d.precio_unitario) / COUNT(DISTINCT v.id_venta), 2) AS ticket_promedio
FROM ventas v
JOIN detalle_venta d ON d.id_venta = v.id_venta
WHERE v.estado = 'CONFIRMADA'
GROUP BY DATE(v.fecha_venta)
ORDER BY fecha;

SELECT * FROM resumen_ventas_diarias ORDER BY fecha;

-- P2 repetibilidad
CALL sp_actualizar_resumen_ventas();
SELECT fecha, cantidad_ventas, unidades_vendidas, ingresos, ticket_promedio
FROM resumen_ventas_diarias
ORDER BY fecha;

-- P6 período sin ventas
SELECT COALESCE(SUM(cantidad_ventas), 0) AS ventas,
       COALESCE(SUM(unidades_vendidas), 0) AS unidades,
       COALESCE(SUM(ingresos), 0) AS ingresos
FROM resumen_ventas_diarias
WHERE fecha BETWEEN '2030-01-01' AND '2030-01-31';

-- P9 estado del evento
SHOW EVENTS FROM laboratorio_ventas;
