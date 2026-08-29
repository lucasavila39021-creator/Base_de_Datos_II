# Protocolo de Seguridad - Base de Datos II (PostgreSQL)

Este protocolo es **obligatorio** para cualquier cambio sobre base de datos (manual o generado por IA).  
Se aplica siempre sobre PostgreSQL y sobre una **copia de trabajo**, nunca sobre producción.

---

## 1) Copia (siempre)

**Objetivo:** aislar el trabajo y evitar impacto sobre datos reales.

### Comandos de referencia (PostgreSQL)

```bash
# crear copia a partir de una base plantilla del proyecto
createdb -U postgres -T foodstore foodstore_copia

# verificar conexión a la copia
psql -U postgres -d foodstore_copia -c "SELECT current_database();"
```

**Regla:** toda prueba de TP se ejecuta en `foodstore_copia`.

---

## 2) Transacción (siempre antes de escribir)

**Objetivo:** inspeccionar efectos antes de confirmar.

### Flujo obligatorio

```sql
BEGIN;
-- ejecutar script o comandos de prueba
-- validar filas afectadas / errores / resultados
ROLLBACK;  -- por defecto en etapa de prueba
-- COMMIT; -- solo cuando la verificación es correcta y consciente
```

**Regla:** ningún `INSERT/UPDATE/DELETE/DDL` se aplica directo sin `BEGIN` previo.

---

## 3) Respaldo (siempre antes de DDL/migraciones)

**Objetivo:** recuperación independiente si algo sale mal.

### Comandos de referencia

```bash
# respaldo previo a cambios estructurales
pg_dump -U postgres -d foodstore_copia -f TP2_Concurrencia_IA/respaldo_foodstore_copia.sql

# restauración (si fuera necesaria)
psql -U postgres -d foodstore_copia -f TP2_Concurrencia_IA/respaldo_foodstore_copia.sql
```

**Regla:** antes de `ALTER`, `DROP`, recreación de triggers o migraciones, se genera `pg_dump`.

---

## Checklist operativo mínimo

- [ ] Estoy en `foodstore_copia` (no en otra base)
- [ ] Abrí transacción con `BEGIN`
- [ ] Probé casos válidos e inválidos
- [ ] Cerré con `ROLLBACK` en pruebas o `COMMIT` consciente
- [ ] Si hubo DDL: existe respaldo `pg_dump` previo
