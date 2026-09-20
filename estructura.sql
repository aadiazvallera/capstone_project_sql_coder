-- ============================================================================
-- PROYECTO CAPSTONE: ESTRUCTURA Y POBLACIÓN DE DATOS
-- Temática: Supermercado Gourmet
-- Base de Datos: capstone_project
-- ============================================================================

-- 1. LIMPIEZA DE TABLAS PREVIAS 
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- 2. CREACIÓN DE TABLAS

-- Tabla: clientes
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_registro DATE NOT NULL,
    membresia VARCHAR(50) DEFAULT 'Standard'
);

-- Tabla: productos
CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio NUMERIC(10, 2) NOT NULL
);

-- Tabla: pedidos
CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(cliente_id),
    producto_id INT REFERENCES productos(producto_id),
    fecha_pedido TIMESTAMP NOT NULL,
    cantidad INT NOT NULL,
    monto_total NUMERIC(10, 2) -- Contiene valores NULL intencionales para resolver en la etapa de limpieza
);

-- 3. INSERCIÓN DE DATOS SIMULADOS

-- Inserción de clientes
INSERT INTO clientes (nombre, email, fecha_registro, membresia) VALUES
('Alejandro Díaz', 'alejandrod@gmail.com', '2024-01-15', 'Gold'),
('Sofía Martínez', 'sofiam@gmail.com', '2024-02-01', 'Black'),
('Mateo Rossi', 'mateor@gmail.com', '2024-02-20', 'Standard'),
('Valentina Gómez', 'valentinag@gmail.com', '2024-03-05', 'Gold'),
('Lucas Benítez', 'lucasb@gmail.com', '2024-03-12', 'Standard'),
('Camila Fernández', 'camilaf@gmail.com', '2024-04-01', 'Black');

-- Inserción de productos (Café, Vinos, Quesos, Aceites y Accesorios)
INSERT INTO productos (nombre_producto, categoria, precio) VALUES
('Vino Malbec Gran Reserva 750ml', 'Cava & Vinos', 18500.00),
('Café de Especialidad Colombia 500g', 'Cafetería', 12500.00),
('Queso Brie Artesanal 250g', 'Lácteos & Fiambrería', 8500.00),
('Aceite de Oliva Extra Virgen 500ml', 'Almacén Gourmet', 9800.00),
('Molinillo de Café Manual Acero', 'Accesorios', 24500.00),
('Jamón Serrano Premium 200g', 'Lácteos & Fiambrería', 14200.00),
('Chocolate Amargo 70% Cacao', 'Dulces & Chocolates', 4500.00),
('Té Hebras Blend Orgánico 100g', 'Cafetería', 5200.00);

-- Inserción de pedidos (incluye nulos en monto_total para justificar la limpieza con COALESCE)
INSERT INTO pedidos (cliente_id, producto_id, fecha_pedido, cantidad, monto_total) VALUES
(1, 1, '2024-01-18 10:30:00', 2, 37000.00),
(1, 2, '2024-02-10 14:15:00', 1, NULL), -- 1 * 12500 = 12500
(2, 5, '2024-02-12 11:00:00', 1, 24500.00),
(3, 3, '2024-02-25 16:45:00', 2, 17000.00),
(1, 4, '2024-03-01 09:20:00', 1, 9800.00),
(4, 6, '2024-03-10 18:30:00', 1, NULL), -- 1 * 14200 = 14200
(2, 1, '2024-03-15 13:00:00', 3, 55500.00),
(5, 7, '2024-03-22 15:10:00', 4, 18000.00),
(3, 2, '2024-04-05 11:50:00', 2, 25000.00),
(4, 8, '2024-04-12 17:05:00', 1, 5200.00),
(2, 6, '2024-04-18 12:40:00', 2, NULL), -- 2 * 14200 = 28400
(6, 8, '2024-04-20 10:00:00', 2, 10400.00);