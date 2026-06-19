

CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    ciudad VARCHAR(80),
    pais VARCHAR(60) DEFAULT 'Panama',
    fecha_registro DATE DEFAULT CURRENT_DATE,
    activo BOOLEAN DEFAULT TRUE
);

-- TABLA PRODUCTOS
CREATE TABLE IF NOT EXISTS productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    stock INTEGER DEFAULT 0,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- TABLA PEDIDOS
CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL DEFAULT 1,
    precio_unitario NUMERIC(10,2) NOT NULL,
    total NUMERIC(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    estado VARCHAR(30) DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','procesando','enviado','entregado','cancelado')),
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE CASCADE
);

-- ÍNDICES PARA MEJOR RENDIMIENTO
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_producto ON pedidos(producto_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);

-- =============================================
-- INSERTAR DATOS DE PRUEBA
-- =============================================

-- 20 Clientes
INSERT INTO clientes (nombre, email, ciudad, pais) VALUES
('Ana García',       'ana.garcia@email.com',    'Ciudad de Panamá', 'Panama'),
('Luis Martínez',    'luis.martinez@email.com', 'Colón',            'Panama'),
('María López',      'maria.lopez@email.com',   'David',            'Panama'),
('Carlos Rodríguez', 'carlos.rod@email.com',    'Santiago',         'Panama'),
('Sofía Fernández',  'sofia.fer@email.com',     'Chitré',           'Panama'),
('Andrés Torres',    'andres.t@email.com',      'La Chorrera',      'Panama'),
('Valentina Ruiz',   'valen.ruiz@email.com',    'Arraiján',         'Panama'),
('Diego Herrera',    'diego.h@email.com',       'Penonomé',         'Panama'),
('Camila Vargas',    'camila.v@email.com',      'Aguadulce',        'Panama'),
('Sebastián Mora',   'seba.mora@email.com',     'Ciudad de Panamá', 'Panama'),
('Lucía Peña',       'lucia.pena@email.com',    'Bocas del Toro',   'Panama'),
('Mateo Gómez',      'mateo.g@email.com',       'Boquete',          'Panama'),
('Isabela Castro',   'isa.castro@email.com',    'Colón',            'Panama'),
('Nicolás Jiménez',  'nico.j@email.com',        'David',            'Panama'),
('Emma Morales',     'emma.m@email.com',        'Ciudad de Panamá', 'Panama'),
('Samuel Ortiz',     'sam.ortiz@email.com',     'Santiago',         'Panama'),
('Daniela Silva',    'dani.silva@email.com',    'La Chorrera',      'Panama'),
('Alejandro Ramos',  'ale.ramos@email.com',     'Arraiján',         'Panama'),
('Paula Cruz',       'paula.cruz@email.com',    'Chitré',           'Panama'),
('Roberto Vega',     'rob.vega@email.com',      'Ciudad de Panamá', 'Panama');

-- 15 Productos
INSERT INTO productos (nombre, categoria, precio, stock, descripcion) VALUES
('Laptop Gamer Pro 15"',        'Electrónica',  1299.99, 15, 'Laptop de alto rendimiento con RTX 4060'),
('Smartphone Samsung Galaxy',   'Electrónica',   799.00, 30, 'Pantalla AMOLED 120Hz, 256GB'),
('Auriculares Sony WH-1000XM5', 'Electrónica',   349.99, 25, 'Cancelación de ruido activa premium'),
('Teclado Mecánico RGB',        'Accesorios',    129.99, 40, 'Switches Cherry MX Red, retroiluminado'),
('Mouse Inalámbrico Logitech',  'Accesorios',     59.99, 50, 'DPI ajustable, batería 70 días'),
('Monitor 27" 4K IPS',          'Electrónica',   499.00, 12, 'Panel IPS 144Hz, HDR400'),
('Silla Gamer ErgoFlex',        'Mobiliario',    389.00, 10, 'Soporte lumbar, ajustable, hasta 150kg'),
('Webcam 4K StreamPro',         'Accesorios',    149.99, 20, 'Micrófono integrado, autofocus'),
('SSD Externo 1TB Samsung',     'Almacenamiento', 99.00, 35, 'USB-C 3.2, velocidad 1050MB/s'),
('Hub USB-C 10 en 1',           'Accesorios',     49.99, 45, 'HDMI 4K, PD 100W, SD card'),
('Tablet iPad Air 11"',         'Electrónica',   749.00, 18, 'Chip M2, pantalla Liquid Retina'),
('Smartwatch Apple Watch S9',   'Wearables',     399.00, 22, 'GPS, monitoreo salud avanzado'),
('Impresora HP LaserJet',       'Impresión',     299.00,  8, 'Láser monocromo, WiFi, dúplex'),
('Router WiFi 6 AX3000',        'Redes',         119.99, 16, 'Tri-band, cobertura 250m²'),
('Power Bank 26800mAh',         'Accesorios',     45.99, 60, 'Carga rápida 65W, 3 puertos');

