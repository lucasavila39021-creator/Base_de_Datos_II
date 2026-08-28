# Protocolo de Seguridad - Base de Datos II

Este documento establece el protocolo de tres pasos obligatorio para interactuar con la base de datos utilizando herramientas de IA.

## 1. Copia
**Regla:** Se trabaja exclusivamente sobre una base de desarrollo local, nunca sobre datos reales.
*   **Comando en mi entorno:** `CREATE DATABASE copia_trabajo;` (Usando XAMPP/MySQL)

## 2. Transacción
**Regla:** Todo script de escritura se prueba primero en una transacción segura para verificar los cambios.
*   **Procedimiento:**
    1. Ejecutar `START TRANSACTION;`
    2. Correr el script generado por la IA.
    3. Inspeccionar el efecto.
    4. Ejecutar `ROLLBACK;` si hay dudas, o `COMMIT;` solo si es correcto.

## 3. Respaldo
**Regla:** Antes de cualquier cambio estructural, se realiza un respaldo completo.
*   **Comando en mi entorno:** `mysqldump -u root -p copia_trabajo > backup.sql`