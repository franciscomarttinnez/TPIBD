/*
  Sistema de Gestión para Concesionaria
  Script 2/3 - Inserción de datos de prueba
*/
USE Concesionaria;
GO

INSERT INTO MARCA (nombre, pais_origen) VALUES
(N'Toyota', N'Japón'),
(N'Volkswagen', N'Alemania'),
(N'Ford', N'Estados Unidos'),
(N'Chevrolet', N'Estados Unidos');

INSERT INTO MODELO (id_modelo, denominacion, version, anio_fabricacion, precio_lista, activo, nombre_marca) VALUES
(1, N'Corolla', N'XEI 2.0', 2024, 28500000.00, 1, N'Toyota'),
(2, N'Hilux', N'SRV 4x4', 2023, 42000000.00, 1, N'Toyota'),
(3, N'Gol', N'Trendline', 2022, 15500000.00, 1, N'Volkswagen'),
(4, N'Amarok', N'Comfortline', 2024, 48000000.00, 1, N'Volkswagen'),
(5, N'Ranger', N'XLT', 2023, 39500000.00, 1, N'Ford'),
(6, N'Onix', N'LTZ', 2024, 19800000.00, 1, N'Chevrolet');

INSERT INTO SUCURSAL (codigo_suc, nombre, direccion, telefono, correo) VALUES
(N'SUC-RES', N'Sucursal Resistencia', N'Av. 25 de Mayo 1200', N'3624123456', N'resistencia@concesionaria.com'),
(N'SUC-COR', N'Sucursal Corrientes', N'Junín 850', N'3794456789', N'corrientes@concesionaria.com'),
(N'SUC-FOR', N'Sucursal Formosa', N'San Martín 400', N'3704223344', N'formosa@concesionaria.com');

INSERT INTO EMPLEADO (legajo, nombre_completo, fecha_ingreso, telefono, correo, cod_sucursal) VALUES
(1001, N'Ana Pérez',       '2020-03-15', N'3624111001', N'ana.perez@concesionaria.com',       N'SUC-RES'),
(1002, N'Bruno Gómez',     '2021-06-01', N'3624111002', N'bruno.gomez@concesionaria.com',     N'SUC-RES'),
(1003, N'Carla Díaz',      '2019-11-20', N'3794111003', N'carla.diaz@concesionaria.com',      N'SUC-COR'),
(1004, N'Diego Fernández', '2022-01-10', N'3794111004', N'diego.fernandez@concesionaria.com', N'SUC-COR'),
(1005, N'Elena Ruiz',      '2023-05-02', N'3704111005', N'elena.ruiz@concesionaria.com',      N'SUC-FOR'),
(2001, N'Fabiana López',   '2018-08-12', N'3624222001', N'fabiana.lopez@concesionaria.com',   N'SUC-RES'),
(2002, N'Gastón Torres',   '2020-09-01', N'3794222002', N'gaston.torres@concesionaria.com',   N'SUC-COR');

INSERT INTO VENDEDOR (legajo) VALUES (1001), (1002), (1003), (1004), (1005);
INSERT INTO ADMINISTRATIVO (legajo) VALUES (2001), (2002);

INSERT INTO PROVEEDOR (cuit, razon_social, domicilio, telefono, correo) VALUES
(N'30546789123', N'Toyota Argentina S.A.',      N'Av. del Libertador 1000, CABA', N'1145551000', N'ventas@toyota.com.ar'),
(N'30678901234', N'Volkswagen Argentina S.A.',  N'Ruta 9 Km 36, Gral. Pacheco',  N'1145552000', N'ventas@vw.com.ar'),
(N'30789012345', N'Ford Argentina S.C.A.',      N'Ruta 8 Km 36, Pacheco',        N'1145553000', N'ventas@ford.com.ar'),
(N'30890123456', N'Autos del Litoral SRL',      N'Av. Belgrano 500, Resistencia', N'3624555666', N'contacto@autoslitoral.com');

-- Ford (307...) solo tiene adquisiciones en 2024
INSERT INTO ADQUISICION (num_comprobante, fecha, tipo_comprobante, importe_total, cuit_proveedor) VALUES
(N'FC-A-0001', '2024-01-15', N'Factura A', 85500000.00, N'30546789123'),
(N'FC-A-0002', '2024-03-10', N'Factura A', 63500000.00, N'30678901234'),
(N'FC-A-0003', '2024-06-20', N'Factura A', 39500000.00, N'30789012345'),
(N'FC-A-0004', '2025-02-05', N'Factura A', 39600000.00, N'30546789123'),
(N'FC-B-0005', '2025-08-12', N'Factura B', 19800000.00, N'30890123456');

