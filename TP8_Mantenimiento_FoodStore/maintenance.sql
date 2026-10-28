-- ==============================================================================
-- maintenance.sql | Lucas Avila
-- Revisión y limpieza justificada. (NO incluye VACUUM FULL por bloqueo de lecturas)
-- ==============================================================================

-- 1. Revisión de parámetros efectivos de autovacuum por tabla
SELECT 
    c.relname AS tabla,
    COALESCE(
        (SELECT option_value FROM pg_options_to_table(c.reloptions) WHERE option_name = 'autovacuum_vacuum_scale_factor'),
        current_setting('autovacuum_vacuum_scale_factor')
    ) AS factor_vacuum,
    COALESCE(
        (SELECT option_value FROM pg_options_to_table(c.reloptions) WHERE option_name = 'autovacuum_enabled'),
        'heredado'
    ) AS estado_autovacuum
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r'
ORDER BY c.relname;

-- 2. Acción de mantenimiento manual justificada
-- Justificación: 'detalle_pedido' sufre constantes escrituras diarias y acumula versiones 
-- obsoletas (dead tuples) rápidamente. Ejecutar VACUUM ANALYZE manual libera este espacio
-- para reuso y recalcula el planificador sin bloquear transacciones concurrentes.
VACUUM ANALYZE detalle_pedido;
