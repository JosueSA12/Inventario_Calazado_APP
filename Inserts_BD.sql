USE [db_acbcc3_dbtaller]
GO

-- =========================================================================
-- 1. TIPOS DE USUARIO
-- =========================================================================
INSERT INTO Seguridad.TipoUsuario (TipoUsuarioCodigo, TipoUsuarioDescription) VALUES
    ('ADM01', 'Administrador General'),
    ('EMP01', 'Artesano de Taller')
GO

-- =========================================================================
-- 2. USUARIOS
-- =========================================================================
INSERT INTO Seguridad.Usuario (UsuarioID, UsuarioNombre, UsuarioLogin, UsuarioPassword, UsuarioCorreo, TipoUsuarioCodigo) VALUES
    ('USR00001', 'jsolanoam', 'admin', '123', 'admin@taller.com', 'ADM01'),
    ('USR00002', 'crodrial', 'empleado', '456', 'empleado@taller.com', 'EMP01')
GO

-- =========================================================================
-- 3. MATERIALES
-- =========================================================================
INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor) VALUES
    ('MAT00007', 'Cuero Vacuno Negro Premium', 'Cuero', 42.50, 'Metros', 'Curtiembre San José'),
    ('MAT00008', 'Cuero Vacuno Marrón Oscuro', 'Cuero', 0.30, 'Metros', 'Curtiembre San José'),
    ('MAT00009', 'Cuero Sintético Blanco', 'Cuero', 34.00, 'Metros', 'Textiles del Perú'),
    ('MAT00010', 'Cuero Sintético Gris', 'Cuero', 21.00, 'Metros', 'Textiles del Perú'),
    ('MAT00029', 'Gamusa Color Negro', 'Cuero', 90.00, 'Metros', 'Cueros Salgado SAC'),
    ('MAT00011', 'Suela de Caucho Natural N° 38', 'Suelas', 37.00, 'Pares', 'Suelas del Norte'),
    ('MAT00012', 'Suela de Caucho Natural N° 40', 'Suelas', 42.00, 'Pares', 'Suelas del Norte'),
    ('MAT00013', 'Suela de Caucho Natural N° 42', 'Suelas', 6.00, 'Pares', 'Suelas del Norte'),
    ('MAT00014', 'Suela de EVA Blanca N° 38', 'Suelas', 18.00, 'Pares', 'Suelas del Norte'),
    ('MAT00015', 'Suela de EVA Blanca N° 40', 'Suelas', 35.00, 'Pares', 'Suelas del Norte'),
    ('MAT00016', 'Hilo Poliéster Negro N° 30', 'Hilos', 22.70, 'Bobinas', 'Hilos Tex S.A.'),
    ('MAT00017', 'Hilo Poliéster Marrón N° 30', 'Hilos', 12.00, 'Bobinas', 'Hilos Tex S.A.'),
    ('MAT00018', 'Hilo Nylon Blanco N° 40', 'Hilos', 14.40, 'Bobinas', 'Hilos Tex S.A.'),
    ('MAT00027', 'Forro Textil Negro', 'Hilos', 20.90, 'Metros', 'Textiles del Perú'),
    ('MAT00028', 'Forro Textil Blanco', 'Hilos', 33.70, 'Metros', 'Textiles del Perú'),
    ('MAT00019', 'Pegamento de Contacto Industrial', 'Pegamentos / Tintes', 3.77, 'Litros', 'Químicos Distribuidora'),
    ('MAT00020', 'Pegamento de Uretano Transparente', 'Pegamentos / Tintes', 6.85, 'Litros', 'Químicos Distribuidora'),
    ('MAT00021', 'Tinte Negro para Cuero', 'Pegamentos / Tintes', 4.64, 'Litros', 'Químicos Distribuidora'),
    ('MAT00022', 'Tinte Marrón para Cuero', 'Pegamentos / Tintes', 3.87, 'Litros', 'Químicos Distribuidora'),
    ('MAT00023', 'Ojal Metálico Dorado 6mm', 'Herrajes / Ojales', 980.00, 'Unidades', 'Herrajes Perú SRL'),
    ('MAT00024', 'Ojal Metálico Plateado 6mm', 'Herrajes / Ojales', 556.00, 'Unidades', 'Herrajes Perú SRL'),
    ('MAT00025', 'Hebilla Metálica Marrón', 'Herrajes / Ojales', 193.00, 'Unidades', 'Herrajes Perú SRL')
