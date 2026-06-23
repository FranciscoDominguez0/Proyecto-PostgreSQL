CREATE DATABASE veterinaria_db;

DROP TABLE IF EXISTS consultas CASCADE;
DROP TABLE IF EXISTS vacunas CASCADE;
DROP TABLE IF EXISTS mascotas CASCADE;
DROP TABLE IF EXISTS propietarios CASCADE;

-- TABLA PROPIETARIOS
CREATE TABLE IF NOT EXISTS propietarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    ciudad VARCHAR(80),
    direccion VARCHAR(200),
    fecha_registro DATE DEFAULT CURRENT_DATE,
    activo BOOLEAN DEFAULT TRUE
);

-- TABLA MASCOTAS
CREATE TABLE IF NOT EXISTS mascotas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL
        CHECK (especie IN ('Perro','Gato','Ave','Conejo','Reptil','Otro')),
    raza VARCHAR(80),
    fecha_nacimiento DATE,
    sexo CHAR(1) CHECK (sexo IN ('M','H')),
    propietario_id INTEGER NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_propietario
        FOREIGN KEY (propietario_id)
        REFERENCES propietarios(id)
        ON DELETE CASCADE
);

-- TABLA VACUNAS
CREATE TABLE IF NOT EXISTS vacunas (
    id SERIAL PRIMARY KEY,
    mascota_id INTEGER NOT NULL,
    nombre_vacuna VARCHAR(150) NOT NULL,
    fecha_aplicacion DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_proxima DATE,
    veterinario VARCHAR(100),
    lote VARCHAR(50),
    observaciones TEXT,
    CONSTRAINT fk_mascota_vacuna
        FOREIGN KEY (mascota_id)
        REFERENCES mascotas(id)
        ON DELETE CASCADE
);

-- TABLA CONSULTAS
CREATE TABLE IF NOT EXISTS consultas (
    id SERIAL PRIMARY KEY,
    mascota_id INTEGER NOT NULL,
    fecha_consulta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(200) NOT NULL,
    diagnostico TEXT,
    tratamiento TEXT,
    costo NUMERIC(10,2) DEFAULT 0.00,
    veterinario VARCHAR(100),
    estado VARCHAR(30) DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente','en_curso','completada','cancelada')),
    CONSTRAINT fk_mascota_consulta
        FOREIGN KEY (mascota_id)
        REFERENCES mascotas(id)
        ON DELETE CASCADE
);

-- ÍNDICES PARA MEJOR RENDIMIENTO
CREATE INDEX idx_propietarios_email ON propietarios(email);
CREATE INDEX idx_mascotas_propietario ON mascotas(propietario_id);
CREATE INDEX idx_mascotas_especie ON mascotas(especie);
CREATE INDEX idx_vacunas_mascota ON vacunas(mascota_id);
CREATE INDEX idx_vacunas_fecha ON vacunas(fecha_aplicacion);
CREATE INDEX idx_consultas_mascota ON consultas(mascota_id);
CREATE INDEX idx_consultas_fecha ON consultas(fecha_consulta);
CREATE INDEX idx_consultas_estado ON consultas(estado);

-- =============================================
-- INSERTAR DATOS DE PRUEBA - 50 POR TABLA
-- =============================================

