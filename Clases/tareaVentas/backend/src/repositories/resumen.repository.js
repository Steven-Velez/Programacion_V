import { pool } from '../config/database.js';

export async function refreshSummary() {
  await pool.query('CALL sp_actualizar_resumen_ventas()');
  const [rows] = await pool.execute(
    `SELECT COUNT(*) AS diasConsolidados,
            MAX(ultima_actualizacion) AS ultimaActualizacion
     FROM resumen_ventas_diarias`,
  );
  return {
    diasConsolidados: Number(rows[0].diasConsolidados),
    ultimaActualizacion: rows[0].ultimaActualizacion,
  };
}

export async function getSummaryStatus() {
  const [rows] = await pool.execute(
    'SELECT pendiente FROM estado_consolidacion WHERE id = 1',
  );
  return { pendiente: rows.length > 0 ? Boolean(rows[0].pendiente) : true };
}

export async function findIndicators({ from, to }) {
  const [rows] = await pool.execute(
    `SELECT COALESCE(SUM(cantidad_ventas), 0) AS totalVentas,
            COALESCE(SUM(unidades_vendidas), 0) AS totalUnidades,
            COALESCE(SUM(ingresos), 0) AS ingresosTotal,
            CASE WHEN SUM(cantidad_ventas) > 0
              THEN ROUND(SUM(ingresos) / SUM(cantidad_ventas), 2)
              ELSE 0
            END AS ticketPromedio,
            MAX(ultima_actualizacion) AS ultimaActualizacion
     FROM resumen_ventas_diarias
     WHERE fecha BETWEEN ? AND ?`,
    [from, to],
  );
  const row = rows[0];
  return {
    totalVentas: Number(row.totalVentas),
    totalUnidades: Number(row.totalUnidades),
    ingresosTotal: Number(row.ingresosTotal),
    ticketPromedio: Number(row.ticketPromedio),
    ultimaActualizacion: row.ultimaActualizacion,
  };
}

export async function findDailySales({ from, to }) {
  const [rows] = await pool.execute(
    `SELECT fecha,
            cantidad_ventas AS cantidadVentas,
            unidades_vendidas AS unidadesVendidas,
            ingresos,
            ticket_promedio AS ticketPromedio,
            ultima_actualizacion AS ultimaActualizacion
     FROM resumen_ventas_diarias
     WHERE fecha BETWEEN ? AND ?
     ORDER BY fecha`,
    [from, to],
  );
  return rows.map((row) => ({
    ...row,
    cantidadVentas: Number(row.cantidadVentas),
    unidadesVendidas: Number(row.unidadesVendidas),
    ingresos: Number(row.ingresos),
    ticketPromedio: Number(row.ticketPromedio),
  }));
}
