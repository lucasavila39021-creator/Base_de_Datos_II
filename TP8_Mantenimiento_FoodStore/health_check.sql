-- ==============================================================================
-- health_check.sql | Lucas Avila
-- ==============================================================================

-- 1. Tamaño global de la base
SELECT 
    datname AS nombre_base, 
    pg_size_pretty(pg_database_size(datname)) AS tamaño_total
FROM pg_database 
WHERE datname = 'foodstore';

-- 2. Conexiones y rendimiento de caché (I/O)
SELECT 
    numbackends AS conexiones_abiertas,
    xact_commit AS tx_confirmadas,
    xact_rollback AS tx_revertidas,
    blks_read AS lecturas_disco,
    blks_hit AS lecturas_cache,
    ROUND(blks_hit::NUMERIC / NULLIF(blks_hit + blks_read, 0) * 100, 2) AS ratio_cache_pct
FROM pg_stat_database 
WHERE datname = 'foodstore';

-- 3. Estado de tablas y tuplas muertas (Bloat)
SELECT 
    relname AS nombre_tabla,
    n_live_tup AS vivas,
    n_dead_tup AS muertas,
    CASE 
        WHEN n_live_tup = 0 THEN 0 
        ELSE ROUND(n_dead_tup::NUMERIC / n_live_tup * 100, 2) 
    END AS porcentaje_muertas,
    last_autovacuum AS ultimo_autovacuum,
    last_autoanalyze AS ultimo_autoanalyze
FROM pg_stat_user_tables 
ORDER BY n_dead_tup DESC;

-- 4. Consultas activas o atascadas
SELECT 
    pid AS id_proceso,
    state AS estado_conexion,
    now() - query_start AS tiempo_ejecucion,
    LEFT(query, 100) AS consulta_sql
FROM pg_stat_activity 
WHERE datname = 'foodstore' 
  AND state != 'idle'
ORDER BY tiempo_ejecucion DESC;