-- 35 Pedidos distribuidos
INSERT INTO pedidos (cliente_id, producto_id, cantidad, precio_unitario, estado, fecha_pedido) VALUES
(1,  1,  1, 1299.99, 'entregado',  '2025-01-05 10:00:00'),
(2,  5,  2,   59.99, 'entregado',  '2025-01-08 14:30:00'),
(3,  2,  1,  799.00, 'entregado',  '2025-01-12 09:15:00'),
(4,  4,  1,  129.99, 'entregado',  '2025-01-15 16:00:00'),
(5,  3,  1,  349.99, 'entregado',  '2025-01-20 11:45:00'),
(6,  6,  1,  499.00, 'enviado',    '2025-02-02 08:30:00'),
(7,  7,  1,  389.00, 'enviado',    '2025-02-05 13:00:00'),
(8,  9,  2,   99.00, 'entregado',  '2025-02-10 15:20:00'),
(9,  10, 3,   49.99, 'entregado',  '2025-02-14 10:10:00'),
(10, 11, 1,  749.00, 'procesando', '2025-02-18 12:00:00'),
(11, 12, 1,  399.00, 'entregado',  '2025-02-22 17:30:00'),
(12, 8,  1,  149.99, 'entregado',  '2025-03-01 09:00:00'),
(13, 15, 2,   45.99, 'entregado',  '2025-03-05 14:45:00'),
(14, 1,  1, 1299.99, 'enviado',    '2025-03-10 11:00:00'),
(15, 2,  2,  799.00, 'procesando', '2025-03-12 16:15:00'),
(16, 4,  2,  129.99, 'entregado',  '2025-03-18 08:45:00'),
(17, 14, 1,  119.99, 'entregado',  '2025-03-22 13:30:00'),
(18, 3,  1,  349.99, 'entregado',  '2025-03-28 10:00:00'),
(19, 5,  3,   59.99, 'entregado',  '2025-04-02 15:00:00'),
(20, 6,  1,  499.00, 'pendiente',  '2025-04-05 09:30:00'),
(1,  9,  1,   99.00, 'entregado',  '2025-04-08 14:00:00'),
(3,  13, 1,  299.00, 'enviado',    '2025-04-10 11:15:00'),
(5,  10, 2,   49.99, 'entregado',  '2025-04-15 16:45:00'),
(7,  7,  1,  389.00, 'cancelado',  '2025-04-18 08:00:00'),
(9,  12, 1,  399.00, 'pendiente',  '2025-04-20 13:00:00'),
(11, 2,  1,  799.00, 'procesando', '2025-04-22 10:30:00'),
(13, 15, 4,   45.99, 'entregado',  '2025-04-25 15:15:00'),
(15, 1,  1, 1299.99, 'entregado',  '2025-04-28 09:00:00'),
(17, 11, 1,  749.00, 'enviado',    '2025-05-02 14:00:00'),
(19, 4,  3,  129.99, 'entregado',  '2025-05-05 11:30:00'),
(2,  8,  1,  149.99, 'entregado',  '2025-05-08 16:00:00'),
(4,  14, 2,  119.99, 'pendiente',  '2025-05-10 08:30:00'),
(6,  3,  1,  349.99, 'procesando', '2025-05-12 13:45:00'),
(8,  5,  2,   59.99, 'entregado',  '2025-05-15 10:00:00'),
(10, 6,  1,  499.00, 'entregado',  '2025-05-18 15:30:00');
