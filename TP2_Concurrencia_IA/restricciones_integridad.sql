-- ============================================================================
-- REGLAS DE NEGOCIO Y TRIGGERS (PARTE 1 - TP2)
-- Proyecto: FoodStore (PostgreSQL)
-- ============================================================================

-- Limpieza idempotente para evitar errores al re-ejecutar
DROP TRIGGER IF EXISTS trg_pedido_estado ON pedido;
DROP TRIGGER IF EXISTS trg_detalle_stock ON detalle_pedido;

-- ----------------------------------------------------------------------------
-- Regla 1: Bloquear modificaciones sobre pedidos cerrados
-- No se permite modificar un pedido si su estado anterior era ENTREGADO o CANCELADO.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_check_estado_pedido()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.estado IN ('ENTREGADO', 'CANCELADO') THEN
        RAISE EXCEPTION 'No se puede modificar un pedido en estado % (pedido id=%).', OLD.estado, OLD.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pedido_estado
    BEFORE UPDATE ON pedido
    FOR EACH ROW
    EXECUTE FUNCTION trg_check_estado_pedido();

-- ----------------------------------------------------------------------------
-- Regla 2: Validar stock disponible al insertar detalle
-- Si la cantidad solicitada supera el stock, se rechaza la operación.
-- También se protege el caso de producto inexistente.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_check_stock_producto()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual INTEGER;
BEGIN
    SELECT p.stock
    INTO stock_actual
    FROM producto p
    WHERE p.id = NEW.id_producto;

    IF stock_actual IS NULL THEN
        RAISE EXCEPTION 'Producto inexistente para detalle_pedido: id_producto=%.', NEW.id_producto;
    END IF;

    IF NEW.cantidad > stock_actual THEN
        RAISE EXCEPTION
            'Stock insuficiente para producto id=%: solicitado=%, disponible=%.',
            NEW.id_producto, NEW.cantidad, stock_actual;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_detalle_stock
    BEFORE INSERT ON detalle_pedido
    FOR EACH ROW
    EXECUTE FUNCTION trg_check_stock_producto();
