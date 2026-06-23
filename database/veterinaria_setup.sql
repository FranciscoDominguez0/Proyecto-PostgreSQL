CREATE DATABASE veterinaria_db;


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
-- 50 MASCOTAS
-- =============================================
INSERT INTO mascotas (nombre, especie, raza, fecha_nacimiento, sexo, propietario_id) VALUES
('Max',       'Perro',   'Labrador Retriever',   '2020-03-15', 'M', 1),
('Luna',      'Gato',    'Siamés',               '2019-07-22', 'H', 2),
('Rocky',     'Perro',   'German Shepherd',      '2021-01-10', 'M', 3),
('Mia',       'Gato',    'Persa',                '2020-11-05', 'H', 4),
('Buddy',     'Perro',   'Golden Retriever',     '2019-05-30', 'M', 5),
('Daisy',     'Perro',   'Poodle',               '2022-02-14', 'H', 6),
('Simba',     'Gato',    'Maine Coon',           '2021-08-20', 'M', 7),
('Bella',     'Perro',   'Beagle',               '2020-09-12', 'H', 8),
('Kiko',      'Ave',     'Loro Amazónico',       '2018-04-01', 'M', 9),
('Coco',      'Conejo',  'Holland Lop',          '2022-06-18', 'H', 10),
('Thor',      'Perro',   'Rottweiler',           '2021-12-03', 'M', 11),
('Nala',      'Gato',    'Bengalí',              '2020-05-25', 'H', 12),
('Chico',     'Perro',   'Chihuahua',            '2019-10-08', 'M', 13),
('Lola',      'Perro',   'Dachshund',            '2022-03-27', 'H', 14),
('Pita',      'Ave',     'Cacatúa',              '2017-09-15', 'H', 15),
('Tobi',      'Perro',   'Boxer',                '2021-07-04', 'M', 16),
('Sofía',     'Gato',    'Ragdoll',              '2020-01-19', 'H', 17),
('Oliver',    'Perro',   'Border Collie',        '2022-08-11', 'M', 18),
('Penny',     'Conejo',  'Mini Rex',             '2023-01-07', 'H', 19),
('Rex',       'Perro',   'Dóberman',             '2020-04-22', 'M', 20),
('Mochi',     'Gato',    'Scottish Fold',        '2021-11-30', 'H', 21),
('Spike',     'Reptil',  'Iguana Verde',         '2019-06-14', 'M', 22),
('Zara',      'Perro',   'Husky Siberiano',      '2022-05-09', 'H', 23),
('Leo',       'Gato',    'British Shorthair',    '2020-12-01', 'M', 24),
('Copito',    'Perro',   'Bichón Maltés',        '2023-02-20', 'M', 25),
('Kira',      'Perro',   'Pitbull',              '2021-04-16', 'H', 26),
('Pepe',      'Ave',     'Periquito',            '2020-07-30', 'M', 27),
('Canela',    'Perro',   'Cocker Spaniel',       '2019-08-25', 'H', 28),
('Zeus',      'Perro',   'Gran Danés',           '2021-02-28', 'M', 29),
('Mango',     'Gato',    'Abisinino',            '2022-10-13', 'M', 30),
('Sasha',     'Perro',   'Schnauzer Miniatura',  '2020-06-06', 'H', 31),
('Gizmo',     'Reptil',  'Gecko Leopardo',       '2021-03-17', 'M', 32),
('Nina',      'Perro',   'Yorkshire Terrier',    '2022-11-22', 'H', 33),
('Bruno',     'Perro',   'San Bernardo',         '2019-09-01', 'M', 34),
('Cleo',      'Gato',    'Sphynx',               '2021-05-08', 'H', 35),
('Nacho',     'Perro',   'French Bulldog',       '2022-01-15', 'M', 36),
('Aria',      'Ave',     'Canario',              '2020-03-04', 'H', 37),
('Toto',      'Perro',   'Shih Tzu',             '2021-09-27', 'M', 38),
('Frida',     'Gato',    'Angora',               '2020-02-10', 'H', 39),
('Gus',       'Perro',   'Bulldog Inglés',       '2022-07-19', 'M', 40),
('Misha',     'Gato',    'Ruso Azul',            '2021-06-23', 'H', 41),
('Titán',     'Perro',   'Alaskan Malamute',     '2020-08-14', 'M', 42),
('Beba',      'Conejo',  'Angora',               '2023-03-05', 'H', 43),
('Pumba',     'Perro',   'Bulldog Francés',      '2021-10-18', 'M', 44),
('Nia',       'Gato',    'Europeo',              '2022-04-02', 'H', 45),
('Flash',     'Perro',   'Whippet',              '2020-11-29', 'M', 46),
('Pelusa',    'Conejo',  'Enano Holandés',       '2023-05-11', 'H', 47),
('Draco',     'Reptil',  'Dragón Barbudo',       '2021-01-25', 'M', 48),
('Rosie',     'Perro',   'Cavalier King Charles','2022-09-08', 'H', 49),
('Tigre',     'Gato',    'Común Europeo',        '2019-12-17', 'M', 50);

