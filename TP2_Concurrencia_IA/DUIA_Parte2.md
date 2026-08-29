# Declaración de Uso de IA (DUIA) - Parte 2 (Concurrencia)

| Campo | Completar |
| :--- | :--- |
| **Herramienta** | Gemini (asistente externo) + validación en PostgreSQL con dos sesiones |
| **Spec o prompt utilizado** | "Explicar y proponer validación para tres escenarios de concurrencia en PostgreSQL: lectura no repetible, lectura fantasma y espera por bloqueo; indicar nivel de aislamiento o mecanismo que lo evita." |
| **Qué generó** | Explicación teórica de MVCC/bloqueos y recomendaciones de `REPEATABLE READ`, `SERIALIZABLE` y `FOR UPDATE`. |
| **Qué se aceptó** | Interpretación de los fenómenos y sugerencias de aislamiento/bloqueo. |
| **Qué se modificó o descartó, y por qué** | Se ajustó la redacción final para reflejar estrictamente lo observado en motor (sin asumir resultados no medidos). |
| **Verificación realizada** | Se reprodujeron 3 escenarios con **dos sesiones concurrentes** sobre `foodstore_copia`: 1) lectura no repetible en `READ COMMITTED` y control en `REPEATABLE READ`; 2) lectura fantasma en `READ COMMITTED` y control con `SERIALIZABLE`; 3) espera por lock con `SELECT ... FOR UPDATE`. Se documentaron comandos y observaciones en `informe_concurrencia.md`. |