GO

-- =========================================================================
-- 4. CALZADO
-- =========================================================================
INSERT INTO Inventario.Calzado (CalzadoCodigo, CalzadoModelo, CalzadoTipo, CalzadoColor, CalzadoTalla, CalzadoStock, CalzadoPrecioVenta) VALUES	
    ('ZAP00025', 'Bota Casual Ranger', 'bota', 'Marrón', 39, 46, 89.99),
    ('ZAP00026', 'Bota Casual Ranger', 'bota', 'Negro', 40, 20, 89.99),
    ('ZAP00027', 'Bota Casual Ranger', 'bota', 'Negro', 41, 23, 89.99),
    ('ZAP00028', 'Bota Casual Ranger', 'bota', 'Marrón', 42, 12, 89.99),
    ('ZAP00029', 'Bota Militar', 'bota', 'Negro', 41, 12, 125.00),
    ('ZAP00030', 'Bota Militar', 'bota', 'Marrón', 42, 16, 125.00),
    ('ZAP00031', 'Botín Chelsea Nobuck', 'bota', 'Negro', 39, 13, 150.00),
    ('ZAP00032', 'Botín Chelsea Nobuck', 'bota', 'Marrón', 42, 4, 150.00),
    ('ZAP00033', 'Mocasín Ejecutivo Premium', 'formal', 'Negro', 39, 3, 110.00),
    ('ZAP00034', 'Mocasín Ejecutivo Premium', 'formal', 'Negro', 41, 8, 110.00),
    ('ZAP00035', 'Mocasín Ejecutivo Premium', 'formal', 'Marrón', 40, 4, 115.00),
    ('ZAP00036', 'Mocasín Ejecutivo Premium', 'formal', 'Marrón', 42, 6, 115.00),
    ('ZAP00037', 'Zapato Derby Clásico', 'formal', 'Negro', 40, 5, 95.00),
    ('ZAP00038', 'Zapato Derby Clásico', 'formal', 'Negro', 42, 4, 95.00),
    ('ZAP00039', 'Zapato Derby Clásico', 'formal', 'Marrón', 39, 3, 98.00),
    ('ZAP00040', 'Zapato Derby Clásico', 'formal', 'Marrón', 41, 2, 98.00),
    ('ZAP00041', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 40, 24, 65.50),
    ('ZAP00042', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 41, 20, 65.50),
    ('ZAP00043', 'Zapatilla Urbana Canvas', 'urbano', 'Negro', 38, 6, 65.50),
    ('ZAP00044', 'Zapatilla Urbana Canvas', 'urbano', 'Negro', 39, 10, 65.50),
    ('ZAP00045', 'Mocasín Driver Casual', 'urbano', 'Azul', 41, 5, 79.90),
    ('ZAP00046', 'Mocasín Driver Casual', 'urbano', 'Marrón', 40, 3, 79.90),
    ('ZAP00047', 'Zapatilla Runner Pro', 'deportivo', 'Gris', 40, 18, 135.00),
    ('ZAP00048', 'Zapatilla Runner Pro', 'deportivo', 'Gris', 42, 24, 135.00),
    ('ZAP00049', 'Zapatilla Runner Pro', 'deportivo', 'Azul', 41, 6, 135.00),
    ('ZAP00050', 'Stiletto Gala Leather', 'tacos', 'Negro', 37, 14, 140.00),
    ('ZAP00051', 'Stiletto Gala Leather', 'tacos', 'Blanco', 38, 4, 140.00),
    ('ZAP00052', 'Sandalia Verano Confort', 'sandalia', 'Marrón', 38, 19, 45.00),
    ('ZAP00053', 'Sandalia Verano Confort', 'sandalia', 'Blanco', 39, 11, 45.00),
    ('ZAP00054', 'Sandalia Verano Confort', 'sandalia', 'Negro', 37, 10, 45.00)
GO


