/*
  Sistema de Gestión para Concesionaria
  Script 3/3 - Consultas SQL (funcionalidades)
*/
USE Concesionaria;
GO

/*------------------------------------------------------------------------------
  1. Valorización del stock por sucursal
  Unidades disponibles y valor total, discriminado por Nuevo / Usado.
------------------------------------------------------------------------------*/
SELECT
    s.codigo_suc,
    s.nombre AS sucursal,
    SUM(CASE WHEN u.condicion = N'Nuevo' THEN 1 ELSE 0 END) AS cant_0km,
    SUM(CASE WHEN u.condicion = N'Nuevo' THEN u.precio_venta ELSE 0 END) AS valor_0km,
    SUM(CASE WHEN u.condicion = N'Usado' THEN 1 ELSE 0 END) AS cant_usados,
    SUM(CASE WHEN u.condicion = N'Usado' THEN u.precio_venta ELSE 0 END) AS valor_usados,
    COUNT(*) AS cant_total_disponible,
    SUM(u.precio_venta) AS valor_total_stock
FROM SUCURSAL s
INNER JOIN UNIDAD_VEHICULO u ON u.codigo_suc = s.codigo_suc
WHERE u.estado_actual = N'Disponible'
GROUP BY s.codigo_suc, s.nombre
ORDER BY s.codigo_suc;
GO

/*------------------------------------------------------------------------------
  2. Unidades con mayor permanencia en stock
  Unidades disponibles ordenadas por días desde fecha_ingreso.
------------------------------------------------------------------------------*/
SELECT TOP 10
    s.nombre AS sucursal,
    mo.nombre_marca AS marca,
    mo.denominacion AS modelo,
    u.condicion,
    u.fecha_ingreso,
    DATEDIFF(DAY, u.fecha_ingreso, GETDATE()) AS dias_en_stock,
    u.num_serie,
    u.precio_venta
FROM UNIDAD_VEHICULO u
INNER JOIN SUCURSAL s ON s.codigo_suc = u.codigo_suc
INNER JOIN MODELO mo ON mo.id_modelo = u.id_modelo
WHERE u.estado_actual = N'Disponible'
ORDER BY dias_en_stock DESC;
GO

/*------------------------------------------------------------------------------
  3. Desempeño comercial por vendedor
  Operaciones confirmadas e importe por período.
  LEFT JOIN: incluye vendedores sin ventas.
------------------------------------------------------------------------------*/
DECLARE @fecha_desde DATE = '2024-01-01';
DECLARE @fecha_hasta DATE = '2025-12-31';

SELECT
    v.legajo,
    e.nombre_completo AS vendedor,
    e.cod_sucursal,
    COUNT(b.num_boleto) AS cant_operaciones_confirmadas,
    ISNULL(SUM(b.importe_total), 0) AS importe_total_vendido
FROM VENDEDOR v
INNER JOIN EMPLEADO e ON e.legajo = v.legajo
LEFT JOIN BOLETO b
    ON b.legajo_vendedor = v.legajo
   AND b.estado = N'confirmado'
   AND b.fecha_emision BETWEEN @fecha_desde AND @fecha_hasta
GROUP BY v.legajo, e.nombre_completo, e.cod_sucursal
ORDER BY importe_total_vendido DESC, v.legajo;
GO

/*------------------------------------------------------------------------------
  4. Clientes con múltiples operaciones
  Clientes con más de un boleto confirmado.
------------------------------------------------------------------------------*/
SELECT
    c.tipo_documento,
    c.num_documento,
    c.nombre_completo,
    COUNT(*) AS cant_vehiculos_adquiridos,
    SUM(b.importe_total) AS importe_acumulado
FROM CLIENTE c
INNER JOIN BOLETO b
    ON b.tipo_documento = c.tipo_documento
   AND b.num_documento = c.num_documento
WHERE b.estado = N'confirmado'
GROUP BY c.tipo_documento, c.num_documento, c.nombre_completo
HAVING COUNT(*) > 1
ORDER BY importe_acumulado DESC;
GO

/*------------------------------------------------------------------------------
  5. Utilización de planes de financiación
  Cantidad de operaciones confirmadas por plan utilizado.
------------------------------------------------------------------------------*/
SELECT
    p.cod_plan,
    p.descripcion,
    p.cantidad_cuotas,
    p.porcentaje_financiacion,
    COUNT(b.num_boleto) AS cant_operaciones,
    SUM(b.importe_total) AS importe_total_operaciones
FROM PLANES p
INNER JOIN BOLETO b ON b.cod_plan = p.cod_plan
WHERE b.estado = N'confirmado'
GROUP BY p.cod_plan, p.descripcion, p.cantidad_cuotas, p.porcentaje_financiacion
ORDER BY cant_operaciones DESC, p.cod_plan;
GO

/*------------------------------------------------------------------------------
  6. Estado de pagos pendientes
  Clientes con cuotas pendiente/vencido: operaciones, cantidad y monto.
------------------------------------------------------------------------------*/
SELECT
    c.tipo_documento,
    c.num_documento,
    c.nombre_completo,
    COUNT(DISTINCT b.num_boleto) AS cant_operaciones_financiadas,
    COUNT(pg.id_pago) AS cant_pagos_pendientes,
    SUM(pg.importe) AS monto_total_pendiente
