# Ejercicio de Lectura Crítica - Parte 3

## Script 1
**Código original:** `UPDATE funcion SET activa = FALSE;`
*   **Efecto real:** Al no tener una cláusula WHERE, este comando actualiza TODAS las filas de la tabla `funcion`, desactivando absolutamente todo, no solo las "retiradas de cartel".
*   **Versión corregida:**
    `UPDATE funcion SET activa = FALSE WHERE fecha_fin < CURRENT_DATE;`

## Script 2
**Código original:** `DELETE FROM categoria WHERE id NOT IN (SELECT categoria_id FROM producto);`
*   **Efecto real:** En SQL, si la subconsulta devuelve al menos un valor NULL (por ejemplo, si hay un producto que tiene su `categoria_id` en NULL), la condición `NOT IN` evalúa como DESCONOCIDO (NULL) para toda la tabla. El resultado es que **no se borra absolutamente ninguna fila**, fallando silenciosamente.
*   **Versión corregida:**
    `DELETE FROM categoria WHERE id NOT IN (SELECT categoria_id FROM producto WHERE categoria_id IS NOT NULL);`
    *(O usar NOT EXISTS, que es más seguro contra valores nulos).*
