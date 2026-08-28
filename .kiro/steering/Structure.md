---
inclusion: always
---
# FoodStore – Estructura de Datos
## Tablas Principales
- `categoria`: Agrupación de productos con baja lógica.
- `cliente`: Registro de clientes con validación de email único.
- `producto`: Catálogo vinculado a categorías con control de stock y precios no negativos.
- `pedido`: Cabecera de órdenes asociada a clientes y estados.
- `detalle_pedido`: Entidad asociativa N:M con subtotal calculado automáticamente y precios históricos.