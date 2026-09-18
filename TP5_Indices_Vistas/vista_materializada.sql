-- TP5 - Parte C: resumen materializado de ventas por categoria
-- Se refresca cuando cambia el volumen de pedidos o detalles.

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_resumen_ventas_categoria AS
SELECT
    c.id AS categoria_id,
    c.nombre AS categoria,
    COUNT(DISTINCT p.id) AS pedidos,
    COALESCE(SUM(CASE WHEN p.id IS NOT NULL THEN dp.cantidad ELSE 0 END), 0)::BIGINT AS unidades_vendidas,
    COALESCE(SUM(CASE WHEN p.id IS NOT NULL THEN dp.subtotal ELSE 0 END), 0)::NUMERIC(14, 2) AS facturacion
FROM categoria AS c
LEFT JOIN producto AS pr
    ON pr.id_categoria = c.id
   AND pr.activo = TRUE
LEFT JOIN detalle_pedido AS dp ON dp.id_producto = pr.id
LEFT JOIN pedido AS p
    ON p.id = dp.id_pedido
   AND p.estado <> 'CANCELADO'
WHERE c.activo = TRUE
GROUP BY c.id, c.nombre;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mv_resumen_ventas_categoria
    ON mv_resumen_ventas_categoria (categoria_id);

COMMENT ON MATERIALIZED VIEW mv_resumen_ventas_categoria IS
    'Resumen precalculado de ventas por categoria; requiere REFRESH.';
