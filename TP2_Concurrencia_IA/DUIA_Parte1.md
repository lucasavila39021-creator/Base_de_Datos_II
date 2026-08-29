# Declaración de Uso de IA (DUIA) - Parte 1 (Integridad versionada)

| Campo | Completar |
| :--- | :--- |
| **Herramienta** | Gemini (asistente externo) + revisión manual en PostgreSQL |
| **Spec o prompt utilizado** | "Generar triggers en PostgreSQL para: (1) impedir modificar pedidos en estado ENTREGADO/CANCELADO y (2) validar stock antes de insertar detalle_pedido" |
| **Qué generó** | Borrador de 2 funciones PL/pgSQL y 2 triggers (`BEFORE UPDATE` en `pedido` y `BEFORE INSERT` en `detalle_pedido`). |
| **Qué se aceptó** | Estructura base de funciones/triggers y validación principal de estados y stock. |
| **Qué se modificó o descartó, y por qué** | Se endureció el script para ejecución idempotente (`DROP TRIGGER IF EXISTS`) y se agregó control explícito para `id_producto` inexistente (`stock_actual IS NULL`) para evitar comportamiento ambiguo. |
| **Verificación realizada** | **Pruebas ejecutadas en `foodstore_copia` dentro de transacción:** (a) `UPDATE pedido` sobre pedido ENTREGADO → rechazado por excepción; (b) `INSERT detalle_pedido` con `cantidad` > `stock` → rechazado; (c) `INSERT detalle_pedido` válido → aceptado. Cierre de prueba con `ROLLBACK`. |
