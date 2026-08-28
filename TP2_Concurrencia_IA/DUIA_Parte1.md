# Declaración de Uso de IA (DUIA) - Parte 1

| Campo | Completar |
| :--- | :--- |
| **Herramienta** | Gemini (Asistente externo por cuota excedida en OpenCode) |
| **Spec o prompt utilizado** | "Generar triggers en PostgreSQL para impedir modificar estado de pedidos ENTREGADOS/CANCELADOS y validar stock antes de insertar detalle_pedido." |
| **Qué generó** | Dos funciones PL/pgSQL y dos triggers (BEFORE UPDATE y BEFORE INSERT). |
| **Qué se aceptó** | Todo el código se aceptó tal cual fue generado. |
| **Qué se modificó o descartó, y por qué** | No hubo modificaciones, la lógica aplicaba perfectamente al esquema. |
| **Verificación realizada** | Se simuló el INSERT de 100 Muzzarellas (stock 50) y el motor rechazó la transacción por la excepción del trigger. |