-- =============================================
-- 50 VACUNAS
-- =============================================
INSERT INTO vacunas (mascota_id, nombre_vacuna, fecha_aplicacion, fecha_proxima, veterinario, lote, observaciones) VALUES
(1,  'Parvovirus Canino',         '2024-01-10', '2025-01-10', 'Dra. Ortega',    'LOT-2024-001', 'Sin reacciones adversas'),
(2,  'Triple Felina (HCP)',       '2024-01-15', '2025-01-15', 'Dr. Ramírez',    'LOT-2024-002', 'Primera dosis'),
(3,  'Rabia',                     '2024-01-20', '2025-01-20', 'Dra. Vargas',    'LOT-2024-003', 'Requerida por ley'),
(4,  'Leucemia Felina',           '2024-02-05', '2025-02-05', 'Dr. Mora',       'LOT-2024-004', 'Refuerzo anual'),
(5,  'Distemper Canino',          '2024-02-10', '2025-02-10', 'Dra. Ortega',    'LOT-2024-005', 'Completada serie'),
(6,  'Tos de las Perreras',       '2024-02-14', '2025-02-14', 'Dr. Castillo',   'LOT-2024-006', 'Vía intranasal'),
(7,  'Calicivirus Felino',        '2024-02-20', '2025-02-20', 'Dra. Fuentes',   'LOT-2024-007', 'Sin novedad'),
(8,  'Rabia',                     '2024-03-01', '2025-03-01', 'Dr. Ramírez',    'LOT-2024-008', 'Refuerzo anual'),
(9,  'Newcastle (Aves)',          '2024-03-05', '2024-09-05', 'Dra. Vargas',    'LOT-2024-009', 'Ave exótica, dosis reducida'),
(10, 'RHDV2 (Conejos)',          '2024-03-10', '2025-03-10', 'Dr. Mora',       'LOT-2024-010', 'Primera vacuna'),
(11, 'Parvovirus Canino',        '2024-03-15', '2025-03-15', 'Dra. Ortega',    'LOT-2024-011', 'Cachorro, serie completa'),
(12, 'Panleucopenia Felina',     '2024-03-20', '2025-03-20', 'Dr. Castillo',   'LOT-2024-012', 'Gato adulto'),
(13, 'DAPP (Cuádruple)',         '2024-04-01', '2025-04-01', 'Dra. Fuentes',   'LOT-2024-013', 'Chihuahua adulto'),
(14, 'Rabia',                    '2024-04-05', '2025-04-05', 'Dr. Ramírez',    'LOT-2024-014', 'Obligatoria Panamá'),
(15, 'Psitacosis (Aves)',        '2024-04-10', '2025-04-10', 'Dra. Vargas',    'LOT-2024-015', 'Aves de compañía'),
(16, 'Leptospirosis',            '2024-04-15', '2025-04-15', 'Dr. Mora',       'LOT-2024-016', 'Zona húmeda, recomendada'),
(17, 'Herpesvirus Felino',       '2024-04-20', '2025-04-20', 'Dra. Ortega',    'LOT-2024-017', 'Gata con historial respiratorio'),
(18, 'Rabia',                    '2024-05-02', '2025-05-02', 'Dr. Castillo',   'LOT-2024-018', 'Perro fronterizo'),
(19, 'RHDV2 (Conejos)',         '2024-05-07', '2025-05-07', 'Dra. Fuentes',   'LOT-2024-019', 'Conejo enano'),
(20, 'Distemper Canino',         '2024-05-12', '2025-05-12', 'Dr. Ramírez',    'LOT-2024-020', 'Dóberman adulto'),
(21, 'Triple Felina (HCP)',      '2024-05-18', '2025-05-18', 'Dra. Vargas',    'LOT-2024-021', 'Scottish Fold'),
(22, 'Salmonelosis (Reptil)',    '2024-05-22', '2025-05-22', 'Dr. Mora',       'LOT-2024-022', 'Iguana 5 años'),
(23, 'Rabia',                    '2024-05-28', '2025-05-28', 'Dra. Ortega',    'LOT-2024-023', 'Husky adulta'),
(24, 'Leucemia Felina',          '2024-06-03', '2025-06-03', 'Dr. Castillo',   'LOT-2024-024', 'British adulto'),
(25, 'DAPP (Cuádruple)',        '2024-06-08', '2025-06-08', 'Dra. Fuentes',   'LOT-2024-025', 'Cachorro Maltés'),
(26, 'Parvovirus Canino',        '2024-06-13', '2025-06-13', 'Dr. Ramírez',    'LOT-2024-026', 'Pitbull joven'),
(27, 'Newcastle (Aves)',         '2024-06-18', '2024-12-18', 'Dra. Vargas',    'LOT-2024-027', 'Periquito adulto'),
(28, 'Tos de las Perreras',     '2024-06-22', '2025-06-22', 'Dr. Mora',       'LOT-2024-028', 'Cocker Spaniel'),
(29, 'Rabia',                    '2024-07-01', '2025-07-01', 'Dra. Ortega',    'LOT-2024-029', 'Gran Danés adulto'),
(30, 'Calicivirus Felino',       '2024-07-05', '2025-07-05', 'Dr. Castillo',   'LOT-2024-030', 'Abisinino'),
(31, 'Leptospirosis',            '2024-07-10', '2025-07-10', 'Dra. Fuentes',   'LOT-2024-031', 'Schnauzer activo'),
(32, 'Ofidismo preventivo',      '2024-07-15', '2025-07-15', 'Dr. Ramírez',    'LOT-2024-032', 'Gecko leopardo, preventivo'),
(33, 'DAPP (Cuádruple)',        '2024-07-20', '2025-07-20', 'Dra. Vargas',    'LOT-2024-033', 'Yorkshire terrier'),
(34, 'Rabia',                    '2024-07-25', '2025-07-25', 'Dr. Mora',       'LOT-2024-034', 'San Bernardo adulto'),
(35, 'Panleucopenia Felina',     '2024-08-01', '2025-08-01', 'Dra. Ortega',    'LOT-2024-035', 'Sphynx sin pelaje'),
(36, 'Distemper Canino',         '2024-08-06', '2025-08-06', 'Dr. Castillo',   'LOT-2024-036', 'French Bulldog'),
(37, 'Psitacosis (Aves)',        '2024-08-11', '2025-08-11', 'Dra. Fuentes',   'LOT-2024-037', 'Canario hembra'),
(38, 'Tos de las Perreras',     '2024-08-16', '2025-08-16', 'Dr. Ramírez',    'LOT-2024-038', 'Shih Tzu, refuerzo'),
(39, 'Herpesvirus Felino',       '2024-08-21', '2025-08-21', 'Dra. Vargas',    'LOT-2024-039', 'Angora adulta'),
(40, 'Rabia',                    '2024-08-27', '2025-08-27', 'Dr. Mora',       'LOT-2024-040', 'Bulldog inglés'),
(41, 'Leucemia Felina',          '2024-09-02', '2025-09-02', 'Dra. Ortega',    'LOT-2024-041', 'Ruso Azul'),
(42, 'Parvovirus Canino',        '2024-09-07', '2025-09-07', 'Dr. Castillo',   'LOT-2024-042', 'Malamute adulto'),
(43, 'RHDV2 (Conejos)',         '2024-09-12', '2025-09-12', 'Dra. Fuentes',   'LOT-2024-043', 'Conejo angora'),
(44, 'DAPP (Cuádruple)',        '2024-09-17', '2025-09-17', 'Dr. Ramírez',    'LOT-2024-044', 'Bulldog Francés adulto'),
(45, 'Triple Felina (HCP)',      '2024-09-22', '2025-09-22', 'Dra. Vargas',    'LOT-2024-045', 'Gato europeo'),
(46, 'Leptospirosis',            '2024-09-27', '2025-09-27', 'Dr. Mora',       'LOT-2024-046', 'Whippet corredor'),
(47, 'RHDV2 (Conejos)',         '2024-10-02', '2025-10-02', 'Dra. Ortega',    'LOT-2024-047', 'Conejo enano holandés'),
(48, 'Salmonelosis (Reptil)',   '2024-10-07', '2025-10-07', 'Dr. Castillo',   'LOT-2024-048', 'Dragón barbudo joven'),
(49, 'Rabia',                   '2024-10-12', '2025-10-12', 'Dra. Fuentes',   'LOT-2024-049', 'Cavalier adulta'),
(50, 'Calicivirus Felino',      '2024-10-17', '2025-10-17', 'Dr. Ramírez',    'LOT-2024-050', 'Gato común europeo');

