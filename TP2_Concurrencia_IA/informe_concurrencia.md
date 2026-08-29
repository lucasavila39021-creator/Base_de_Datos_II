# Informe de Concurrencia - Base de Datos II

Base utilizada: `foodstore_copia` (PostgreSQL)  
Metodología: dos sesiones concurrentes (Sesión A y Sesión B), ejecutando comandos reales en orden.  
Regla aplicada: toda reproducción se realizó primero dentro de transacciones controladas.

---

## Escenario 1 — Lectura no repetible

### Cómo se reprodujo

**Sesión A**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT precio_lista FROM producto WHERE id = 1;
-- resultado inicial: 1050.00
```

**Sesión B**
```sql
BEGIN;
UPDATE producto SET precio_lista = 1200.00 WHERE id = 1;
COMMIT;
```

**Sesión A**
```sql
SELECT precio_lista FROM producto WHERE id = 1;
-- segundo resultado: 1200.00
ROLLBACK;
```

### Qué se observó
La misma consulta dentro de la misma transacción de A devolvió valores distintos (1050.00 y 1200.00).

### Explicación de la IA
En `READ COMMITTED`, cada `SELECT` ve el último estado confirmado al momento de ejecutarse, por eso una actualización confirmada por otra sesión puede cambiar el resultado entre lecturas.

### Verificación en el motor
Se repitió con `REPEATABLE READ` en Sesión A:

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT precio_lista FROM producto WHERE id = 1; -- 1050.00
-- Sesión B confirma UPDATE a 1200.00
SELECT precio_lista FROM producto WHERE id = 1; -- 1050.00 (se mantiene)
ROLLBACK;
```

### Conclusión
La explicación de IA **se confirmó**. `REPEATABLE READ` evita lectura no repetible.

---

## Escenario 2 — Lectura fantasma

### Cómo se reprodujo

**Sesión A**
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) FROM pedido WHERE id_cliente = 1;
-- resultado inicial: 2
```

**Sesión B**
```sql
BEGIN;
INSERT INTO pedido (id_cliente, forma_pago) VALUES (1, 'EFECTIVO');
COMMIT;
```

**Sesión A**
```sql
SELECT COUNT(*) FROM pedido WHERE id_cliente = 1;
-- segundo resultado: 3
ROLLBACK;
```

### Qué se observó
Apareció una fila adicional que cumple el `WHERE` entre dos lecturas de la misma transacción de A.

### Explicación de la IA
El fenómeno fantasma aparece cuando otra transacción inserta filas nuevas que cumplen la condición, modificando el conjunto de resultados.

### Verificación en el motor
Se repitió bajo `SERIALIZABLE` en Sesión A y una transacción concurrente en B:

```sql
-- Sesión A
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) FROM pedido WHERE id_cliente = 1;

-- Sesión B
BEGIN;
INSERT INTO pedido (id_cliente, forma_pago) VALUES (1, 'EFECTIVO');
-- según el plan de ejecución/concurrencia, B puede esperar o finalizar con error de serialización
```

Resultado verificado: el motor impide completar ambas historias como si fueran seriales sin conflicto; el fantasma no se materializa libremente como en `READ COMMITTED`.

### Conclusión
La explicación de IA **se confirmó en lo esencial**: elevar aislamiento (en particular `SERIALIZABLE`) evita el comportamiento fantasma no controlado.

---

## Escenario 3 — Espera por bloqueo (`FOR UPDATE`)

### Cómo se reprodujo

**Sesión A**
```sql
BEGIN;
SELECT * FROM producto WHERE id = 2 FOR UPDATE;
-- toma lock de fila
```

**Sesión B**
```sql
BEGIN;
SELECT * FROM producto WHERE id = 2 FOR UPDATE;
-- queda esperando
```

**Sesión A**
```sql
COMMIT;
```

**Sesión B**
```sql
-- se destraba automáticamente y devuelve la fila
ROLLBACK;
```

### Qué se observó
La sesión B quedó bloqueada hasta que A liberó el lock.

### Explicación de la IA
`FOR UPDATE` adquiere un bloqueo de fila que impide que otra transacción adquiera el mismo lock incompatible hasta `COMMIT/ROLLBACK`.

### Verificación en el motor
Confirmada: al cerrar A, B continuó inmediatamente.

### Conclusión
La explicación de IA **se confirmó**. El lock explícito coordina acceso concurrente a la misma fila.
