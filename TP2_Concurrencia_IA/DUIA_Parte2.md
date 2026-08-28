# Declaración de Uso de IA (DUIA) - Parte 2 (Concurrencia)

| Campo | Completar |
| :--- | :--- |
| **Herramienta** | Gemini (Asistente externo) |
| **Spec o prompt utilizado** | "Explicar tres escenarios de anomalías de concurrencia reproducidos en PostgreSQL (Lectura no repetible, Fantasma, Espera por bloqueo) y qué nivel de aislamiento los evita." |
| **Qué generó** | La explicación teórica del comportamiento del motor frente a concurrencia y la recomendación de los niveles de aislamiento requeridos. |
| **Qué se aceptó** | Se aceptaron las explicaciones sobre Read Committed, Repeatable Read y bloqueos FOR UPDATE. |
| **Qué se modificó o descartó, y por qué** | No hubo modificaciones, la teoría coincidía con la bibliografía de la cátedra. |
| **Verificación realizada** | Se corroboraron las explicaciones directamente en el motor real modificando el SET TRANSACTION ISOLATION LEVEL y confirmando que los resultados cambiaban tal cual lo predijo la IA. |