-- =============================================
-- 50 PROPIETARIOS
-- =============================================
INSERT INTO propietarios (nombre, email, telefono, ciudad, direccion) VALUES
('Ana García',        'ana.garcia@email.com',       '6000-1001', 'Ciudad de Panamá', 'Calle 50, Marbella'),
('Luis Martínez',     'luis.martinez@email.com',    '6000-1002', 'Colón',            'Av. del Frente 23'),
('María López',       'maria.lopez@email.com',      '6000-1003', 'David',            'Calle Central 45'),
('Carlos Rodríguez',  'carlos.rod@email.com',       '6000-1004', 'Santiago',         'Av. Central 12'),
('Sofía Fernández',   'sofia.fer@email.com',        '6000-1005', 'Chitré',           'Calle Moín 8'),
('Andrés Torres',     'andres.t@email.com',         '6000-1006', 'La Chorrera',      'Res. El Valle 3'),
('Valentina Ruiz',    'valen.ruiz@email.com',       '6000-1007', 'Arraiján',         'Urbanización Pacífico 7'),
('Diego Herrera',     'diego.h@email.com',          '6000-1008', 'Penonomé',         'Calle Escuela 2'),
('Camila Vargas',     'camila.v@email.com',         '6000-1009', 'Aguadulce',        'Barrio Norte 15'),
('Sebastián Mora',    'seba.mora@email.com',        '6000-1010', 'Ciudad de Panamá', 'Torre Global, Piso 3'),
('Lucía Peña',        'lucia.pena@email.com',       '6000-1011', 'Bocas del Toro',   'Calle 3, Isla Colón'),
('Mateo Gómez',       'mateo.g@email.com',          '6000-1012', 'Boquete',          'Av. Central 89'),
('Isabela Castro',    'isa.castro@email.com',       '6000-1013', 'Colón',            'Barrio Sur 4'),
('Nicolás Jiménez',   'nico.j@email.com',           '6000-1014', 'David',            'Calle Obaldía 33'),
('Emma Morales',      'emma.m@email.com',           '6000-1015', 'Ciudad de Panamá', 'Costa del Este B-12'),
('Samuel Ortiz',      'sam.ortiz@email.com',        '6000-1016', 'Santiago',         'Urb. San Juan 9'),
('Daniela Silva',     'dani.silva@email.com',       '6000-1017', 'La Chorrera',      'Av. Primero 6'),
('Alejandro Ramos',   'ale.ramos@email.com',        '6000-1018', 'Arraiján',         'Calle Las Palmas 11'),
('Paula Cruz',        'paula.cruz@email.com',       '6000-1019', 'Chitré',           'Barrio Moín 22'),
('Roberto Vega',      'rob.vega@email.com',         '6000-1020', 'Ciudad de Panamá', 'Calle 74 Este'),
('José Castillo',     'jose.castillo@email.com',    '6000-1021', 'Ciudad de Panamá', 'Av. Balboa 100'),
('Gabriela Pérez',    'gabriela.perez@email.com',   '6000-1022', 'David',            'Calle F Norte 5'),
('Fernando Díaz',     'fernando.diaz@email.com',    '6000-1023', 'Colón',            'Paseo Gorgas 18'),
('Patricia Mendoza',  'patricia.mendoza@email.com', '6000-1024', 'Santiago',         'Calle Los Robles 4'),
('Ricardo Sánchez',   'ricardo.sanchez@email.com',  '6000-1025', 'Chitré',           'Av. Nacional 55'),
('Laura Navarro',     'laura.navarro@email.com',    '6000-1026', 'Penonomé',         'Barriada 24 de Diciembre'),
('Kevin Moreno',      'kevin.moreno@email.com',     '6000-1027', 'Arraiján',         'Res. Las Vegas 8'),
('Natalia Gómez',     'natalia.gomez@email.com',    '6000-1028', 'La Chorrera',      'Calle El Espino 3'),
('Miguel Castro',     'miguel.castro@email.com',    '6000-1029', 'David',            'Calle B Sur 12'),
('Andrea Ruiz',       'andrea.ruiz@email.com',      '6000-1030', 'Ciudad de Panamá', 'Punta Pacífica 201'),
('Javier Herrera',    'javier.herrera@email.com',   '6000-1031', 'Colón',            'Calle Segunda 7'),
('Diana Torres',      'diana.torres@email.com',     '6000-1032', 'Santiago',         'Urb. El Carmen 14'),
('Eduardo Silva',     'eduardo.silva@email.com',    '6000-1033', 'Boquete',          'Calle La Montaña 5'),
('Valeria Jiménez',   'valeria.jimenez@email.com',  '6000-1034', 'David',            'Calle Tercera Norte 9'),
('Tomás Ortega',      'tomas.ortega@email.com',     '6000-1035', 'Chitré',           'Av. Herrera 28'),
('Mónica Flores',     'monica.flores@email.com',    '6000-1036', 'Ciudad de Panamá', 'San Francisco A-4'),
('Raúl Gómez',        'raul.gomez@email.com',       '6000-1037', 'Arraiján',         'Calle Las Flores 2'),
('Karla Vega',        'karla.vega@email.com',       '6000-1038', 'La Chorrera',      'Res. El Palmar 6'),
('Cristian Ríos',     'cristian.rios@email.com',    '6000-1039', 'Colón',            'Barrio Norte 31'),
('Melissa Cruz',      'melissa.cruz@email.com',     '6000-1040', 'David',            'Av. Obaldía 10'),
('Óscar Mendoza',     'oscar.mendoza@email.com',    '6000-1041', 'Ciudad de Panamá', 'Miraflores 8B'),
('Yadira Morales',    'yadira.morales@email.com',   '6000-1042', 'Santiago',         'Calle El Roble 3'),
('Jorge Fuentes',     'jorge.fuentes@email.com',    '6000-1043', 'Penonomé',         'Urb. La Esperanza 2'),
('Tatiana López',     'tatiana.lopez@email.com',    '6000-1044', 'Boquete',          'Finca El Volcán s/n'),
('Erick Villarreal',  'erick.v@email.com',          '6000-1045', 'David',            'Calle 8 Sur 17'),
('Paola Sánchez',     'paola.s@email.com',          '6000-1046', 'Ciudad de Panamá', 'Av. Samuel Lewis 5'),
('Héctor Castillo',   'hector.c@email.com',         '6000-1047', 'Colón',            'Calle 7 Este 2'),
('Sara Martínez',     'sara.m@email.com',           '6000-1048', 'Arraiján',         'Calle El Manglar 9'),
('Bruno Pérez',       'bruno.p@email.com',          '6000-1049', 'David',            'Calle 4 Norte 33'),
('Verónica Díaz',     'veronica.d@email.com',       '6000-1050', 'Chitré',           'Paseo Los Estudiantes 6');

