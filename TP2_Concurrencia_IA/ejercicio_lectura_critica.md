# Ejercicio de Lectura Crítica - Parte 3

## Script 1

**Código original**
```sql
UPDATE funcion
SET activa = FALSE;
```

### Qué filas afecta realmente
Afecta **todas** las filas de `funcion` porque no tiene cláusula `WHERE`.

### Por qué no coincide con la consigna
La consigna dice “dar de baja funciones retiradas de cartel”, que implica un subconjunto (por ejemplo, funciones vencidas). El script original desactiva también funciones vigentes.

### Versión corregida
```sql
UPDATE funcion
SET activa = FALSE
WHERE fecha_fin < CURRENT_DATE
  AND activa = TRUE;
```

---

## Script 2

**Código original**
```sql
DELETE FROM categoria
WHERE id NOT IN (SELECT categoria_id FROM producto);
```

### Qué filas afecta realmente
Si la subconsulta devuelve algún `NULL`, la expresión `NOT IN (...)` puede evaluar a `UNKNOWN` para todas las filas y terminar borrando **ninguna**, aunque existan categorías huérfanas.

### Por qué no coincide con la consigna
La consigna pide limpiar categorías sin productos asociados. Con `NOT IN` y posibles `NULL`, el comportamiento puede ser incorrecto/silencioso.

### Versión corregida (opción segura)
```sql
DELETE FROM categoria c
WHERE NOT EXISTS (
  SELECT 1
  FROM producto p
  WHERE p.id_categoria = c.id
);
```

### Alternativa válida con `NOT IN` (si se filtran nulos)
```sql
DELETE FROM categoria
WHERE id NOT IN (
  SELECT p.id_categoria
  FROM producto p
  WHERE p.id_categoria IS NOT NULL
);
```

---

## Nota de seguridad aplicada
Antes de ejecutar versiones corregidas:
1. Trabajar sobre `foodstore_copia`.
2. Ejecutar dentro de `BEGIN; ... ROLLBACK;` para inspección.
3. Tomar respaldo previo si hubiera DDL/migración (`pg_dump`).