-- =============================================
-- 50 CONSULTAS
-- =============================================
INSERT INTO consultas (mascota_id, fecha_consulta, motivo, diagnostico, tratamiento, costo, veterinario, estado) VALUES
(1,  '2024-01-05 09:00:00', 'Revisión general',           'Sano. Excelente condición física',                 'Ninguno. Preventivo',                     25.00,  'Dra. Ortega',  'completada'),
(2,  '2024-01-08 10:30:00', 'Pérdida de apetito',         'Gastroenteritis leve',                             'Dieta blanda, metronidazol 7 días',       35.00,  'Dr. Ramírez',  'completada'),
(3,  '2024-01-12 14:00:00', 'Cojera pata trasera',        'Esguince leve en articulación tibiotarsal',        'Reposo, antiinflamatorio 5 días',         40.00,  'Dra. Vargas',  'completada'),
(4,  '2024-01-15 11:00:00', 'Estornudos frecuentes',      'Rinotraqueítis viral felina',                      'Antibiótico + suero ocular 10 días',      50.00,  'Dr. Mora',     'completada'),
(5,  '2024-01-20 09:30:00', 'Control post-vacuna',        'Reacción leve en sitio de inyección',              'Antihistamínico 3 días',                  20.00,  'Dra. Ortega',  'completada'),
(6,  '2024-02-01 08:00:00', 'Vómito repetitivo',          'Obstrucción parcial por cuerpo extraño',           'Ayuno + fluidoterapia + radiografías',    85.00,  'Dr. Castillo', 'completada'),
(7,  '2024-02-05 15:00:00', 'Prurito intenso',            'Alergia alimentaria',                              'Cambio de dieta, antihistamínicos',       45.00,  'Dra. Fuentes', 'completada'),
(8,  '2024-02-10 10:00:00', 'Limpieza dental',            'Sarro moderado',                                   'Profilaxis dental bajo anestesia',       120.00,  'Dr. Ramírez',  'completada'),
(9,  '2024-02-14 13:00:00', 'Pérdida de plumas',          'Psitacosis inicial',                               'Doxiciclina 30 días + aislamiento',       60.00,  'Dra. Vargas',  'completada'),
(10, '2024-02-18 09:00:00', 'Revisión general conejo',    'Maloclusión dental leve',                          'Corrección dental + dieta heno',          55.00,  'Dr. Mora',     'completada'),
(11, '2024-02-22 11:00:00', 'Herida en pata delantera',   'Laceración superficial',                           'Limpieza, sutura, antibiótico 5 días',    70.00,  'Dra. Ortega',  'completada'),
(12, '2024-03-01 14:30:00', 'Cambio comportamiento',      'Estrés ambiental',                                 'Feliway difusor + enriquecimiento',       30.00,  'Dr. Castillo', 'completada'),
(13, '2024-03-05 09:00:00', 'Tos crónica',                'Colapso de tráquea grado I',                       'Tos supresores, evitar collar',           65.00,  'Dra. Fuentes', 'completada'),
(14, '2024-03-10 10:00:00', 'Revisión anual',             'Obesidad leve (sobrepeso 500g)',                   'Dieta balanceada, ejercicio diario',      25.00,  'Dr. Ramírez',  'completada'),
(15, '2024-03-15 15:00:00', 'Ave no come',                'Carencia vitamínica',                              'Suplemento vitamínico en agua',           40.00,  'Dra. Vargas',  'completada'),
(16, '2024-03-20 08:30:00', 'Diarrea con sangre',         'Colitis hemorrágica',                              'Hospitalización 48h, fluidoterapia',     150.00,  'Dr. Mora',     'completada'),
(17, '2024-03-25 11:00:00', 'Ojo cerrado',                'Úlcera corneal OD',                                'Colirio antibiótico 2 semanas',           75.00,  'Dra. Ortega',  'completada'),
(18, '2024-04-01 09:00:00', 'Revisión general',           'Sano. Parasitismo intestinal leve',                'Desparasitación oral',                    30.00,  'Dr. Castillo', 'completada'),
(19, '2024-04-05 14:00:00', 'Uña rota conejo',            'Fractura de falange distal',                       'Vendaje + reposo 2 semanas',              45.00,  'Dra. Fuentes', 'completada'),
(20, '2024-04-10 10:00:00', 'Agresividad súbita',         'Hipotiroidismo',                                   'Levotiroxina diaria, control mensual',    80.00,  'Dr. Ramírez',  'completada'),
(21, '2024-04-15 11:30:00', 'No usa arenero',             'Cistitis idiopática felina',                       'Analgesia + cambio arenero + dieta',      55.00,  'Dra. Vargas',  'completada'),
(22, '2024-04-20 09:00:00', 'Iguana sin comer',           'Síndrome metabólico óseo',                         'Suplemento Ca + lámpara UV-B',            90.00,  'Dr. Mora',     'completada'),
(23, '2024-04-25 14:00:00', 'Raspadura en nariz',         'Dermatitis superficial',                           'Antiséptico tópico 7 días',               20.00,  'Dra. Ortega',  'completada'),
(24, '2024-05-02 09:30:00', 'Pelaje opaco',               'Deficiencia de ácidos grasos omega-3',             'Suplemento Omega + dieta premium',        35.00,  'Dr. Castillo', 'completada'),
(25, '2024-05-07 11:00:00', 'Primer control cachorro',    'Sano. Calendario vacunal iniciado',                'Vitaminas + desparasitación',             30.00,  'Dra. Fuentes', 'completada'),
(26, '2024-05-12 13:00:00', 'Herida en pelea',            'Absceso subcutáneo en hombro',                     'Drenaje + antibiótico 10 días',           95.00,  'Dr. Ramírez',  'completada'),
(27, '2024-05-18 09:00:00', 'Periquito letárgico',        'Infección bacteriana sistémica',                   'Enrofloxacina oral + vitaminas',          50.00,  'Dra. Vargas',  'completada'),
(28, '2024-05-22 10:00:00', 'Infección ótica',            'Otitis externa bacteriana bilateral',              'Limpieza + gotas antibióticas',           65.00,  'Dr. Mora',     'completada'),
(29, '2024-05-28 14:00:00', 'Cojera pata delantera',      'Displasia de codo grado II',                       'Antiinflamatorio + condroprotector',     110.00,  'Dra. Ortega',  'completada'),
(30, '2024-06-03 09:30:00', 'Vómitos',                    'Bola de pelo (tricobezoar)',                        'Malta diaria + fibra en dieta',           25.00,  'Dr. Castillo', 'completada'),
(31, '2024-06-08 11:00:00', 'Revisión anual',             'Sano. Control parasitario al día',                 'Pipeta antiparasitaria',                  25.00,  'Dra. Fuentes', 'completada'),
(32, '2024-06-13 09:00:00', 'Gecko no mueve una pata',    'Neuropatía por déficit UV',                        'Suplemento vitamínico + calor',           70.00,  'Dr. Ramírez',  'completada'),
(33, '2024-06-18 13:30:00', 'Temblores',                  'Hipoglucemia',                                     'Glucosa IV + alimentación cada 4h',       80.00,  'Dra. Vargas',  'completada'),
(34, '2024-06-22 08:30:00', 'Control peso',               'Obesidad grado II',                                'Dieta hipocalórica + ejercicio',          30.00,  'Dr. Mora',     'completada'),
(35, '2024-07-01 10:00:00', 'Revisión piel sin pelo',     'Sano. Piel hidratada normal',                      'Hidratante dérmico felino',               35.00,  'Dra. Ortega',  'completada'),
(36, '2024-07-05 14:00:00', 'Dificultad respiratoria',    'Braquicefalia: síndrome obstructivo',              'Evaluación quirúrgica programada',       200.00,  'Dr. Castillo', 'completada'),
(37, '2024-07-10 09:00:00', 'Canario no canta',           'Laringitis aviar',                                 'Reposo + antibiótico en agua',            40.00,  'Dra. Fuentes', 'completada'),
(38, '2024-07-15 11:00:00', 'Picazón excesiva',           'Alergia ambiental (atopía)',                        'Antihistamínico + champú medicinal',      50.00,  'Dr. Ramírez',  'completada'),
(39, '2024-07-20 13:00:00', 'Peluda come menos',          'Gingivitis crónica',                               'Profilaxis dental + antibiótico',        115.00,  'Dra. Vargas',  'completada'),
(40, '2024-07-25 09:00:00', 'Revisión postvacuna',        'Reacción local, sin fiebre',                       'Antiinflamatorio 2 días',                 20.00,  'Dr. Mora',     'completada'),
(41, '2024-08-01 10:00:00', 'Peso bajo',                  'Hipertiroidismo felino',                           'Metimazol diario + control mensual',      90.00,  'Dra. Ortega',  'completada'),
(42, '2024-08-06 14:00:00', 'Luxación cadera',            'Displasia de cadera bilateral',                    'Fisioterapia + condroprotector 6m',      180.00,  'Dr. Castillo', 'completada'),
(43, '2024-08-11 09:30:00', 'Conejo no mueve cuello',     'Encéfalitozoonosis',                               'Fenbendazol 28 días + meloxicam',        100.00,  'Dra. Fuentes', 'completada'),
(44, '2024-08-16 11:00:00', 'Bulto en cuello',            'Lipoma benigno',                                   'Extirpación quirúrgica',                  250.00,  'Dr. Ramírez',  'completada'),
(45, '2024-08-21 13:00:00', 'Revisión gata europea',      'Sana. Esterilización recomendada',                 'Programar esterilización',                25.00,  'Dra. Vargas',  'completada'),
(46, '2024-08-27 09:00:00', 'Desgarramiento muscular',    'Rotura parcial LCA rodilla izq.',                  'Cirugía ortopédica + fisioterapia',      350.00,  'Dr. Mora',     'completada'),
(47, '2024-09-02 10:00:00', 'Conejo letárgico',           'Hepatitis hepática viral (HVD)',                   'Soporte + hidratación + vitamina K',     130.00,  'Dra. Ortega',  'completada'),
(48, '2024-09-07 14:00:00', 'Dragón sin apetito',         'Impactación gastrointestinal',                     'Enema + ablandador intestinal',           85.00,  'Dr. Castillo', 'completada'),
(49, '2024-09-12 09:00:00', 'Revisión general',           'Sana. Excelente condición',                        'Preventivo. Control en 6 meses',          25.00,  'Dra. Fuentes', 'completada'),
(50, '2024-09-17 11:00:00', 'Rasca orejas',               'Ácaros (otoacariosis)',                            'Auriculares acaricidas 14 días',          45.00,  'Dr. Ramírez',  'completada');