-- =============================================
-- 50 MASCOTAS (Distribuidas: algunos propietarios tienen múltiples, otros cero)
-- =============================================
INSERT INTO mascotas (nombre, especie, raza, fecha_nacimiento, sexo, propietario_id) VALUES
('Max',       'Perro',   'Labrador Retriever',   '2022-03-15', 'M', 1),
('Luna',      'Gato',    'Siamés',               '2021-07-22', 'H', 1),
('Rocky',     'Perro',   'German Shepherd',      '2023-01-10', 'M', 1),
('Mia',       'Gato',    'Persa',                '2022-11-05', 'H', 2),
('Buddy',     'Perro',   'Golden Retriever',     '2021-05-30', 'M', 2),
('Daisy',     'Perro',   'Poodle',               '2024-02-14', 'H', 3),
('Simba',     'Gato',    'Maine Coon',           '2023-08-20', 'M', 4),
('Bella',     'Perro',   'Beagle',               '2022-09-12', 'H', 5),
('Kiko',      'Ave',     'Loro Amazónico',       '2020-04-01', 'M', 5),
('Coco',      'Conejo',  'Holland Lop',          '2024-06-18', 'H', 5),
('Thor',      'Perro',   'Rottweiler',           '2023-12-03', 'M', 5),
('Nala',      'Gato',    'Bengalí',              '2022-05-25', 'H', 6),
('Chico',     'Perro',   'Chihuahua',            '2021-10-08', 'M', 7),
('Lola',      'Perro',   'Dachshund',            '2024-03-27', 'H', 8),
('Pita',      'Ave',     'Cacatúa',              '2019-09-15', 'H', 9),
('Tobi',      'Perro',   'Boxer',                '2023-07-04', 'M', 10),
('Sofía',     'Gato',    'Ragdoll',              '2022-01-19', 'H', 10),
('Oliver',    'Perro',   'Border Collie',        '2024-08-11', 'M', 10),
('Penny',     'Conejo',  'Mini Rex',             '2025-01-07', 'H', 14),
('Rex',       'Perro',   'Dóberman',             '2022-04-22', 'M', 15),
('Mochi',     'Gato',    'Scottish Fold',        '2023-11-30', 'H', 15),
('Spike',     'Reptil',  'Iguana Verde',         '2021-06-14', 'M', 16),
('Zara',      'Perro',   'Husky Siberiano',      '2024-05-09', 'H', 17),
('Leo',       'Gato',    'British Shorthair',    '2022-12-01', 'M', 18),
('Copito',    'Perro',   'Bichón Maltés',        '2025-02-20', 'M', 19),
('Kira',      'Perro',   'Pitbull',              '2023-04-16', 'H', 20),
('Pepe',      'Ave',     'Periquito',            '2022-07-30', 'M', 20),
('Canela',    'Perro',   'Cocker Spaniel',       '2021-08-25', 'H', 21),
('Zeus',      'Perro',   'Gran Danés',           '2023-02-28', 'M', 22),
('Mango',     'Gato',    'Abisinino',            '2024-10-13', 'M', 23),
('Sasha',     'Perro',   'Schnauzer Miniatura',  '2022-06-06', 'H', 24),
('Gizmo',     'Reptil',  'Gecko Leopardo',       '2023-03-17', 'M', 25),
('Nina',      'Perro',   'Yorkshire Terrier',    '2024-11-22', 'H', 26),
('Bruno',     'Perro',   'San Bernardo',         '2021-09-01', 'M', 27),
('Cleo',      'Gato',    'Sphynx',               '2023-05-08', 'H', 28),
('Nacho',     'Perro',   'French Bulldog',       '2024-01-15', 'M', 29),
('Aria',      'Ave',     'Canario',              '2022-03-04', 'H', 30),
('Toto',      'Perro',   'Shih Tzu',             '2023-09-27', 'M', 30),
('Frida',     'Gato',    'Angora',               '2022-02-10', 'H', 31),
('Gus',       'Perro',   'Bulldog Inglés',       '2024-07-19', 'M', 32),
('Misha',     'Gato',    'Ruso Azul',            '2023-06-23', 'H', 33),
('Titán',     'Perro',   'Alaskan Malamute',     '2022-08-14', 'M', 34),
('Beba',      'Conejo',  'Angora',               '2025-03-05', 'H', 35),
('Pumba',     'Perro',   'Bulldog Francés',      '2023-10-18', 'M', 36),
('Nia',       'Gato',    'Europeo',              '2024-04-02', 'H', 37),
('Flash',     'Perro',   'Whippet',              '2022-11-29', 'M', 38),
('Pelusa',    'Conejo',  'Enano Holandés',       '2025-05-11', 'H', 39),
('Draco',     'Reptil',  'Dragón Barbudo',       '2023-01-25', 'M', 40),
('Rosie',     'Perro',   'Cavalier King Charles','2024-09-08', 'H', 40),
('Tigre',     'Gato',    'Común Europeo',        '2021-12-17', 'M', 40);

