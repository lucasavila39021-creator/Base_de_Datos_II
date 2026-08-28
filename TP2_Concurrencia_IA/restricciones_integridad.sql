-- ============================================================================
-- REGLAS DE NEGOCIO Y TRIGGERS (PARTE 1 - TP2)
-- ============================================================================

-- Función y Trigger para impedir modificar pedidos ENTREGADOS o CANCELADOS
CREATE OR REPLACE FUNCTION trg_check_estado_pedido()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.estado IN ('ENTREGADO', 'CANCELADO') THEN
        RAISE EXCEPTION 'No se puede modificar un pedido que ya se encuentra en estado %', OLD.estado;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pedido_estado
    BEFORE UPDATE ON pedido
    FOR EACH ROW
    EXECUTE FUNCTION trg_check_estado_pedido();

-- Función y Trigger para validar stock disponible antes de insertar un detalle
CREATE OR REPLACE FUNCTION trg_check_stock_producto()
RETURNS TRIGGER AS $$
DECLARE
stock_actual INTEGER;
BEGIN
SELECT stock INTO stock_actual FROM producto WHERE id = NEW.id_producto;
IF NEW.cantidad > stock_actual THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto ID %. Solicitado: %, Disponible: %', NEW.id_producto, NEW.cantidad, stock_actual;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_detalle_stock
    BEFORE INSERT ON detalle_pedido
    FOR EACH ROW
    EXECUTE FUNCTION trg_check_stock_producto();