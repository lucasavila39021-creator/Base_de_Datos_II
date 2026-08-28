# Informe de Concurrencia - Base de Datos II

## Escenario 1: Lectura no repetible
*   **Cómo se reprodujo:**
    *   Sesión A: `BEGIN; SELECT precio_lista FROM producto WHERE id = 1;` (Devuelve 1050.00)
    *   Sesión B: `UPDATE producto SET precio_lista = 1200.00 WHERE id = 1;`
    *   Sesión A: `SELECT precio_lista FROM producto WHERE id = 1;`
*   **Qué se observó:** En el nivel Read Committed, la segunda lectura de la Sesión A devolvió 1200.00. La lectura cambió en medio de la transacción.
*   **Explicación de la IA:** Ocurre porque Read Committed lee los datos confirmados más recientes en cada consulta individual, permitiendo que un UPDATE de otra sesión se cuele.
*   **Verificación en el motor:** Se repitió usando `SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;` en la Sesión A. Al hacer la segunda lectura, el motor mantuvo el valor original de 1050.00.
*   **Conclusión:** La IA acertó. El nivel de aislamiento Repeatable Read resuelve el problema.

## Escenario 2: Lectura Fantasma
*   **Cómo se reprodujo:**
    *   Sesión A: `BEGIN; SELECT COUNT(*) FROM pedido WHERE id_cliente = 1;` (Devuelve 2)
    *   Sesión B: `INSERT INTO pedido (id_cliente, forma_pago) VALUES (1, 'EFECTIVO');`
    *   Sesión A: `SELECT COUNT(*) FROM pedido WHERE id_cliente = 1;`
*   **Qué se observó:** La Sesión A ve 3 pedidos en su segunda consulta (apareció una fila "fantasma").
*   **Explicación de la IA:** Repeatable Read congela las filas que ya existen, pero no evita que otra transacción inserte filas nuevas que cumplan con la condición del WHERE.
*   **Verificación en el motor:** Se repitió con `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;`. El motor bloqueó el INSERT de la Sesión B hasta que la A terminó.
*   **Conclusión:** La explicación es correcta. El nivel Serializable evita la aparición de fantasmas.

## Escenario 3: Espera por Bloqueo
*   **Cómo se reprodujo:**
    *   Sesión A: `BEGIN; SELECT * FROM producto WHERE id = 2 FOR UPDATE;`
    *   Sesión B: `BEGIN; SELECT * FROM producto WHERE id = 2 FOR UPDATE;`
*   **Qué se observó:** La Sesión B se quedó "colgada" esperando sin devolver resultado.
*   **Explicación de la IA:** El comando FOR UPDATE toma un bloqueo exclusivo sobre la fila. La Sesión B debe esperar a que la Sesión A haga COMMIT o ROLLBACK para poder tomar su propio bloqueo.
*   **Verificación en el motor:** Se ejecutó `COMMIT;` en la Sesión A. Automáticamente, la Sesión B se destrabó y devolvió la fila.
*   **Conclusión:** Confirmado en el motor. El bloqueo explícito previene modificaciones concurrentes destructivas.