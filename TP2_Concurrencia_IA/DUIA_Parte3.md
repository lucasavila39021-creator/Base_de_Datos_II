# Declaración de Uso de IA (DUIA) - Parte 3 (Lectura crítica)

| Campo | Completar |
| :--- | :--- |
| **Herramienta** | Gemini (asistente externo) + validación conceptual manual |
| **Spec o prompt utilizado** | "Analizar dos scripts SQL potencialmente peligrosos, explicar su efecto real y proponer versiones corregidas seguras." |
| **Qué generó** | Diagnóstico del `UPDATE` sin `WHERE` y del `DELETE ... NOT IN (...)` con riesgo por `NULL`, más propuestas de corrección. |
| **Qué se aceptó** | El diagnóstico base de ambos riesgos y la orientación para reescritura segura. |
| **Qué se modificó o descartó, y por qué** | Se mejoró la corrección del segundo caso priorizando `NOT EXISTS`, por ser más robusto ante `NULL` y más claro para defensa oral. |
| **Verificación realizada** | Se verificó lógicamente el efecto real de cada script y se reescribieron ambas sentencias en `ejercicio_lectura_critica.md`, incluyendo justificación de por qué la versión original no cumple la consigna. |