INSERT INTO UNIDAD_VEHICULO
(num_serie, num_motor, color, fecha_ingreso, condicion, precio_venta, estado_actual, id_modelo, codigo_suc, num_comprobante)
VALUES
(N'JTDBR32E900000001', N'MOT-T-001', N'Blanco',  '2024-01-18', N'Nuevo', 28500000.00, N'Vendido',    1, N'SUC-RES', N'FC-A-0001'),
(N'JTDBR32E900000002', N'MOT-T-002', N'Gris',    '2024-01-18', N'Nuevo', 28500000.00, N'Disponible', 1, N'SUC-RES', N'FC-A-0001'),
(N'JTDBR32E900000003', N'MOT-T-003', N'Negro',   '2024-01-20', N'Nuevo', 42000000.00, N'Vendido',    2, N'SUC-RES', N'FC-A-0001'),
(N'WVWZZZ1JZ00000004', N'MOT-V-004', N'Rojo',    '2024-03-12', N'Nuevo', 15500000.00, N'Disponible', 3, N'SUC-COR', N'FC-A-0002'),
(N'WVWZZZ1JZ00000005', N'MOT-V-005', N'Plata',   '2024-03-12', N'Nuevo', 48000000.00, N'Vendido',    4, N'SUC-COR', N'FC-A-0002'),
(N'WVWZZZ1JZ00000006', N'MOT-V-006', N'Azul',    '2024-03-15', N'Nuevo', 15500000.00, N'Disponible', 3, N'SUC-COR', N'FC-A-0002'),
(N'1FTEW1EP5PFA00007', N'MOT-F-007', N'Blanco',  '2024-06-22', N'Nuevo', 39500000.00, N'Disponible', 5, N'SUC-FOR', N'FC-A-0003'),
(N'JTDBR32E900000008', N'MOT-T-008', N'Gris',    '2025-02-08', N'Nuevo', 29000000.00, N'Disponible', 1, N'SUC-RES', N'FC-A-0004'),
(N'JTDBR32E900000009', N'MOT-T-009', N'Blanco',  '2025-02-08', N'Nuevo', 42500000.00, N'Reservado',  2, N'SUC-RES', N'FC-A-0004'),
(N'LSGUD84X9EE000010', N'MOT-C-010', N'Negro',   '2025-08-15', N'Nuevo', 19800000.00, N'Vendido',    6, N'SUC-FOR', N'FC-B-0005'),
-- Usados por parte de pago (sin adquisición)
(N'USEDPPAY000000011', N'MOT-U-011', N'Verde',   '2024-09-01', N'Usado', 9800000.00,  N'Vendido',    3, N'SUC-RES', NULL),
(N'USEDPPAY000000012', N'MOT-U-012', N'Gris',    '2025-01-20', N'Usado', 12500000.00, N'Disponible', 1, N'SUC-COR', NULL);

INSERT INTO CLIENTE (tipo_documento, num_documento, nombre_completo, domicilio, correo) VALUES
(N'DNI', N'30111222', N'Martín Álvarez',   N'Calle Falsa 123, Resistencia', N'martin.alvarez@mail.com'),
(N'DNI', N'28999888', N'Lucía Romero',     N'Belgrano 456, Corrientes',     N'lucia.romero@mail.com'),
(N'DNI', N'32555666', N'Pablo Sánchez',    N'San Martín 789, Formosa',      N'pablo.sanchez@mail.com'),
(N'DNI', N'27444333', N'Sofía Méndez',     N'Italia 321, Resistencia',      N'sofia.mendez@mail.com'),
(N'CUIT',N'20333444556', N'Transporte Norte SA', N'Ruta 11 Km 5',           N'admin@tnorte.com');

