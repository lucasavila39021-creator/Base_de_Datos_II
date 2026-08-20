--Proyecto Food Store
--Script DDL con PostgreSQL - Parte IV


--Limpieza previa en orden de dependencia

drop table if exists detalle_pedido cascade;
drop table if exists pedido cascade;
drop table if exists producto cascade;
drop table if exists cliente cascade;
drop table if exists categoria cascade;

drop type if exists enum_forma_pago cascade;


--1. Creacion del enumerable "forma_pago"
create type enum_forma_pago as enum ('efectivo', 'tarjeta', 'transferencia');





--2. Definicion de tablas

--Tabla categoria
create table categoria(
    id_categoria bigint generated always as identity primary key,
    nombre varchar(100) not null unique,
    activo boolean not null default true,
    created_at timestamp not null default current_timestamp
);


--Tabla cliente
create table cliente(
    id_cliente bigint generated always as identity primary key,
    nombre_completo varchar(100) not null,
    email varchar(100) not null unique, --Regla de Negocios (R6) Cada cliente tiene un correo electronico único.
    created_at timestamp not null default current_timestamp
);


--Tabla Producto
create table producto(
    id_producto bigint generated always as identity primary key,
    id_categoria bigint not null,
    nombre varchar(150) not null,
    precio_lista numeric(10,2) not null,
    stock_actual integer not null default 0,
    activo boolean not null default true, --Regla de Negocios (R7) El producto ni categoria se borra fisicamente, solo se marcan como inactivos.
    created_at timestamp not null default current_timestamp,

    --Restriciones de dominio (R5) El precio de un producto no puede tener un valor negativo y el stock no puede ser menor a cero.
    constraint ck_precio_lista check (precio_lista >= 0),
    constraint ck_stock_actual check (stock_actual >= 0),

    --Foreign Key con Restrict para preservar el historial
    constraint fk_producto_categoria foreign key (id_categoria)
        references categoria(id_categoria) on delete restrict
);


--Tabla Pedido
create table pedido(
    id_pedido bigint generated always as identity primary key,
    id_cliente bigint not null,
    fecha_hora timestamp not null default current_timestamp,
    forma_pago enum_forma_pago not null,

    constraint fk_pedido_cliente foreign key (id_cliente)
        references cliente(id_cliente) on delete restrict
);



--Tabla asociativa detalle_pedido -- (intermedia entre pedido y producto)

create table detalle_pedido(
    id_pedido bigint not null,
    id_producto bigint not null,
    cantidad integer not null,
    precio_unitario numeric(10, 2) not null, -- Regla de Negocios (R4) se guarda un registro de la cantidad de productos dentro de un pedido

    --Clave primaria compuesta
    primary key(id_pedido, id_producto),

    --Restricciones
    constraint ck_cantidad check (cantidad > 0),
    constraint ck_detalle_precio check (precio_unitario >= 0),


    --Foreign Key

    constraint fk_detalle_pedido foreign key (id_pedido)
        references pedido(id_pedido) on delete cascade,

    constraint fk_detalle_producto foreign key (id_producto)
        references producto(id_producto) on delete restrict
);

--3. Indices

--Indice 1- Optimiza la busqueda de pedidos realizados por un cliente en particular
create index idx_pedido_cliente on pedido(id_cliente);

--Indice 2- Acelera el listado de productos activos pertenecientes a una categoria
create index idx_producto_categoria on producto(id_categoria) where activo = true;