-- =============================================
-- VACUNAS (>60 registros: múltiples para algunos, 0 para otros)
-- =============================================
INSERT INTO vacunas (mascota_id, nombre_vacuna, fecha_aplicacion, fecha_proxima, veterinario, lote, observaciones) VALUES
(1,  'Parvovirus Canino',         '2025-01-10', '2026-01-10', 'Dra. Ortega',    'LOT-2025-001', 'Primera dosis'),
(1,  'Distemper Canino',          '2025-02-10', '2026-02-10', 'Dra. Ortega',    'LOT-2025-005', 'Segunda dosis'),
(1,  'Rabia',                     '2025-03-15', '2026-03-15', 'Dr. Ramírez',    'LOT-2025-012', 'Anual'),
(1,  'Parvovirus Canino',         '2026-01-10', '2027-01-10', 'Dra. Ortega',    'LOT-2026-001', 'Refuerzo'),
(1,  'Distemper Canino',          '2026-02-10', '2027-02-10', 'Dra. Ortega',    'LOT-2026-005', 'Refuerzo'),
(2,  'Triple Felina (HCP)',       '2025-05-15', '2026-05-15', 'Dr. Ramírez',    'LOT-2025-002', 'Primera dosis'),
(2,  'Leucemia Felina',           '2025-06-20', '2026-06-20', 'Dr. Mora',       'LOT-2025-014', 'Refuerzo'),
(2,  'Rabia',                     '2025-07-20', '2026-07-20', 'Dr. Mora',       'LOT-2025-015', 'Requerida por ley'),
(3,  'Rabia',                     '2025-11-20', '2026-11-20', 'Dra. Vargas',    'LOT-2025-003', 'Requerida por ley'),
(3,  'DAPP (Cuádruple)',          '2025-11-20', '2026-11-20', 'Dra. Vargas',    'LOT-2025-004', 'Combo'),
(4,  'Leucemia Felina',           '2026-02-05', '2027-02-05', 'Dr. Mora',       'LOT-2026-004', 'Refuerzo anual'),
-- Mascota 5 no tiene vacunas
(6,  'Tos de las Perreras',       '2026-02-14', '2027-02-14', 'Dr. Castillo',   'LOT-2026-006', 'Vía intranasal'),
(7,  'Calicivirus Felino',        '2026-02-20', '2027-02-20', 'Dra. Fuentes',   'LOT-2026-007', 'Sin novedad'),
(8,  'Rabia',                     '2026-03-01', '2027-03-01', 'Dr. Ramírez',    'LOT-2026-008', 'Refuerzo anual'),
(8,  'Parvovirus Canino',         '2026-03-01', '2027-03-01', 'Dr. Ramírez',    'LOT-2026-009', 'Refuerzo anual'),
(8,  'Distemper Canino',          '2026-03-01', '2027-03-01', 'Dr. Ramírez',    'LOT-2026-010', 'Refuerzo anual'),
(9,  'Newcastle (Aves)',          '2026-03-05', '2026-09-05', 'Dra. Vargas',    'LOT-2026-009', 'Ave exótica, dosis reducida'),
(10, 'RHDV2 (Conejos)',           '2026-03-10', '2027-03-10', 'Dr. Mora',       'LOT-2026-010', 'Primera vacuna'),
(11, 'Parvovirus Canino',         '2025-03-15', '2026-03-15', 'Dra. Ortega',    'LOT-2025-011', 'Cachorro, serie completa'),
(11, 'Rabia',                     '2025-04-15', '2026-04-15', 'Dra. Ortega',    'LOT-2025-015', 'Cachorro, rabia'),
(11, 'DAPP (Cuádruple)',          '2026-04-15', '2027-04-15', 'Dra. Ortega',    'LOT-2026-015', 'Refuerzo anual'),
-- Mascota 12 sin vacunas
(13, 'DAPP (Cuádruple)',          '2026-04-01', '2027-04-01', 'Dra. Fuentes',   'LOT-2026-013', 'Chihuahua adulto'),
(14, 'Rabia',                     '2026-04-05', '2027-04-05', 'Dr. Ramírez',    'LOT-2026-014', 'Obligatoria Panamá'),
(15, 'Psitacosis (Aves)',         '2026-04-10', '2027-04-10', 'Dra. Vargas',    'LOT-2026-015', 'Aves de compañía'),
(16, 'Leptospirosis',             '2026-04-15', '2027-04-15', 'Dr. Mora',       'LOT-2026-016', 'Zona húmeda, recomendada'),
(17, 'Herpesvirus Felino',        '2026-04-20', '2027-04-20', 'Dra. Ortega',    'LOT-2026-017', 'Gata con historial respiratorio'),
(18, 'Rabia',                     '2026-05-02', '2027-05-02', 'Dr. Castillo',   'LOT-2026-018', 'Perro fronterizo'),
(18, 'Distemper Canino',          '2026-05-02', '2027-05-02', 'Dr. Castillo',   'LOT-2026-020', 'Refuerzo'),
-- Mascota 19 sin vacunas
(20, 'Distemper Canino',          '2026-05-12', '2027-05-12', 'Dr. Ramírez',    'LOT-2026-020', 'Dóberman adulto'),
(20, 'Rabia',                     '2026-05-12', '2027-05-12', 'Dr. Ramírez',    'LOT-2026-021', 'Junto con distemper'),
(20, 'Parvovirus Canino',         '2026-05-12', '2027-05-12', 'Dr. Ramírez',    'LOT-2026-022', 'Combo completo'),
(20, 'Tos de las Perreras',       '2026-05-12', '2027-05-12', 'Dr. Ramírez',    'LOT-2026-023', 'Para guardería'),
(21, 'Triple Felina (HCP)',       '2026-05-18', '2027-05-18', 'Dra. Vargas',    'LOT-2026-021', 'Scottish Fold'),
(22, 'Salmonelosis (Reptil)',     '2026-05-22', '2027-05-22', 'Dr. Mora',       'LOT-2026-022', 'Iguana 5 años'),
(23, 'Rabia',                     '2026-05-28', '2027-05-28', 'Dra. Ortega',    'LOT-2026-023', 'Husky adulta'),
(24, 'Leucemia Felina',           '2026-06-03', '2027-06-03', 'Dr. Castillo',   'LOT-2026-024', 'British adulto'),
(24, 'Rabia',                     '2026-06-03', '2027-06-03', 'Dr. Castillo',   'LOT-2026-025', 'British adulto'),
(25, 'DAPP (Cuádruple)',          '2026-06-08', '2027-06-08', 'Dra. Fuentes',   'LOT-2026-025', 'Cachorro Maltés'),
(25, 'Tos de las Perreras',       '2026-06-08', '2027-06-08', 'Dra. Fuentes',   'LOT-2026-026', 'Prevención guardería'),
(26, 'Parvovirus Canino',         '2026-06-13', '2027-06-13', 'Dr. Ramírez',    'LOT-2026-026', 'Pitbull joven'),
-- Mascota 27 sin vacunas
(28, 'Tos de las Perreras',       '2025-06-22', '2026-06-22', 'Dr. Mora',       'LOT-2025-028', 'Cocker Spaniel'),
(29, 'Rabia',                     '2025-07-01', '2026-07-01', 'Dra. Ortega',    'LOT-2025-029', 'Gran Danés adulto'),
(30, 'Calicivirus Felino',        '2025-07-05', '2026-07-05', 'Dr. Castillo',   'LOT-2025-030', 'Abisinino'),
(30, 'Rabia',                     '2025-07-05', '2026-07-05', 'Dr. Castillo',   'LOT-2025-031', 'Abisinino'),
(30, 'Triple Felina (HCP)',       '2025-07-05', '2026-07-05', 'Dr. Castillo',   'LOT-2025-032', 'Combo'),
(31, 'Leptospirosis',             '2025-07-10', '2026-07-10', 'Dra. Fuentes',   'LOT-2025-031', 'Schnauzer activo'),
(32, 'Ofidismo preventivo',       '2025-07-15', '2026-07-15', 'Dr. Ramírez',    'LOT-2025-032', 'Gecko leopardo, preventivo'),
(33, 'DAPP (Cuádruple)',          '2025-07-20', '2026-07-20', 'Dra. Vargas',    'LOT-2025-033', 'Yorkshire terrier'),
(34, 'Rabia',                     '2025-07-25', '2026-07-25', 'Dr. Mora',       'LOT-2025-034', 'San Bernardo adulto'),
(35, 'Panleucopenia Felina',      '2025-08-01', '2026-08-01', 'Dra. Ortega',    'LOT-2025-035', 'Sphynx sin pelaje'),
(36, 'Distemper Canino',          '2025-08-06', '2026-08-06', 'Dr. Castillo',   'LOT-2025-036', 'French Bulldog'),
(36, 'Tos de las Perreras',       '2025-08-06', '2026-08-06', 'Dr. Castillo',   'LOT-2025-037', 'Protección guardería'),
(37, 'Psitacosis (Aves)',         '2025-08-11', '2026-08-11', 'Dra. Fuentes',   'LOT-2025-037', 'Canario hembra'),
(38, 'Tos de las Perreras',       '2025-08-16', '2026-08-16', 'Dr. Ramírez',    'LOT-2025-038', 'Shih Tzu, refuerzo'),
(40, 'Rabia',                     '2025-08-27', '2026-08-27', 'Dr. Mora',       'LOT-2025-040', 'Bulldog inglés'),
(40, 'DAPP (Cuádruple)',          '2025-08-27', '2026-08-27', 'Dr. Mora',       'LOT-2025-041', 'Refuerzo'),
(40, 'Leptospirosis',             '2025-08-27', '2026-08-27', 'Dr. Mora',       'LOT-2025-042', 'Refuerzo'),
(42, 'Parvovirus Canino',         '2025-09-07', '2026-09-07', 'Dr. Castillo',   'LOT-2025-042', 'Malamute adulto'),
(43, 'RHDV2 (Conejos)',           '2025-09-12', '2026-09-12', 'Dra. Fuentes',   'LOT-2025-043', 'Conejo angora'),
(44, 'DAPP (Cuádruple)',          '2025-09-17', '2026-09-17', 'Dr. Ramírez',    'LOT-2025-044', 'Bulldog Francés adulto'),
(45, 'Triple Felina (HCP)',       '2025-09-22', '2026-09-22', 'Dra. Vargas',    'LOT-2025-045', 'Gato europeo'),
(45, 'Leucemia Felina',           '2025-09-22', '2026-09-22', 'Dra. Vargas',    'LOT-2025-046', 'Gato libre acceso'),
(48, 'Salmonelosis (Reptil)',     '2025-10-07', '2026-10-07', 'Dr. Castillo',   'LOT-2025-048', 'Dragón barbudo joven'),
(49, 'Rabia',                     '2025-10-12', '2026-10-12', 'Dra. Fuentes',   'LOT-2025-049', 'Cavalier adulta'),
(50, 'Calicivirus Felino',        '2025-10-17', '2026-10-17', 'Dr. Ramírez',    'LOT-2025-050', 'Gato común europeo'),
(50, 'Rabia',                     '2025-10-17', '2026-10-17', 'Dr. Ramírez',    'LOT-2025-051', 'Gato común europeo');

