# Informe breve: laboratorio de ventas y resumen diario

## Arquitectura

El sistema separa datos operativos y datos consolidados dentro de MySQL. Las tablas `ventas` y `detalle_venta` conservan las operaciones; `resumen_ventas_diarias` contiene una proyección diaria consultada por el dashboard. `estado_consolidacion` registra si una operación pendiente debe ejecutar el procedimiento.

```text
operación REST -> ventas/detalle_venta -> triggers marcan pendiente
                                      |
                                      v
event o POST manual -> sp_actualizar_resumen_ventas()
                                      |
                                      v
resumen_ventas_diarias -> API solo-lectura -> dashboard
```

## Decisiones técnicas

- El procedimiento elimina y reconstruye el resumen dentro de una transacción. Las anulaciones y modificaciones quedan reflejadas al consolidar.
- Las ventas cuentan una vez mediante `COUNT(DISTINCT id_venta)`; los detalles se usan para unidades e ingresos.
- El evento se ejecuta cada cinco minutos.
- Los endpoints de resumen leen únicamente `resumen_ventas_diarias` y el estado lee `estado_consolidacion`, no las tablas transaccionales.
- Las cantidades y precios históricos tienen restricciones positivas/no negativas.

## Evidencia de pruebas

Ejecute `01_esquema_y_datos.sql`, `02_procedimiento_y_evento.sql` y luego `04_pruebas_P1_P9.sql`. Las comprobaciones cubren P1, P2, P6 y P9. P3-P5 se pueden verificar creando, anulando o modificando una venta desde la API, comprobando `pendiente=true`, ejecutando el POST de actualización y consultando nuevamente los indicadores.

| Caso | Evidencia |
|---|---|
| P1/P2 | Totales SQL de control comparados con el resumen; segunda ejecución sin duplicados |
| P3 | Alta confirmada aumenta el resumen únicamente después de consolidar |
| P4 | Anulación excluye venta en el siguiente procedimiento |
| P5 | Cambio de cantidad/precio recalcula unidades e ingresos |
| P6/P7 | Período vacío devuelve ceros; rango invertido devuelve HTTP 400 |
| P8 | Repositorio de resumen sin consultas a `ventas` o `detalle_venta` |
| P9 | Evento habilitado con frecuencia de cinco minutos |

## Desfase y conclusión

Existe un desfase intencional de hasta cinco minutos entre una operación y su visualización. El usuario puede ver el estado pendiente y solicitar una actualización manual. Recalcular todo es simple y repetible, pero conviene una actualización incremental o un almacén analítico si crecen significativamente el volumen y la exigencia de latencia.