FROM CLIENTE c
INNER JOIN BOLETO b
    ON b.tipo_documento = c.tipo_documento
   AND b.num_documento = c.num_documento
INNER JOIN PAGO pg ON pg.num_boleto = b.num_boleto
WHERE pg.estado IN (N'pendiente', N'vencido')
  AND b.estado = N'confirmado'
GROUP BY c.tipo_documento, c.num_documento, c.nombre_completo
ORDER BY monto_total_pendiente DESC;
GO

/*------------------------------------------------------------------------------
  7. Adquisiciones realizadas a proveedores
  Por proveedor y período: adquisiciones, unidades e importe.
------------------------------------------------------------------------------*/
DECLARE @acq_desde DATE = '2024-01-01';
DECLARE @acq_hasta DATE = '2025-12-31';

SELECT
    pr.cuit,
    pr.razon_social,
    COUNT(*) AS cant_adquisiciones,
    (
        SELECT COUNT(*)
        FROM UNIDAD_VEHICULO u
        INNER JOIN ADQUISICION a2 ON a2.num_comprobante = u.num_comprobante
        WHERE a2.cuit_proveedor = pr.cuit
          AND a2.fecha BETWEEN @acq_desde AND @acq_hasta
    ) AS cant_unidades_incorporadas,
    SUM(a.importe_total) AS importe_total_adquisiciones
FROM PROVEEDOR pr
INNER JOIN ADQUISICION a ON a.cuit_proveedor = pr.cuit
WHERE a.fecha BETWEEN @acq_desde AND @acq_hasta
GROUP BY pr.cuit, pr.razon_social
ORDER BY importe_total_adquisiciones DESC;
GO

/*------------------------------------------------------------------------------
  8. Proveedores sin adquisiciones recientes
  Proveedores sin adquisiciones en el período; última fecha si existe.
------------------------------------------------------------------------------*/
DECLARE @sin_desde DATE = '2025-01-01';
DECLARE @sin_hasta DATE = '2025-12-31';

SELECT
    pr.cuit,
    pr.razon_social,
    (
        SELECT MAX(a2.fecha)
        FROM ADQUISICION a2
        WHERE a2.cuit_proveedor = pr.cuit
    ) AS fecha_ultima_adquisicion
FROM PROVEEDOR pr
WHERE NOT EXISTS (
    SELECT 1
    FROM ADQUISICION a
    WHERE a.cuit_proveedor = pr.cuit
      AND a.fecha BETWEEN @sin_desde AND @sin_hasta
)
ORDER BY pr.razon_social;
GO

/*------------------------------------------------------------------------------
  9. Reventa de vehículos recibidos como parte de pago
  Unidades en PARTE_PAGO con boleto de venta confirmado posterior.
------------------------------------------------------------------------------*/
SELECT
    u.num_serie,
    c.nombre_completo AS cliente_que_entrego,
    pp.valor_reconocido,
    u.fecha_ingreso,
    b_venta.fecha_emision AS fecha_reventa,
    b_venta.importe_total AS precio_reventa,
    b_venta.num_boleto AS boleto_reventa
FROM PARTE_PAGO pp
INNER JOIN UNIDAD_VEHICULO u ON u.num_serie = pp.num_serie
INNER JOIN BOLETO b_entrega ON b_entrega.num_boleto = pp.num_boleto
INNER JOIN CLIENTE c
    ON c.tipo_documento = b_entrega.tipo_documento
   AND c.num_documento = b_entrega.num_documento
INNER JOIN BOLETO b_venta
    ON b_venta.num_serie = u.num_serie
   AND b_venta.estado = N'confirmado'
   AND b_venta.num_boleto <> pp.num_boleto
ORDER BY u.fecha_ingreso;
GO

/*------------------------------------------------------------------------------
  10. Operaciones superiores al promedio
  Boletos confirmados con importe mayor al promedio de confirmados.
------------------------------------------------------------------------------*/
SELECT
    b.num_boleto,
    b.fecha_emision,
    c.nombre_completo AS cliente,
    e.nombre_completo AS vendedor,
    mo.nombre_marca AS marca,
    mo.denominacion AS modelo,
    b.importe_total
FROM BOLETO b
INNER JOIN CLIENTE c
    ON c.tipo_documento = b.tipo_documento
   AND c.num_documento = b.num_documento
INNER JOIN EMPLEADO e ON e.legajo = b.legajo_vendedor
INNER JOIN UNIDAD_VEHICULO u ON u.num_serie = b.num_serie
INNER JOIN MODELO mo ON mo.id_modelo = u.id_modelo
WHERE b.estado = N'confirmado'
  AND b.importe_total > (
        SELECT AVG(b2.importe_total)
        FROM BOLETO b2
        WHERE b2.estado = N'confirmado'
      )
ORDER BY b.importe_total DESC;
GO