-- =========================================================================
-- 5. TIPOS DE MOVIMIENTOS
-- =========================================================================
INSERT INTO Inventario.TipoMovimiento (TipoMovimientoCodigo, TipoMovimientoDescripcion, TipoMovimientoFactor) VALUES
    ('E01', 'Abastecimiento de Materiales', 1),
    ('E02', 'Entrada por Producción Terminada', 1),
    ('S01', 'Salida por Consumo de Taller', -1),
    ('S02', 'Salida por Venta de Producto', -1),
    ('S03', 'Descarte de Materiales', -1)
GO


-- =========================================================================
-- 6. RECETAS DE PRODUCCIÓN (CalzadoMaterial)
-- =========================================================================

-- Bota Casual Ranger - Marrón Talla 39 (ZAP00025)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00025', 'MAT00008', 1.50, 'USR00001'),
    ('ZAP00025', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00025', 'MAT00017', 0.20, 'USR00001'),
    ('ZAP00025', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00025', 'MAT00024', 4.00, 'USR00001'),
    ('ZAP00025', 'MAT00027', 0.50, 'USR00001')
GO

-- Bota Casual Ranger - Negro Talla 40 (ZAP00026)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00026', 'MAT00008', 1.50, 'USR00001'),
    ('ZAP00026', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00026', 'MAT00017', 0.20, 'USR00001'),
    ('ZAP00026', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00026', 'MAT00024', 4.00, 'USR00001'),
    ('ZAP00026', 'MAT00027', 0.50, 'USR00001')
GO

-- Bota Casual Ranger - Negro Talla 41 (ZAP00027)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00027', 'MAT00007', 1.50, 'USR00001'),
    ('ZAP00027', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00027', 'MAT00016', 0.20, 'USR00001'),
    ('ZAP00027', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00027', 'MAT00023', 4.00, 'USR00001'),
    ('ZAP00027', 'MAT00027', 0.50, 'USR00001')
GO

-- Bota Casual Ranger - Marrón Talla 42 (ZAP00028)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00028', 'MAT00007', 1.50, 'USR00001'),
    ('ZAP00028', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00028', 'MAT00016', 0.20, 'USR00001'),
    ('ZAP00028', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00028', 'MAT00023', 4.00, 'USR00001'),
    ('ZAP00028', 'MAT00027', 0.50, 'USR00001')
GO

-- Bota Militar - Negro Talla 41 (ZAP00029)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00029', 'MAT00007', 1.80, 'USR00001'),
    ('ZAP00029', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00029', 'MAT00016', 0.25, 'USR00001'),
    ('ZAP00029', 'MAT00019', 0.12, 'USR00001'),
    ('ZAP00029', 'MAT00023', 6.00, 'USR00001'),
    ('ZAP00029', 'MAT00027', 0.60, 'USR00001')
GO

-- Bota Militar - Marrón Talla 42 (ZAP00030)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00030', 'MAT00008', 1.80, 'USR00001'),
    ('ZAP00030', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00030', 'MAT00017', 0.25, 'USR00001'),
    ('ZAP00030', 'MAT00019', 0.12, 'USR00001'),
    ('ZAP00030', 'MAT00024', 6.00, 'USR00001'),
    ('ZAP00030', 'MAT00027', 0.60, 'USR00001')
GO

-- Botín Chelsea - Negro Talla 39 (ZAP00031)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00031', 'MAT00007', 1.60, 'USR00001'),
    ('ZAP00031', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00031', 'MAT00016', 0.20, 'USR00001'),
    ('ZAP00031', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00031', 'MAT00024', 4.00, 'USR00001'),
    ('ZAP00031', 'MAT00027', 0.50, 'USR00001')
GO

-- Botín Chelsea - Marrón Talla 42 (ZAP00032)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00032', 'MAT00008', 1.60, 'USR00001'),
    ('ZAP00032', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00032', 'MAT00017', 0.20, 'USR00001'),
    ('ZAP00032', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00032', 'MAT00027', 0.50, 'USR00001'),
    ('ZAP00032', 'MAT00024', 4.00, 'USR00001')
GO

-- Mocasín Ejecutivo - Negro Talla 39 (ZAP00033)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00033', 'MAT00007', 1.20, 'USR00001'),
    ('ZAP00033', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00033', 'MAT00016', 0.15, 'USR00001'),
    ('ZAP00033', 'MAT00019', 0.08, 'USR00001'),
    ('ZAP00033', 'MAT00027', 0.40, 'USR00001')
GO

-- Mocasín Ejecutivo - Negro Talla 41 (ZAP00034)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00034', 'MAT00007', 1.20, 'USR00001'),
    ('ZAP00034', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00034', 'MAT00016', 0.15, 'USR00001'),
    ('ZAP00034', 'MAT00019', 0.08, 'USR00001'),
    ('ZAP00034', 'MAT00027', 0.40, 'USR00001')
GO

-- Mocasín Ejecutivo - Marrón Talla 40 (ZAP00035)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00035', 'MAT00008', 1.20, 'USR00001'),
    ('ZAP00035', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00035', 'MAT00017', 0.15, 'USR00001'),
    ('ZAP00035', 'MAT00019', 0.08, 'USR00001'),
    ('ZAP00035', 'MAT00027', 0.40, 'USR00001')
GO

-- Mocasín Ejecutivo - Marrón Talla 42 (ZAP00036)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00036', 'MAT00008', 1.20, 'USR00001'),
    ('ZAP00036', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00036', 'MAT00017', 0.15, 'USR00001'),
    ('ZAP00036', 'MAT00019', 0.08, 'USR00001'),
    ('ZAP00036', 'MAT00027', 0.40, 'USR00001')
GO

-- Zapato Derby - Negro Talla 40 (ZAP00037)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00037', 'MAT00007', 1.40, 'USR00001'),
    ('ZAP00037', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00037', 'MAT00016', 0.20, 'USR00001'),
    ('ZAP00037', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00037', 'MAT00027', 0.45, 'USR00001')
GO

-- Zapato Derby - Negro Talla 42 (ZAP00038)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00038', 'MAT00007', 1.40, 'USR00001'),
    ('ZAP00038', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00038', 'MAT00016', 0.20, 'USR00001'),
    ('ZAP00038', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00038', 'MAT00027', 0.45, 'USR00001')
GO

-- Zapato Derby - Marrón Talla 39 (ZAP00039)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00039', 'MAT00008', 1.40, 'USR00001'),
    ('ZAP00039', 'MAT00011', 1.00, 'USR00001'),
    ('ZAP00039', 'MAT00017', 0.20, 'USR00001'),
    ('ZAP00039', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00039', 'MAT00027', 0.45, 'USR00001')
GO

-- Zapato Derby - Marrón Talla 41 (ZAP00040)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00040', 'MAT00008', 1.40, 'USR00001'),
    ('ZAP00040', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00040', 'MAT00017', 0.20, 'USR00001'),
    ('ZAP00040', 'MAT00019', 0.10, 'USR00001'),
    ('ZAP00040', 'MAT00027', 0.45, 'USR00001')
GO

-- Zapatilla Urbana Canvas - Blanco Talla 40 (ZAP00041)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00041', 'MAT00009', 0.80, 'USR00001'),
    ('ZAP00041', 'MAT00014', 1.00, 'USR00001'),
    ('ZAP00041', 'MAT00018', 0.10, 'USR00001'),
    ('ZAP00041', 'MAT00020', 0.05, 'USR00001'),
    ('ZAP00041', 'MAT00028', 0.30, 'USR00001')
GO

-- Zapatilla Urbana Canvas - Blanco Talla 41 (ZAP00042)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00042', 'MAT00009', 0.80, 'USR00001'),
    ('ZAP00042', 'MAT00014', 1.00, 'USR00001'),
    ('ZAP00042', 'MAT00018', 0.10, 'USR00001'),
    ('ZAP00042', 'MAT00020', 0.05, 'USR00001'),
    ('ZAP00042', 'MAT00028', 0.30, 'USR00001')
GO

-- Zapatilla Urbana Canvas - Negro Talla 38 (ZAP00043)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00043', 'MAT00029', 0.80, 'USR00001'),
    ('ZAP00043', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00043', 'MAT00016', 0.10, 'USR00001'),
    ('ZAP00043', 'MAT00019', 0.05, 'USR00001'),
    ('ZAP00043', 'MAT00027', 0.30, 'USR00001')
GO

-- Zapatilla Urbana Canvas - Negro Talla 39 (ZAP00044)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00044', 'MAT00029', 0.80, 'USR00001'),
    ('ZAP00044', 'MAT00013', 1.00, 'USR00001'),
    ('ZAP00044', 'MAT00016', 0.10, 'USR00001'),
    ('ZAP00044', 'MAT00019', 0.05, 'USR00001'),
    ('ZAP00044', 'MAT00027', 0.30, 'USR00001')
GO

-- Mocasín Driver - Azul Talla 41 (ZAP00045)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00045', 'MAT00009', 1.00, 'USR00001'),
    ('ZAP00045', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00045', 'MAT00018', 0.15, 'USR00001'),
    ('ZAP00045', 'MAT00020', 0.08, 'USR00001'),
    ('ZAP00045', 'MAT00028', 0.35, 'USR00001')
GO

-- Mocasín Driver - Marrón Talla 40 (ZAP00046)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00046', 'MAT00008', 1.00, 'USR00001'),
    ('ZAP00046', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00046', 'MAT00017', 0.15, 'USR00001'),
    ('ZAP00046', 'MAT00019', 0.08, 'USR00001'),
    ('ZAP00046', 'MAT00027', 0.35, 'USR00001')
GO

-- Zapatilla Runner Pro - Gris Talla 40 (ZAP00047)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00047', 'MAT00010', 1.00, 'USR00001'),
    ('ZAP00047', 'MAT00015', 1.00, 'USR00001'),
    ('ZAP00047', 'MAT00016', 0.20, 'USR00001'),
    ('ZAP00047', 'MAT00020', 0.10, 'USR00001'),
    ('ZAP00047', 'MAT00028', 0.40, 'USR00001')
GO

-- Zapatilla Runner Pro - Gris Talla 42 (ZAP00048)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00048', 'MAT00009', 1.00, 'USR00001'),
    ('ZAP00048', 'MAT00015', 1.00, 'USR00001'),
    ('ZAP00048', 'MAT00018', 0.20, 'USR00001'),
    ('ZAP00048', 'MAT00020', 0.10, 'USR00001'),
    ('ZAP00048', 'MAT00028', 0.40, 'USR00001')
GO

-- Zapatilla Runner Pro - Azul Talla 41 (ZAP00049)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00049', 'MAT00009', 1.00, 'USR00001'),
    ('ZAP00049', 'MAT00015', 1.00, 'USR00001'),
    ('ZAP00049', 'MAT00018', 0.20, 'USR00001'),
    ('ZAP00049', 'MAT00020', 0.10, 'USR00001'),
    ('ZAP00049', 'MAT00028', 0.40, 'USR00001')
GO

-- Stiletto Gala - Negro Talla 37 (ZAP00050)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00050', 'MAT00007', 1.40, 'USR00001'),
    ('ZAP00050', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00050', 'MAT00016', 0.15, 'USR00001'),
    ('ZAP00050', 'MAT00019', 0.08, 'USR00001'),
    ('ZAP00050', 'MAT00027', 0.35, 'USR00001')
GO

-- Stiletto Gala - Blanco Talla 38 (ZAP00051)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00051', 'MAT00009', 1.40, 'USR00001'),
    ('ZAP00051', 'MAT00012', 1.00, 'USR00001'),
    ('ZAP00051', 'MAT00018', 0.15, 'USR00001'),
    ('ZAP00051', 'MAT00020', 0.08, 'USR00001'),
    ('ZAP00051', 'MAT00028', 0.35, 'USR00001')
GO

-- Sandalia Verano - Marrón Talla 38 (ZAP00052)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00052', 'MAT00008', 0.80, 'USR00001'),
    ('ZAP00052', 'MAT00014', 1.00, 'USR00001'),
    ('ZAP00052', 'MAT00017', 0.12, 'USR00001'),
    ('ZAP00052', 'MAT00019', 0.06, 'USR00001')
GO

-- Sandalia Verano - Blanco Talla 39 (ZAP00053)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00053', 'MAT00009', 0.80, 'USR00001'),
    ('ZAP00053', 'MAT00014', 1.00, 'USR00001'),
    ('ZAP00053', 'MAT00018', 0.12, 'USR00001'),
    ('ZAP00053', 'MAT00020', 0.06, 'USR00001')
GO

-- Sandalia Verano - Negro Talla 37 (ZAP00054)
INSERT INTO Inventario.CalzadoMaterial (CalzadoCodigo, MaterialCodigo, CantidadPorPar, UsuarioCreacion)
VALUES
    ('ZAP00054', 'MAT00029', 0.80, 'USR00001'),
    ('ZAP00054', 'MAT00014', 1.00, 'USR00001'),
    ('ZAP00054', 'MAT00016', 0.12, 'USR00001'),
    ('ZAP00054', 'MAT00019', 0.06, 'USR00001')
GO




-- ==========================================
-- PRODUCCIONES JUNIO 2026
-- ==========================================

-- 16/06/2026 - Bota Casual Ranger Marrón 39 (ZAP00025) - 10 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00025', 10, 'USR00001', '2026-06-16 08:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 10
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00025'
GO

-- 18/06/2026 - Bota Militar Negro 41 (ZAP00029) - 8 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00029', 8, 'USR00002', '2026-06-18 09:30:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 8
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00029'
GO

-- 20/06/2026 - Botín Chelsea Negro 39 (ZAP00031) - 6 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00031', 6, 'USR00001', '2026-06-20 10:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 6
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00031'
GO

-- 22/06/2026 - Mocasín Ejecutivo Negro 39 (ZAP00033) - 12 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00033', 12, 'USR00002', '2026-06-22 11:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 12
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00033'
GO

-- 24/06/2026 - Zapatilla Runner Pro Gris 40 (ZAP00047) - 10 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00047', 10, 'USR00001', '2026-06-24 14:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 10
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00047'
GO

-- 26/06/2026 - Zapatilla Urbana Canvas Blanco 40 (ZAP00041) - 15 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00041', 15, 'USR00002', '2026-06-26 15:30:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 15
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00041'
GO

-- 28/06/2026 - Zapato Derby Negro 40 (ZAP00037) - 8 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00037', 8, 'USR00001', '2026-06-28 16:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 8
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00037'
GO

-- 30/06/2026 - Bota Casual Ranger Negro 40 (ZAP00026) - 12 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00026', 12, 'USR00002', '2026-06-30 17:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 12
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00026'
GO

PRINT 'Producciones JUNIO 2026 completadas (8 órdenes)'
GO


-- ==========================================
-- PRODUCCIONES JULIO 2026
-- ==========================================

-- 02/07/2026 - Bota Militar Marrón 42 (ZAP00030) - 10 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00030', 10, 'USR00001', '2026-07-02 08:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 10
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00030'
GO

-- 04/07/2026 - Botín Chelsea Marrón 42 (ZAP00032) - 8 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00032', 8, 'USR00002', '2026-07-04 09:30:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 8
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00032'
GO

-- 06/07/2026 - Mocasín Ejecutivo Marrón 40 (ZAP00035) - 10 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00035', 10, 'USR00001', '2026-07-06 10:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 10
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00035'
GO

-- 08/07/2026 - Zapatilla Runner Pro Gris 42 (ZAP00048) - 12 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00048', 12, 'USR00002', '2026-07-08 14:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 12
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00048'
GO

-- 10/07/2026 - Zapatilla Urbana Canvas Negro 38 (ZAP00043) - 14 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00043', 14, 'USR00001', '2026-07-10 15:30:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 14
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00043'
GO

-- 12/07/2026 - Zapato Derby Marrón 39 (ZAP00039) - 6 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00039', 6, 'USR00002', '2026-07-12 16:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 6
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00039'
GO

-- 14/07/2026 - Bota Casual Ranger Negro 41 (ZAP00027) - 10 pares
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00027', 10, 'USR00001', '2026-07-14 17:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 10
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00027'
GO

-- 16/07/2026 - Bota Militar Negro 41 (ZAP00029) - 8 pares (AYER)
DECLARE @OrdenID INT
INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha, OrdenEstado)
VALUES ('ZAP00029', 8, 'USR00002', '2026-07-16 08:00:00', 'A')
SET @OrdenID = SCOPE_IDENTITY()
INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
SELECT @OrdenID, MaterialCodigo, CantidadPorPar * 8
FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = 'ZAP00029'
GO

PRINT ' Producciones JULIO 2026 completadas (8 órdenes)'
GO


-- ==========================================
-- ACTUALIZAR STOCK DE CALZADO
-- ==========================================

UPDATE C
SET C.CalzadoStock = C.CalzadoStock + (
    SELECT ISNULL(SUM(O.CantidadPares), 0)
    FROM Inventario.OrdenProduccion O
    WHERE O.CalzadoCodigo = C.CalzadoCodigo
        AND O.OrdenEstado = 'A'
)
FROM Inventario.Calzado C
WHERE C.CalzadoEstado = 'A'
GO

PRINT 'Stock de calzado actualizado con producciones'
GO

-- Ver resumen de producciones por mes
SELECT 
    YEAR(OrdenFecha) AS Año,
    MONTH(OrdenFecha) AS Mes,
    COUNT(*) AS Ordenes,
    SUM(CantidadPares) AS ParesProducidos
FROM Inventario.OrdenProduccion
WHERE OrdenEstado = 'A'
GROUP BY YEAR(OrdenFecha), MONTH(OrdenFecha)
ORDER BY Año DESC, Mes DESC
GO

-- Ver todas las producciones
SELECT 
    OrdenID,
    CalzadoCodigo,
    CantidadPares,
    OrdenFecha,
    UsuarioID
FROM Inventario.OrdenProduccion
WHERE OrdenEstado = 'A'
ORDER BY OrdenFecha DESC
GO

-- ==========================================
-- CREAR CARRITOS PARA CADA VENTA
-- ==========================================

-- Carrito para jsolanoam (USR00001)
INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 0, 'A', GETDATE(), GETDATE())
GO

-- Carrito para crodrial (USR00002)
INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 0, 'A', GETDATE(), GETDATE())
GO

-- Carritos adicionales para diferentes fechas (para que cada venta tenga su propio carrito)
-- Junio - jsolanoam
INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 179.98, 'C', '2026-06-17 10:00:00', '2026-06-17 10:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 150.00, 'C', '2026-06-21 16:00:00', '2026-06-21 16:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 270.00, 'C', '2026-06-25 15:00:00', '2026-06-25 15:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 95.00, 'C', '2026-06-29 17:30:00', '2026-06-29 17:30:00')
GO

-- Junio - crodrial
INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 125.00, 'C', '2026-06-19 14:30:00', '2026-06-19 14:30:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 220.00, 'C', '2026-06-23 11:00:00', '2026-06-23 11:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 196.50, 'C', '2026-06-27 12:00:00', '2026-06-27 12:00:00')
GO

-- Julio - jsolanoam
INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 125.00, 'C', '2026-07-03 14:00:00', '2026-07-03 14:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 230.00, 'C', '2026-07-07 11:30:00', '2026-07-07 11:30:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 131.00, 'C', '2026-07-11 12:00:00', '2026-07-11 12:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00001', 269.97, 'C', '2026-07-15 18:00:00', '2026-07-15 18:00:00')
GO

-- Julio - crodrial
INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 179.98, 'C', '2026-07-01 09:00:00', '2026-07-01 09:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 150.00, 'C', '2026-07-05 16:00:00', '2026-07-05 16:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 270.00, 'C', '2026-07-09 15:00:00', '2026-07-09 15:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 98.00, 'C', '2026-07-13 17:00:00', '2026-07-13 17:00:00')
GO

INSERT INTO Inventario.Carrito (UsuarioID, Total, Estado, FechaCreacion, FechaActualizacion)
VALUES ('USR00002', 260.00, 'C', '2026-07-16 16:00:00', '2026-07-16 16:00:00')
GO

PRINT 'Carritos creados'
GO

SELECT CarritoID, UsuarioID, Total, Estado, FechaCreacion
FROM Inventario.Carrito
ORDER BY CarritoID
GO

-- ==========================================
-- VENTAS JUNIO 2026 (CON CARRITOS EXISTENTES)
-- ==========================================

-- 17/06/2026 - Bota Casual Ranger Marrón 39 (ZAP00025) x2 - CarritoID 3
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 3, 179.98, '2026-06-17 10:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00025', 2, 89.99, 179.98)
GO

-- 19/06/2026 - Bota Militar Negro 41 (ZAP00029) x1 - CarritoID 6
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 6, 125.00, '2026-06-19 14:30:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00029', 1, 125.00, 125.00)
GO

-- 21/06/2026 - Botín Chelsea Negro 39 (ZAP00031) x1 - CarritoID 4
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 4, 150.00, '2026-06-21 16:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00031', 1, 150.00, 150.00)
GO

-- 23/06/2026 - Mocasín Ejecutivo Negro 39 (ZAP00033) x2 - CarritoID 7
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 7, 220.00, '2026-06-23 11:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00033', 2, 110.00, 220.00)
GO

-- 25/06/2026 - Zapatilla Runner Pro Gris 40 (ZAP00047) x2 - CarritoID 5
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 5, 270.00, '2026-06-25 15:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00047', 2, 135.00, 270.00)
GO

-- 27/06/2026 - Zapatilla Urbana Canvas Blanco 40 (ZAP00041) x3 - CarritoID 8
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 8, 196.50, '2026-06-27 12:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00041', 3, 65.50, 196.50)
GO

-- 29/06/2026 - Zapato Derby Negro 40 (ZAP00037) x1 - CarritoID 1
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 1, 95.00, '2026-06-29 17:30:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00037', 1, 95.00, 95.00)
GO

PRINT 'Ventas JUNIO 2026 completadas (7 ventas)'
GO

-- ==========================================
-- VENTAS JULIO 2026 (CON CARRITOS EXISTENTES)
-- ==========================================

-- 01/07/2026 - Bota Casual Ranger Negro 40 (ZAP00026) x2 - CarritoID 13
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 13, 179.98, '2026-07-01 09:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00026', 2, 89.99, 179.98)
GO

-- 03/07/2026 - Bota Militar Marrón 42 (ZAP00030) x1 - CarritoID 9
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 9, 125.00, '2026-07-03 14:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00030', 1, 125.00, 125.00)
GO

-- 05/07/2026 - Botín Chelsea Marrón 42 (ZAP00032) x1 - CarritoID 14
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 14, 150.00, '2026-07-05 16:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00032', 1, 150.00, 150.00)
GO

-- 07/07/2026 - Mocasín Ejecutivo Marrón 40 (ZAP00035) x2 - CarritoID 10
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 10, 230.00, '2026-07-07 11:30:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00035', 2, 115.00, 230.00)
GO

-- 09/07/2026 - Zapatilla Runner Pro Gris 42 (ZAP00048) x2 - CarritoID 15
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 15, 270.00, '2026-07-09 15:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00048', 2, 135.00, 270.00)
GO

-- 11/07/2026 - Zapatilla Urbana Canvas Negro 38 (ZAP00043) x2 - CarritoID 11
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 11, 131.00, '2026-07-11 12:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00043', 2, 65.50, 131.00)
GO

-- 13/07/2026 - Zapato Derby Marrón 39 (ZAP00039) x1 - CarritoID 16
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 16, 98.00, '2026-07-13 17:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00039', 1, 98.00, 98.00)
GO

-- 15/07/2026 - Bota Casual Ranger Negro 41 (ZAP00027) x3 - CarritoID 12
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00001', 12, 269.97, '2026-07-15 18:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES (@VentaID, 'ZAP00027', 3, 89.99, 269.97)
GO

-- 16/07/2026 - Bota Militar Negro 41 + Zapatilla Runner Pro Gris 40 - CarritoID 17
DECLARE @VentaID INT
INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
VALUES ('USR00002', 17, 260.00, '2026-07-16 16:00:00', 'A')
SET @VentaID = SCOPE_IDENTITY()
INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
VALUES 
    (@VentaID, 'ZAP00029', 1, 125.00, 125.00),
    (@VentaID, 'ZAP00047', 1, 135.00, 135.00)
GO

PRINT 'Ventas JULIO 2026 completadas (9 ventas)'
GO

SELECT 
    VentaID,
    FechaVenta,
    Total,
    UsuarioID,
    CarritoID
FROM Inventario.Venta
WHERE Estado = 'A'
ORDER BY FechaVenta DESC
GO