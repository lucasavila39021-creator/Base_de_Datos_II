# Declaración de Uso de IA (DUIA) - Parte 3 (Lectura Crítica)

| Campo | Completar |
| :--- | :--- |
| **Herramienta** | Gemini (Asistente externo) |
| **Spec o prompt utilizado** | "Analizar dos scripts SQL destructivos, explicar su efecto real en la base de datos y generar las versiones corregidas." |
| **Qué generó** | El análisis del UPDATE sin WHERE (que afectaba toda la tabla) y el análisis del DELETE con NOT IN evaluando a NULL (que fallaba silenciosamente), junto con sus correcciones. |
| **Qué se aceptó** | El análisis técnico de la falla lógica de los scripts y las consultas SQL corregidas. |
| **Qué se modificó o descartó, y por qué** | Nada descartado. |
| **Verificación realizada** | Se comprobó conceptualmente el riesgo de la falta de cláusula WHERE y el comportamiento del estándar SQL frente a comparaciones con valores NULL en subconsultas. |