-- =============================================
-- CONSULTAS (>75 registros: algunas mascotas sin consultas, otras con muchas)
-- =============================================
INSERT INTO consultas (mascota_id, fecha_consulta, motivo, diagnostico, tratamiento, costo, veterinario, estado) VALUES
(1,  '2025-01-05 09:00:00', 'Revisión general',           'Sano. Excelente condición física',                 'Ninguno. Preventivo',                     25.00,  'Dra. Ortega',  'completada'),
(1,  '2025-06-10 10:00:00', 'Diarrea aguda',              'Infección intestinal leve',                        'Antibióticos orales, dieta blanda',       45.00,  'Dra. Ortega',  'completada'),
(1,  '2025-06-15 10:00:00', 'Revisión diarrea',           'Recuperado',                                       'Ninguno',                                 20.00,  'Dra. Ortega',  'completada'),
(1,  '2026-01-05 09:00:00', 'Revisión anual',             'Sano',                                             'Preventivo',                              25.00,  'Dra. Ortega',  'completada'),
(1,  '2025-10-10 16:00:00', 'Cojera',                     'Esguince',                                         'Reposo',                                  40.00,  'Dra. Ortega',  'en_curso'),
(1,  '2025-10-17 16:00:00', 'Seguimiento cojera',         'Pendiente',                                        'Pendiente',                                0.00,  'Dra. Ortega',  'pendiente'),
(2,  '2026-01-08 10:30:00', 'Pérdida de apetito',         'Gastroenteritis leve',                             'Dieta blanda, metronidazol 7 días',       35.00,  'Dr. Ramírez',  'completada'),
(3,  '2026-01-12 14:00:00', 'Cojera pata trasera',        'Esguince leve en articulación tibiotarsal',        'Reposo, antiinflamatorio 5 días',         40.00,  'Dra. Vargas',  'completada'),
(3,  '2026-01-18 14:00:00', 'Revisión esguince',          'Recuperado',                                       'Alta médica',                             20.00,  'Dra. Vargas',  'completada'),
(4,  '2026-01-15 11:00:00', 'Estornudos frecuentes',      'Rinotraqueítis viral felina',                      'Antibiótico + suero ocular 10 días',      50.00,  'Dr. Mora',     'completada'),
(4,  '2026-01-25 11:00:00', 'Revisión respiratoria',      'Mejora notable',                                   'Terminar antibióticos',                   25.00,  'Dr. Mora',     'completada'),
(6,  '2026-02-01 08:00:00', 'Vómito repetitivo',          'Obstrucción parcial por cuerpo extraño',           'Ayuno + fluidoterapia + radiografías',    85.00,  'Dr. Castillo', 'completada'),
(6,  '2026-02-02 10:00:00', 'Seguimiento por vómitos',    'Obstrucción resuelta',                             'Alta médica con dieta especial',          30.00,  'Dr. Castillo', 'completada'),
(6,  '2026-05-02 10:00:00', 'Revisión nutricional',       'Sano',                                             'Dieta de mantenimiento',                  25.00,  'Dr. Castillo', 'completada'),
(7,  '2026-02-05 15:00:00', 'Prurito intenso',            'Alergia alimentaria',                              'Cambio de dieta, antihistamínicos',       45.00,  'Dra. Fuentes', 'completada'),
(7,  '2026-03-05 15:00:00', 'Revisión de alergia',        'Controlado',                                       'Mantener dieta',                          25.00,  'Dra. Fuentes', 'completada'),
(8,  '2026-02-10 10:00:00', 'Limpieza dental',            'Sarro moderado',                                   'Profilaxis dental bajo anestesia',       120.00,  'Dr. Ramírez',  'completada'),
(10, '2026-02-18 09:00:00', 'Revisión general conejo',    'Maloclusión dental leve',                          'Corrección dental + dieta heno',          55.00,  'Dr. Mora',     'completada'),
(11, '2026-02-22 11:00:00', 'Herida en pata delantera',   'Laceración superficial',                           'Limpieza, sutura, antibiótico 5 días',    70.00,  'Dra. Ortega',  'completada'),
(11, '2026-03-01 11:00:00', 'Retiro de puntos',           'Cicatrización completa',                           'Alta médica',                             20.00,  'Dra. Ortega',  'completada'),
(12, '2026-03-01 14:30:00', 'Cambio comportamiento',      'Estrés ambiental',                                 'Feliway difusor + enriquecimiento',       30.00,  'Dr. Castillo', 'completada'),
(13, '2026-03-05 09:00:00', 'Tos crónica',                'Colapso de tráquea grado I',                       'Tos supresores, evitar collar',           65.00,  'Dra. Fuentes', 'completada'),
(13, '2026-04-05 09:00:00', 'Control tos',                'Mejora sintomática',                               'Mantener tratamiento',                    25.00,  'Dra. Fuentes', 'completada'),
(13, '2026-05-05 09:00:00', 'Control tos',                'Estable',                                          'Mantener tratamiento',                    25.00,  'Dra. Fuentes', 'completada'),
(13, '2026-06-05 09:00:00', 'Control tos',                'Estable',                                          'Mantener tratamiento',                    25.00,  'Dra. Fuentes', 'completada'),
(13, '2025-07-05 09:00:00', 'Control tos',                'Estable',                                          'Mantener tratamiento',                    25.00,  'Dra. Fuentes', 'completada'),
(14, '2026-03-10 10:00:00', 'Revisión anual',             'Obesidad leve (sobrepeso 500g)',                   'Dieta balanceada, ejercicio diario',      25.00,  'Dr. Ramírez',  'completada'),
(16, '2026-03-20 08:30:00', 'Diarrea con sangre',         'Colitis hemorrágica',                              'Hospitalización 48h, fluidoterapia',     150.00,  'Dr. Mora',     'completada'),
(16, '2026-03-22 08:30:00', 'Alta hospitalización',       'Estable',                                          'Dieta blanda',                            30.00,  'Dr. Mora',     'completada'),
(17, '2026-03-25 11:00:00', 'Ojo cerrado',                'Úlcera corneal OD',                                'Colirio antibiótico 2 semanas',           75.00,  'Dra. Ortega',  'completada'),
(18, '2026-04-01 09:00:00', 'Revisión general',           'Sano. Parasitismo intestinal leve',                'Desparasitación oral',                    30.00,  'Dr. Castillo', 'completada'),
(20, '2026-04-10 10:00:00', 'Agresividad súbita',         'Hipotiroidismo',                                   'Levotiroxina diaria, control mensual',    80.00,  'Dr. Ramírez',  'completada'),
(20, '2026-05-10 10:00:00', 'Control hipotiroidismo',     'Niveles estables',                                 'Mantener dosis',                          35.00,  'Dr. Ramírez',  'completada'),
(20, '2026-06-10 10:00:00', 'Control hipotiroidismo',     'Niveles estables',                                 'Mantener dosis',                          35.00,  'Dr. Ramírez',  'completada'),
(20, '2025-07-10 10:00:00', 'Control hipotiroidismo',     'Niveles estables',                                 'Mantener dosis',                          35.00,  'Dr. Ramírez',  'completada'),
(20, '2025-08-10 10:00:00', 'Control hipotiroidismo',     'Niveles estables',                                 'Mantener dosis',                          35.00,  'Dr. Ramírez',  'completada'),
(21, '2026-04-15 11:30:00', 'No usa arenero',             'Cistitis idiopática felina',                       'Analgesia + cambio arenero + dieta',      55.00,  'Dra. Vargas',  'completada'),
(23, '2026-04-25 14:00:00', 'Raspadura en nariz',         'Dermatitis superficial',                           'Antiséptico tópico 7 días',               20.00,  'Dra. Ortega',  'completada'),
(25, '2026-05-07 11:00:00', 'Primer control cachorro',    'Sano. Calendario vacunal iniciado',                'Vitaminas + desparasitación',             30.00,  'Dra. Fuentes', 'completada'),
(26, '2026-05-12 13:00:00', 'Herida en pelea',            'Absceso subcutáneo en hombro',                     'Drenaje + antibiótico 10 días',           95.00,  'Dr. Ramírez',  'completada'),
(28, '2026-05-22 10:00:00', 'Infección ótica',            'Otitis externa bacteriana bilateral',              'Limpieza + gotas antibióticas',           65.00,  'Dr. Mora',     'completada'),
(29, '2026-05-28 14:00:00', 'Cojera pata delantera',      'Displasia de codo grado II',                       'Antiinflamatorio + condroprotector',     110.00,  'Dra. Ortega',  'completada'),
(29, '2025-06-28 14:00:00', 'Revisión codo',              'Mejora leve',                                      'Continuar antiinflamatorio',              35.00,  'Dra. Ortega',  'completada'),
(31, '2026-06-08 11:00:00', 'Revisión anual',             'Sano. Control parasitario al día',                 'Pipeta antiparasitaria',                  25.00,  'Dra. Fuentes', 'completada'),
(33, '2026-06-18 13:30:00', 'Temblores',                  'Hipoglucemia',                                     'Glucosa IV + alimentación cada 4h',       80.00,  'Dra. Vargas',  'completada'),
(34, '2025-06-22 08:30:00', 'Control peso',               'Obesidad grado II',                                'Dieta hipocalórica + ejercicio',          30.00,  'Dr. Mora',     'completada'),
(35, '2025-07-01 10:00:00', 'Revisión piel sin pelo',     'Sano. Piel hidratada normal',                      'Hidratante dérmico felino',               35.00,  'Dra. Ortega',  'completada'),
(36, '2025-07-05 14:00:00', 'Dificultad respiratoria',    'Braquicefalia: síndrome obstructivo',              'Evaluación quirúrgica programada',       200.00,  'Dr. Castillo', 'completada'),
(36, '2025-07-15 14:00:00', 'Cirugía braquicefálica',     'Exitosa',                                          'Reposo absoluto',                        500.00,  'Dr. Castillo', 'completada'),
(36, '2025-07-25 14:00:00', 'Revisión post-quirúrgica',   'Buena cicatrización',                              'Alta parcial',                            40.00,  'Dr. Castillo', 'completada'),
(38, '2025-07-15 11:00:00', 'Picazón excesiva',           'Alergia ambiental (atopía)',                        'Antihistamínico + champú medicinal',      50.00,  'Dr. Ramírez',  'completada'),
(39, '2025-07-20 13:00:00', 'Peluda come menos',          'Gingivitis crónica',                               'Profilaxis dental + antibiótico',        115.00,  'Dra. Vargas',  'completada'),
(40, '2025-08-01 10:00:00', 'Chequeo general',            'Sano',                                             'Ninguno',                                 25.00,  'Dr. Mora',     'completada'),
(40, '2025-08-15 10:00:00', 'Vómitos esporádicos',        'Gastritis',                                        'Dieta blanda',                            35.00,  'Dr. Mora',     'completada'),
(42, '2025-08-06 14:00:00', 'Luxación cadera',            'Displasia de cadera bilateral',                    'Fisioterapia + condroprotector 6m',      180.00,  'Dr. Castillo', 'completada'),
(42, '2025-09-06 14:00:00', 'Control cadera',             'Evolución favorable',                              'Continuar fisioterapia',                  45.00,  'Dr. Castillo', 'completada'),
(44, '2025-08-16 11:00:00', 'Bulto en cuello',            'Lipoma benigno',                                   'Extirpación quirúrgica',                  250.00,  'Dr. Ramírez',  'completada'),
(44, '2025-08-26 11:00:00', 'Retiro de puntos',           'Bien',                                             'Ninguno',                                 20.00,  'Dr. Ramírez',  'completada'),
(46, '2025-08-27 09:00:00', 'Desgarramiento muscular',    'Rotura parcial LCA rodilla izq.',                  'Cirugía ortopédica + fisioterapia',      350.00,  'Dr. Mora',     'completada'),
(46, '2025-09-10 09:00:00', 'Fisioterapia sesión 1',      'Buena respuesta',                                  'Ejercicios en casa',                      35.00,  'Dr. Mora',     'completada'),
(46, '2025-09-17 09:00:00', 'Fisioterapia sesión 2',      'Mejora movilidad',                                 'Aumentar carga',                          35.00,  'Dr. Mora',     'completada'),
(46, '2025-09-24 09:00:00', 'Fisioterapia sesión 3',      'Casi normal',                                      'Alta deportiva próxima',                  35.00,  'Dr. Mora',     'completada'),
(49, '2025-09-12 09:00:00', 'Revisión general',           'Sana. Excelente condición',                        'Preventivo. Control en 6 meses',          25.00,  'Dra. Fuentes', 'completada'),
(50, '2025-09-17 11:00:00', 'Rasca orejas',               'Ácaros (otoacariosis)',                            'Auriculares acaricidas 14 días',          45.00,  'Dr. Ramírez',  'completada'),
(50, '2025-10-01 11:00:00', 'Control ácaros',             'Sin presencia de ácaros',                          'Alta',                                    20.00,  'Dr. Ramírez',  'completada'),
(2,  '2025-10-15 10:00:00', 'Vómitos',                    'Indigestión',                                      'Dieta blanda',                            30.00,  'Dr. Ramírez',  'pendiente'),
(8,  '2025-10-16 09:30:00', 'Revisión dental post lim.',  'Sarro controlado',                                 'Cepillado en casa',                       25.00,  'Dr. Ramírez',  'en_curso');