INSERT INTO CONTACTO_TELEFONICO (tipo_documento, num_documento, telefono, nombre_contacto) VALUES
(N'DNI', N'30111222', N'3624555001', N'Martín Álvarez'),
(N'DNI', N'30111222', N'3624555002', N'Esposa - Laura Álvarez'),
(N'DNI', N'28999888', N'3794555003', N'Lucía Romero'),
(N'DNI', N'32555666', N'3704555004', N'Pablo Sánchez'),
(N'DNI', N'27444333', N'3624555005', N'Sofía Méndez'),
(N'CUIT',N'20333444556', N'3624999000', N'Recepción Transporte Norte');

INSERT INTO PLANES (cod_plan, descripcion, porcentaje_financiacion, cantidad_cuotas, interes_anual) VALUES
(N'PLAN-12', N'Financiación 12 cuotas', 70.00, 12, 45.00),
(N'PLAN-24', N'Financiación 24 cuotas', 60.00, 24, 52.00),
(N'PLAN-36', N'Financiación 36 cuotas', 50.00, 36, 58.00),
(N'PLAN-48', N'Financiación 48 cuotas', 40.00, 48, 62.00);

INSERT INTO ACCESORIO (codigo, descripcion, precio, disponible) VALUES
(N'ACC-01', N'Alarma perimetral',     250000.00, 1),
(N'ACC-02', N'Cubiertas reforzadas',  480000.00, 1),
(N'ACC-03', N'Tapizados de cuero',    650000.00, 1),
(N'ACC-04', N'Sensor de estacionamiento', 180000.00, 1);

INSERT INTO BOLETO
(num_boleto, fecha_emision, importe_total, estado, cod_plan, legajo_vendedor, tipo_documento, num_documento, num_serie)
VALUES
(1001, '2024-09-01', 28500000.00, N'confirmado',      N'PLAN-12', 1001, N'DNI', N'30111222', N'JTDBR32E900000001'),
(1002, '2024-10-15', 48000000.00, N'confirmado',      N'PLAN-24', 1003, N'DNI', N'28999888', N'WVWZZZ1JZ00000005'),
(1003, '2025-01-20', 42000000.00, N'confirmado',      NULL,       1002, N'DNI', N'27444333', N'JTDBR32E900000003'),
(1004, '2025-03-05', 10500000.00, N'confirmado',      N'PLAN-12', 1001, N'DNI', N'32555666', N'USEDPPAY000000011'),
(1005, '2025-04-18', 42500000.00, N'en negociación',  N'PLAN-36', 1004, N'CUIT',N'20333444556', N'JTDBR32E900000009'),
(1006, '2025-05-01', 15500000.00, N'cancelado',       NULL,       1003, N'DNI', N'28999888', N'WVWZZZ1JZ00000004'),
(1007, '2025-07-10', 19800000.00, N'confirmado',      N'PLAN-24', 1004, N'DNI', N'27444333', N'LSGUD84X9EE000010');

INSERT INTO PARTE_PAGO (num_boleto, num_serie, valor_reconocido) VALUES
(1001, N'USEDPPAY000000011', 8500000.00),
(1003, N'USEDPPAY000000012', 11000000.00);

INSERT INTO BOLETO_ACCESORIO (num_boleto, codigo) VALUES
(1001, N'ACC-01'),
(1001, N'ACC-04'),
(1002, N'ACC-02'),
(1002, N'ACC-03'),
(1004, N'ACC-01');

INSERT INTO PAGO (id_pago, fecha_vencimiento, importe, estado, num_boleto) VALUES
(1,  '2024-10-01', 1200000.00, N'pagado',    1001),
(2,  '2024-11-01', 1200000.00, N'pagado',    1001),
(3,  '2024-12-01', 1200000.00, N'vencido',   1001),
(4,  '2025-01-01', 1200000.00, N'pendiente', 1001),
(5,  '2025-02-01', 1200000.00, N'pendiente', 1001),
(6,  '2024-11-15', 1500000.00, N'pagado',    1002),
(7,  '2024-12-15', 1500000.00, N'pagado',    1002),
(8,  '2025-01-15', 1500000.00, N'pendiente', 1002),
(9,  '2025-02-15', 1500000.00, N'pendiente', 1002),
(10, '2025-04-05', 700000.00,  N'pagado',    1004),
(11, '2025-05-05', 700000.00,  N'pendiente', 1004),
(12, '2025-06-05', 700000.00,  N'pendiente', 1004),
(13, '2025-08-10', 900000.00,  N'pendiente', 1007),
(14, '2025-09-10', 900000.00,  N'pendiente', 1007);
GO
