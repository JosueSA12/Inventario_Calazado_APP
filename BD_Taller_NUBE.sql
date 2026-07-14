USE [db_acbcc3_dbtaller] 
GO

-- =========================================================================
-- 1. CREACIÓN DE SCHEMAS
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Seguridad')
BEGIN
    EXEC('CREATE SCHEMA Seguridad') 
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Inventario')
BEGIN
    EXEC('CREATE SCHEMA Inventario') 
END
GO

-- =========================================================================
-- 2. CREACIÓN DE TABLAS
-- =========================================================================

-- 2.1 Seguridad.TipoUsuario
CREATE TABLE Seguridad.TipoUsuario (
    TipoUsuarioCodigo NCHAR(5) PRIMARY KEY,
    TipoUsuarioDescription NVARCHAR(50) NOT NULL UNIQUE,
    TipoUsuarioEstado NCHAR(1) DEFAULT 'A' CHECK (TipoUsuarioEstado IN ('A', 'E'))
)
GO

-- 2.2 Seguridad.Usuario
CREATE TABLE Seguridad.Usuario (
    UsuarioID NCHAR(8) PRIMARY KEY,
    UsuarioNombre NVARCHAR(100) NOT NULL,
    UsuarioLogin NVARCHAR(20) NOT NULL UNIQUE,
    UsuarioPassword NVARCHAR(50) NOT NULL,
    UsuarioCorreo NVARCHAR(100) NULL UNIQUE,
    TipoUsuarioCodigo NCHAR(5) NOT NULL,
    UsuarioFechaCreacion DATE DEFAULT GETDATE() CHECK (UsuarioFechaCreacion <= GETDATE()),
    UsuarioEstado NCHAR(1) DEFAULT 'A' CHECK (UsuarioEstado IN ('A', 'E')),
    CONSTRAINT UsuarioTipoUsuarioFK FOREIGN KEY (TipoUsuarioCodigo) REFERENCES Seguridad.TipoUsuario(TipoUsuarioCodigo)
)
GO

-- 2.3 Inventario.Material
CREATE TABLE Inventario.Material (
    MaterialCodigo NCHAR(8) PRIMARY KEY,
    MaterialNombre NVARCHAR(100) NOT NULL,
    MaterialCategoria NVARCHAR(50) NOT NULL,
    MaterialCantidad DECIMAL(10,2) DEFAULT 0.00 CHECK (MaterialCantidad >= 0),
    MaterialMedida NVARCHAR(20) NOT NULL,
    MaterialProveedor NVARCHAR(100) NULL,
    MaterialEstado NCHAR(1) DEFAULT 'A' CHECK (MaterialEstado IN ('A', 'E')),
    CONSTRAINT MaterialCategoriaCK CHECK (MaterialCategoria IN ('Cuero', 'Suelas', 'Hilos', 'Pegamentos / Tintes', 'Herrajes / Ojales'))
)
GO

-- 2.4 Inventario.Calzado
CREATE TABLE Inventario.Calzado (
    CalzadoCodigo NCHAR(8) PRIMARY KEY,
    CalzadoModelo NVARCHAR(100) NOT NULL,
    CalzadoTipo NVARCHAR(30) NOT NULL,
    CalzadoColor NVARCHAR(50) NOT NULL,
    CalzadoTalla INT NOT NULL CHECK (CalzadoTalla BETWEEN 25 AND 45),
    CalzadoStock INT DEFAULT 0 CHECK (CalzadoStock >= 0),
    CalzadoPrecioVenta DECIMAL(10,2) NOT NULL CHECK (CalzadoPrecioVenta > 0),
    CalzadoEstado NCHAR(1) DEFAULT 'A' CHECK (CalzadoEstado IN ('A', 'E'))
)
GO

-- 2.5 Inventario.TipoMovimiento
CREATE TABLE Inventario.TipoMovimiento (
    TipoMovimientoCodigo NCHAR(3) PRIMARY KEY,
    TipoMovimientoDescripcion NVARCHAR(50) NOT NULL UNIQUE,
    TipoMovimientoFactor INT NOT NULL CHECK (TipoMovimientoFactor IN (1, -1)),
    TipoMovimientoEstado NCHAR(1) DEFAULT 'A' CHECK (TipoMovimientoEstado IN ('A', 'E'))
)
GO

-- 2.6 Inventario.HistorialMaterial
CREATE TABLE Inventario.HistorialMaterial (
    HistorialMaterialId BIGINT IDENTITY(1,1) PRIMARY KEY,
    MaterialCodigo NCHAR(8) NOT NULL,
    TipoMovimientoCodigo NCHAR(3) NOT NULL,
    HistorialMaterialCantidad DECIMAL(10,2) NOT NULL CHECK (HistorialMaterialCantidad > 0),
    HistorialMaterialFecha DATETIME DEFAULT GETDATE() CHECK (HistorialMaterialFecha <= GETDATE()),
    UsuarioID NCHAR(8) NOT NULL,
    HistorialMaterialNota NVARCHAR(255) NULL,
    CONSTRAINT HistorialMaterial_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo),
    CONSTRAINT HistorialMaterial_TipoMovimientoFK FOREIGN KEY (TipoMovimientoCodigo) REFERENCES Inventario.TipoMovimiento(TipoMovimientoCodigo),
    CONSTRAINT HistorialMaterial_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID)
)
GO

-- 2.7 Inventario.HistorialCalzado
CREATE TABLE Inventario.HistorialCalzado (
    HistorialCalzadoId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CalzadoCodigo NCHAR(8) NOT NULL,
    TipoMovimientoCodigo NCHAR(3) NOT NULL,
    HistorialCalzadoCantidad INT NOT NULL CHECK (HistorialCalzadoCantidad > 0),
    HistorialCalzadoFecha DATETIME DEFAULT GETDATE() CHECK (HistorialCalzadoFecha <= GETDATE()),
    UsuarioID NCHAR(8) NOT NULL,
    CONSTRAINT HistorialCalzado_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo),
    CONSTRAINT HistorialCalzado_TipoMovimientoFK FOREIGN KEY (TipoMovimientoCodigo) REFERENCES Inventario.TipoMovimiento(TipoMovimientoCodigo),
    CONSTRAINT HistorialCalzado_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID)
)
GO

-- 2.8 Inventario.OrdenProduccion
CREATE TABLE Inventario.OrdenProduccion (
    OrdenID INT IDENTITY(1,1) PRIMARY KEY,
    CalzadoCodigo NCHAR(8) NOT NULL,
    CantidadPares INT NOT NULL CHECK (CantidadPares > 0),
    OrdenFecha DATETIME DEFAULT GETDATE(),
    UsuarioID NCHAR(8) NOT NULL,
    OrdenEstado NCHAR(1) DEFAULT 'A',
    CONSTRAINT OrdenProduccion_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo),
    CONSTRAINT OrdenProduccion_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID)
)
GO

-- 2.9 Inventario.OrdenProduccionDetalle
CREATE TABLE Inventario.OrdenProduccionDetalle (
    DetalleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrdenID INT NOT NULL,
    MaterialCodigo NCHAR(8) NOT NULL,
    CantidadConsumida DECIMAL(10,2) NOT NULL CHECK (CantidadConsumida > 0),
    CONSTRAINT Detalle_OrdenFK FOREIGN KEY (OrdenID) REFERENCES Inventario.OrdenProduccion(OrdenID),
    CONSTRAINT Detalle_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo)
)
GO

-- 2.10 Inventario.Carrito
CREATE TABLE Inventario.Carrito (
    CarritoID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID NCHAR(8) NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME DEFAULT GETDATE(),
    Estado NCHAR(1) DEFAULT 'A' CHECK (Estado IN ('A', 'C', 'E')),
    Total DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT Carrito_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID)
)
GO

-- 2.11 Inventario.CarritoDetalle
CREATE TABLE Inventario.CarritoDetalle (
    DetalleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CarritoID INT NOT NULL,
    CalzadoCodigo NCHAR(8) NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario > 0),
    Subtotal DECIMAL(10,2) NOT NULL,
    FechaAgregado DATETIME DEFAULT GETDATE(),
    CONSTRAINT Detalle_CarritoFK FOREIGN KEY (CarritoID) REFERENCES Inventario.Carrito(CarritoID),
    CONSTRAINT Detalle_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo)
)
GO

-- 2.12 Inventario.Venta
CREATE TABLE Inventario.Venta (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    UsuarioID NCHAR(8) NOT NULL,
    CarritoID INT NOT NULL,
    FechaVenta DATETIME DEFAULT GETDATE(),
    Total DECIMAL(10,2) NOT NULL,
    Estado NCHAR(1) DEFAULT 'A' CHECK (Estado IN ('A', 'C')),
    CONSTRAINT Venta_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID),
    CONSTRAINT Venta_CarritoFK FOREIGN KEY (CarritoID) REFERENCES Inventario.Carrito(CarritoID)
)
GO

-- 2.13 Inventario.VentaDetalle
CREATE TABLE Inventario.VentaDetalle (
    VentaDetalleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    VentaID INT NOT NULL,
    CalzadoCodigo NCHAR(8) NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT VentaDetalle_VentaFK FOREIGN KEY (VentaID) REFERENCES Inventario.Venta(VentaID),
    CONSTRAINT VentaDetalle_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo)
)
GO

-- =========================================================================
-- 3. INSERCIÓN DE DATOS INICIALES
-- =========================================================================

-- 3.1 Tipos de Usuario
INSERT INTO Seguridad.TipoUsuario (TipoUsuarioCodigo, TipoUsuarioDescription) VALUES
    ('ADM01', 'Administrador General'),
    ('EMP01', 'Operario / Artesano de Taller')
GO

-- 3.2 Usuarios base
INSERT INTO Seguridad.Usuario (UsuarioID, UsuarioNombre, UsuarioLogin, UsuarioPassword, UsuarioCorreo, TipoUsuarioCodigo) VALUES
    ('USR00001', 'Jorge Luis', 'admin', '123', 'admin@taller.com', 'ADM01'),
    ('USR00002', 'Carlos Rodriguez', 'empleado', '456', 'empleado@taller.com', 'EMP01')
GO

-- 3.3 Catálogo de Materiales
INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor) VALUES
    ('MAT00001', 'Cuero Badana Marrón Premium', 'Cuero', 18.50, 'Metros', 'Curtiembre San José'),
    ('MAT00002', 'Suelas de Caucho Negro N° 42', 'Suelas', 3.00, 'Pares', 'Suelas del Norte'),
    ('MAT00003', 'Hilo Nylon Italiano N° 40', 'Hilos', 12.00, 'Bobinas', 'Hilos Tex S.A.'),
    ('MAT00004', 'Pegamento de Contacto Extra XL', 'Pegamentos / Tintes', 1.20, 'Litros', 'Químicos Distribuidora'),
    ('MAT00005', 'Ojales de Bronce Pavonado 8mm', 'Herrajes / Ojales', 500.00, 'Unidades', 'Herrajes Perú SRL'),
    ('MAT00006', 'Cuero de Cocodrilo', 'Cuero', 20.00, 'Metros', 'Josue Fernando Solano SAC')
GO

-- 3.4 Catálogo de Calzado
INSERT INTO Inventario.Calzado (CalzadoCodigo, CalzadoModelo, CalzadoTipo, CalzadoColor, CalzadoTalla, CalzadoStock, CalzadoPrecioVenta) VALUES	
    ('ZAP00001', 'Bota Casual Ranger', 'bota', 'Marrón', 40, 15, 89.99),
    ('ZAP00002', 'Bota Casual Ranger', 'bota', 'Marrón', 41, 24, 89.99),
    ('ZAP00003', 'Bota Casual Ranger', 'bota', 'Negro', 39, 8, 89.99),
    ('ZAP00004', 'Bota Casual Ranger', 'bota', 'Negro', 42, 12, 89.99),
    ('ZAP00005', 'Mocasín Ejecutivo Premium', 'formal', 'Negro', 42, 8, 110.00),
    ('ZAP00006', 'Mocasín Ejecutivo Premium', 'formal', 'Negro', 40, 5, 110.00),
    ('ZAP00007', 'Mocasín Ejecutivo Premium', 'formal', 'Marrón', 41, 6, 115.00),
    ('ZAP00008', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 38, 4, 65.50),
    ('ZAP00009', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 39, 10, 65.50),
    ('ZAP00010', 'Zapatilla Urbana Canvas', 'urbano', 'Negro', 40, 15, 65.50),
    ('ZAP00011', 'Bota Militar', 'bota', 'Negro', 40, 15, 125.00),
    ('ZAP00012', 'Bota Militar', 'bota', 'Marrón', 41, 3, 125.00),
    ('ZAP00013', 'Stiletto Gala Leather', 'tacos', 'Negro', 36, 12, 140.00),
    ('ZAP00014', 'Stiletto Gala Leather', 'tacos', 'Blanco', 37, 2, 140.00),
    ('ZAP00015', 'Sandalia Verano Confort', 'sandalia', 'Marrón', 37, 20, 45.00),
    ('ZAP00016', 'Sandalia Verano Confort', 'sandalia', 'Blanco', 38, 14, 45.00),
    ('ZAP00017', 'Zapato Derby Clásico', 'formal', 'Negro', 41, 10, 95.00),
    ('ZAP00018', 'Zapato Derby Clásico', 'formal', 'Marrón', 42, 3, 98.00),
    ('ZAP00019', 'Zapatilla Runner Pro', 'deportivo', 'Gris', 41, 18, 135.00),
    ('ZAP00020', 'Zapatilla Runner Pro', 'deportivo', 'Azul', 42, 7, 135.00),
    ('ZAP00021', 'Botín Chelsea Nobuck', 'bota', 'Marrón', 40, 9, 150.00),
    ('ZAP00022', 'Botín Chelsea Nobuck', 'bota', 'Negro', 41, 11, 150.00),
    ('ZAP00023', 'Mocasín Driver Casual', 'urbano', 'Azul', 40, 14, 79.90),
    ('ZAP00024', 'Mocasín Driver Casual', 'urbano', 'Marrón', 39, 6, 79.90)
GO

-- 3.5 Tipos de Movimientos
INSERT INTO Inventario.TipoMovimiento (TipoMovimientoCodigo, TipoMovimientoDescripcion, TipoMovimientoFactor) VALUES
    ('E01', 'Abastecimiento de Materiales', 1),
    ('E02', 'Entrada por Producción Terminada', 1),
    ('S01', 'Salida por Consumo de Taller', -1),
    ('S02', 'Salida por Venta de Producto', -1),
    ('S03', 'Descarte de Materiales', -1)
GO

-- 3.6 Historial Material
INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialNota) VALUES
    ('MAT00001', 'S01', 5.50, 'USR00002', 'Consumo de cuero para lote de botas Ranger'),
    ('MAT00004', 'E01', 10.00, 'USR00001', 'Abastecimiento mensual de pegamento de contacto')
GO

-- 3.7 Historial Calzado
INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID) VALUES
    ('ZAP00001', 'E02', 10, 'USR00002'),
    ('ZAP00004', 'S02', 2, 'USR00001')
GO

-- =========================================================================
-- 4. PROCEDIMIENTOS ALMACENADOS
-- =========================================================================

-- 4.1 Dashboard - Obtener Resumen
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ObtenerResumen
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @TotalModelos INT
    DECLARE @TotalMateriales INT
    DECLARE @AlertasCriticas INT

    SELECT @TotalModelos = COUNT(DISTINCT CalzadoModelo) FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    SELECT @TotalMateriales = COUNT(*) FROM Inventario.Material WHERE MaterialEstado = 'A'
    SELECT @AlertasCriticas = COUNT(*) FROM Inventario.Material WHERE MaterialCantidad < 5.00 AND MaterialEstado = 'A'

    SELECT
        ISNULL(@TotalModelos, 0) AS TotalModelos,
        ISNULL(@TotalMateriales, 0) AS TotalMateriales,
        ISNULL(@AlertasCriticas, 0) AS AlertasCriticas
END
GO

-- 4.2 Dashboard - Listar Actividad Reciente
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ListarActividadReciente
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE)
    
    SELECT
        Actividad.Fecha,
        Actividad.Tipo,
        Actividad.Descripcion,
        Actividad.Cantidad,
        Actividad.Movimiento,
        U.UsuarioNombre AS Encargado
    FROM
    (
        SELECT
            HM.HistorialMaterialFecha AS Fecha,
            'Material' AS Tipo,
            M.MaterialNombre AS Descripcion,
            CONVERT(NVARCHAR(20), HM.HistorialMaterialCantidad) + ' ' + M.MaterialMedida AS Cantidad,
            TM.TipoMovimientoDescripcion AS Movimiento,
            HM.UsuarioID
        FROM Inventario.HistorialMaterial HM
        INNER JOIN Inventario.Material M ON HM.MaterialCodigo = M.MaterialCodigo
        INNER JOIN Inventario.TipoMovimiento TM ON HM.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
        WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual

        UNION ALL

        SELECT
            HC.HistorialCalzadoFecha AS Fecha,
            'Calzado' AS Tipo,
            C.CalzadoModelo + ' (' + RTRIM(C.CalzadoColor) + ', Talla ' + CONVERT(NVARCHAR(3), C.CalzadoTalla) + ')' AS Descripcion,
            CASE
                WHEN HC.TipoMovimientoCodigo = 'S02'
                THEN CONVERT(NVARCHAR(10), HC.HistorialCalzadoCantidad) + ' Pares (Subtotal: S/.' + CONVERT(NVARCHAR(20), CAST(HC.HistorialCalzadoCantidad * C.CalzadoPrecioVenta AS DECIMAL(10,2))) + ')'
                ELSE CONVERT(NVARCHAR(20), HC.HistorialCalzadoCantidad) + ' Pares'
            END AS Cantidad,
            TM.TipoMovimientoDescripcion AS Movimiento,
            HC.UsuarioID
        FROM Inventario.HistorialCalzado HC
        INNER JOIN Inventario.Calzado C ON HC.CalzadoCodigo = C.CalzadoCodigo
        INNER JOIN Inventario.TipoMovimiento TM ON HC.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
        WHERE CAST(HC.HistorialCalzadoFecha AS DATE) = @FechaActual
    ) AS Actividad
    INNER JOIN Seguridad.Usuario U ON Actividad.UsuarioID = U.UsuarioID
    ORDER BY Actividad.Fecha DESC
END
GO

-- 4.3 Dashboard - Filtrar Movimientos
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_FiltrarMovimientos
    @TipoFiltro NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @TipoMovimientoCodigo NCHAR(3)
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE)
    
    IF @TipoFiltro = 'VENTA'
        SET @TipoMovimientoCodigo = 'S02'
    ELSE IF @TipoFiltro = 'PRODUCCION'
        SET @TipoMovimientoCodigo = 'E02'
    ELSE IF @TipoFiltro = 'ABASTECIMIENTO'
        SET @TipoMovimientoCodigo = 'E01'
    ELSE IF @TipoFiltro = 'CONSUMO'
        SET @TipoMovimientoCodigo = 'S01'
    ELSE IF @TipoFiltro = 'DESCARTE'
        SET @TipoMovimientoCodigo = 'S03'

    SELECT
        Actividad.Fecha,
        Actividad.Tipo,
        Actividad.Descripcion,
        Actividad.Cantidad,
        Actividad.Movimiento,
        U.UsuarioNombre AS Encargado
    FROM
    (
        SELECT
            HM.HistorialMaterialFecha AS Fecha,
            'Material' AS Tipo,
            M.MaterialNombre AS Descripcion,
            CONVERT(NVARCHAR(20), HM.HistorialMaterialCantidad) + ' ' + M.MaterialMedida AS Cantidad,
            TM.TipoMovimientoDescripcion AS Movimiento,
            HM.UsuarioID,
            TM.TipoMovimientoCodigo
        FROM Inventario.HistorialMaterial HM
        INNER JOIN Inventario.Material M ON HM.MaterialCodigo = M.MaterialCodigo
        INNER JOIN Inventario.TipoMovimiento TM ON HM.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
        WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual
          AND (@TipoMovimientoCodigo IS NULL OR TM.TipoMovimientoCodigo = @TipoMovimientoCodigo)

        UNION ALL

        SELECT
            HC.HistorialCalzadoFecha AS Fecha,
            'Calzado' AS Tipo,
            C.CalzadoModelo + ' (' + RTRIM(C.CalzadoColor) + ', Talla ' + CONVERT(NVARCHAR(3), C.CalzadoTalla) + ')' AS Descripcion,
            CASE
                WHEN HC.TipoMovimientoCodigo = 'S02'
                THEN CONVERT(NVARCHAR(10), HC.HistorialCalzadoCantidad) + ' Pares (Subtotal: S/.' + CONVERT(NVARCHAR(20), CAST(HC.HistorialCalzadoCantidad * C.CalzadoPrecioVenta AS DECIMAL(10,2))) + ')'
                ELSE CONVERT(NVARCHAR(20), HC.HistorialCalzadoCantidad) + ' Pares'
            END AS Cantidad,
            TM.TipoMovimientoDescripcion AS Movimiento,
            HC.UsuarioID,
            TM.TipoMovimientoCodigo
        FROM Inventario.HistorialCalzado HC
        INNER JOIN Inventario.Calzado C ON HC.CalzadoCodigo = C.CalzadoCodigo
        INNER JOIN Inventario.TipoMovimiento TM ON HC.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
        WHERE CAST(HC.HistorialCalzadoFecha AS DATE) = @FechaActual
          AND (@TipoMovimientoCodigo IS NULL OR TM.TipoMovimientoCodigo = @TipoMovimientoCodigo)
    ) AS Actividad
    INNER JOIN Seguridad.Usuario U ON Actividad.UsuarioID = U.UsuarioID
    ORDER BY Actividad.Fecha DESC
END
GO

-- 4.4 Dashboard - Obtener KPIs por Filtro
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ObtenerKPIsPorFiltro
    @TipoFiltro NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @TipoMovimientoCodigo NCHAR(3)
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE)
    
    IF @TipoFiltro = 'VENTA'
        SET @TipoMovimientoCodigo = 'S02'
    ELSE IF @TipoFiltro = 'PRODUCCION'
        SET @TipoMovimientoCodigo = 'E02'
    ELSE IF @TipoFiltro = 'ABASTECIMIENTO'
        SET @TipoMovimientoCodigo = 'E01'
    ELSE IF @TipoFiltro = 'CONSUMO'
        SET @TipoMovimientoCodigo = 'S01'
    ELSE IF @TipoFiltro = 'DESCARTE'
        SET @TipoMovimientoCodigo = 'S03'

    SELECT
        (SELECT COUNT(*) FROM Inventario.Material WHERE MaterialEstado = 'A') AS TotalMateriales,
        (SELECT COUNT(*) FROM Inventario.Calzado WHERE CalzadoEstado = 'A') AS TotalModelos,
        (SELECT COUNT(*) FROM Inventario.Material WHERE MaterialCantidad < 5.00 AND MaterialEstado = 'A') AS AlertasCriticas,
        
        ISNULL((
            SELECT SUM(HistorialMaterialCantidad)
            FROM Inventario.HistorialMaterial HM
            INNER JOIN Inventario.TipoMovimiento TM ON HM.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
            WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual
              AND (@TipoMovimientoCodigo IS NULL OR TM.TipoMovimientoCodigo = @TipoMovimientoCodigo)
        ), 0) AS TotalMovimientosMateriales,
        
        ISNULL((
            SELECT SUM(HistorialCalzadoCantidad)
            FROM Inventario.HistorialCalzado HC
            INNER JOIN Inventario.TipoMovimiento TM ON HC.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
            WHERE CAST(HC.HistorialCalzadoFecha AS DATE) = @FechaActual
              AND (@TipoMovimientoCodigo IS NULL OR TM.TipoMovimientoCodigo = @TipoMovimientoCodigo)
        ), 0) AS TotalMovimientosCalzado,
        
        ISNULL((
            SELECT SUM(HC.HistorialCalzadoCantidad * C.CalzadoPrecioVenta)
            FROM Inventario.HistorialCalzado HC
            INNER JOIN Inventario.Calzado C ON HC.CalzadoCodigo = C.CalzadoCodigo
            INNER JOIN Inventario.TipoMovimiento TM ON HC.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
            WHERE CAST(HC.HistorialCalzadoFecha AS DATE) = @FechaActual
              AND TM.TipoMovimientoCodigo = 'S02'
        ), 0) AS IngresosTotales,
        
        (
            SELECT TOP 1
                C.CalzadoModelo + '|' +
                RTRIM(C.CalzadoColor) + '|' +
                CONVERT(NVARCHAR(3), C.CalzadoTalla) + '|' +
                CONVERT(NVARCHAR(10), SUM(HC.HistorialCalzadoCantidad))
            FROM Inventario.HistorialCalzado HC
            INNER JOIN Inventario.Calzado C ON HC.CalzadoCodigo = C.CalzadoCodigo
            WHERE CAST(HC.HistorialCalzadoFecha AS DATE) = @FechaActual
              AND HC.TipoMovimientoCodigo = 'S02'
            GROUP BY C.CalzadoModelo, C.CalzadoColor, C.CalzadoTalla
            ORDER BY SUM(HC.HistorialCalzadoCantidad) DESC
        ) AS ProductoMasVendido,
        
        (
            SELECT TOP 1
                M.MaterialCategoria + '|' +
                M.MaterialNombre + '|' +
                CONVERT(NVARCHAR(10), SUM(HM.HistorialMaterialCantidad)) + ' ' + M.MaterialMedida
            FROM Inventario.HistorialMaterial HM
            INNER JOIN Inventario.Material M ON HM.MaterialCodigo = M.MaterialCodigo
            WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual
              AND HM.TipoMovimientoCodigo = 'S01'
            GROUP BY M.MaterialCategoria, M.MaterialNombre, M.MaterialMedida
            ORDER BY SUM(HM.HistorialMaterialCantidad) DESC
        ) AS MaterialMasConsumido,
        
        ISNULL((
            SELECT SUM(HistorialMaterialCantidad)
            FROM Inventario.HistorialMaterial HM
            INNER JOIN Inventario.TipoMovimiento TM ON HM.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
            WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual
              AND TM.TipoMovimientoCodigo = 'E01'
        ), 0) AS TotalAbastecimiento,
        
        ISNULL((
            SELECT SUM(HistorialMaterialCantidad)
            FROM Inventario.HistorialMaterial HM
            INNER JOIN Inventario.TipoMovimiento TM ON HM.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
            WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual
              AND TM.TipoMovimientoCodigo = 'S03'
        ), 0) AS TotalDescarte,
        
        ISNULL((
            SELECT COUNT(*)
            FROM (
                SELECT HistorialMaterialId AS Id FROM Inventario.HistorialMaterial WHERE CAST(HistorialMaterialFecha AS DATE) = @FechaActual
                UNION ALL
                SELECT HistorialCalzadoId FROM Inventario.HistorialCalzado WHERE CAST(HistorialCalzadoFecha AS DATE) = @FechaActual
            ) AS Movimientos
        ), 0) AS TotalMovimientos
END
GO

-- 4.5 Inventario - Listar Materiales
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_ListarMateriales
AS
BEGIN
    SET NOCOUNT ON
    SELECT
        MaterialCodigo AS codigo,
        MaterialNombre AS insumo,
        MaterialCategoria AS categoria,
        MaterialCantidad AS cantidad,
        MaterialMedida AS medida,
        MaterialProveedor AS proveedor
    FROM Inventario.Material
    WHERE MaterialEstado = 'A'
    ORDER BY MaterialNombre DESC
END
GO

-- 4.6 Inventario - Listar Alertas Bajo Stock
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_ListarAlertasBajoStock
AS
BEGIN
    SET NOCOUNT ON
    SELECT
        MaterialCodigo AS codigo,
        MaterialNombre AS insumo,
        MaterialCategoria AS categoria,
        MaterialCantidad AS cantidad,
        MaterialMedida AS medida,
        MaterialProveedor AS proveedor
    FROM Inventario.Material
    WHERE MaterialEstado = 'A' AND MaterialCantidad < 5.0
    ORDER BY MaterialCantidad ASC
END
GO

-- 4.7 Inventario - Insertar Material
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_InsertarMaterial
    @MaterialNombre NVARCHAR(100),
    @MaterialCategoria NVARCHAR(50),
    @MaterialCantidad DECIMAL(10,2),
    @MaterialMedida NVARCHAR(20),
    @MaterialProveedor NVARCHAR(100),
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @CodigoExistente NCHAR(8)
        DECLARE @CodigoFinal NCHAR(8)
        DECLARE @AccionRealizada NVARCHAR(20)

        SELECT @CodigoExistente = MaterialCodigo FROM Inventario.Material
        WHERE UPPER(RTRIM(MaterialNombre)) = UPPER(RTRIM(@MaterialNombre)) AND MaterialCategoria = @MaterialCategoria AND MaterialEstado = 'A'

        IF @CodigoExistente IS NOT NULL
        BEGIN
            UPDATE Inventario.Material SET MaterialCantidad = MaterialCantidad + @MaterialCantidad,
                MaterialProveedor = ISNULL(@MaterialProveedor, MaterialProveedor), MaterialMedida = @MaterialMedida
            WHERE MaterialCodigo = @CodigoExistente
            SET @CodigoFinal = @CodigoExistente
            SET @AccionRealizada = 'ACCION_SUMAR'
        END
        ELSE
        BEGIN
            DECLARE @MaxId INT
            SELECT @MaxId = ISNULL(MAX(CAST(SUBSTRING(MaterialCodigo, 4, 5) AS INT)), 0) FROM Inventario.Material
            SET @CodigoFinal = 'MAT' + RIGHT('00000' + CAST((@MaxId + 1) AS VARCHAR(5)), 5)

            INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor, MaterialEstado)
            VALUES (@CodigoFinal, @MaterialNombre, @MaterialCategoria, @MaterialCantidad, @MaterialMedida, @MaterialProveedor, 'A')
            SET @AccionRealizada = 'ACCION_CREAR'
        END

        INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialFecha, HistorialMaterialNota)
        VALUES (@CodigoFinal, 'E01', @MaterialCantidad, @UsuarioID, GETDATE(), CASE WHEN @AccionRealizada = 'ACCION_CREAR' THEN N'Ingreso inicial de nuevo material.' ELSE N'Abastecimiento de stock.' END)

        COMMIT TRANSACTION
        SELECT @CodigoFinal AS CodigoResultado, @AccionRealizada AS Accion
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.8 Inventario - Listar Materiales para Dropdown
CREATE OR ALTER PROCEDURE Inventario.USP_Material_ListarParaDropdown
AS
BEGIN
    SET NOCOUNT ON
    SELECT
        RTRIM(MaterialCodigo) AS codigo,
        RTRIM(MaterialNombre) AS nombre,
        RTRIM(MaterialCategoria) AS categoria,
        RTRIM(MaterialMedida) AS medida,
        RTRIM(ISNULL(MaterialProveedor, '')) AS proveedor,
        MaterialCantidad AS stockActual
    FROM Inventario.Material
    WHERE MaterialEstado = 'A'
    ORDER BY MaterialNombre ASC
END
GO

-- 4.9 Inventario - Editar Material
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_EditarMaterial
    @MaterialCodigo NCHAR(8),
    @MaterialNombre NVARCHAR(100),
    @MaterialCategoria NVARCHAR(50),
    @MaterialCantidad DECIMAL(10,2),
    @MaterialMedida NVARCHAR(20),
    @MaterialProveedor NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Inventario.Material WHERE MaterialCodigo = @MaterialCodigo AND MaterialEstado = 'A')
            RAISERROR('El material no existe.', 16, 1)

        UPDATE Inventario.Material SET MaterialNombre = @MaterialNombre, MaterialCategoria = @MaterialCategoria,
            MaterialCantidad = @MaterialCantidad, MaterialMedida = @MaterialMedida, MaterialProveedor = ISNULL(@MaterialProveedor, MaterialProveedor)
        WHERE MaterialCodigo = @MaterialCodigo

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, 'Material actualizado correctamente.' AS Mensaje
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.10 Inventario - Eliminar Material
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_EliminarMaterial
    @MaterialCodigo NCHAR(8),
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Inventario.Material WHERE MaterialCodigo = @MaterialCodigo AND MaterialEstado = 'A')
            RAISERROR('El material no existe.', 16, 1)

        DECLARE @CantidadActual DECIMAL(10,2)
        SELECT @CantidadActual = MaterialCantidad FROM Inventario.Material WHERE MaterialCodigo = @MaterialCodigo

        UPDATE Inventario.Material SET MaterialEstado = 'E', MaterialCantidad = 0.00 WHERE MaterialCodigo = @MaterialCodigo

        INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialFecha, HistorialMaterialNota)
        VALUES (@MaterialCodigo, 'S03', @CantidadActual, @UsuarioID, GETDATE(), N'Material eliminado del taller.')

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, 'Material eliminado correctamente.' AS Mensaje
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.11 Inventario - Listar Calzado
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_ListarCalzado
AS
BEGIN
    SET NOCOUNT ON
    SELECT CalzadoCodigo AS codigo, CalzadoModelo AS modelo, CalzadoTipo AS tipo, CalzadoColor AS color,
           CalzadoTalla AS talla, CalzadoStock AS stock, CalzadoPrecioVenta AS precio,
           CASE WHEN CalzadoStock < 5 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS bajoStock
    FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    ORDER BY CalzadoModelo ASC, CalzadoTalla DESC
END
GO

-- 4.12 Inventario - Registrar Venta
CREATE OR ALTER PROCEDURE Inventario.USP_Calzado_RegistrarVenta
    @CalzadoCodigo NCHAR(8),
    @CantidadAVender INT,
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @StockActual INT
        DECLARE @Estado NCHAR(1)
        SELECT @StockActual = CalzadoStock, @Estado = CalzadoEstado FROM Inventario.Calzado WITH (UPDLOCK) WHERE CalzadoCodigo = @CalzadoCodigo

        IF @StockActual IS NULL OR @Estado <> 'A'
            RAISERROR('El calzado no existe o está inactivo.', 16, 1)

        IF @StockActual < @CantidadAVender
            RAISERROR('Stock insuficiente.', 16, 1)

        UPDATE Inventario.Calzado SET CalzadoStock = CalzadoStock - @CantidadAVender WHERE CalzadoCodigo = @CalzadoCodigo

        INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID, HistorialCalzadoFecha)
        VALUES (@CalzadoCodigo, 'S02', @CantidadAVender, @UsuarioID, GETDATE())

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, N'Venta registrada correctamente.' AS Mensaje
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.13 Inventario - Listar Calzado para Dropdown
CREATE OR ALTER PROCEDURE Inventario.USP_Calzado_ListarParaDropdown
AS
BEGIN
    SET NOCOUNT ON
    SELECT CalzadoCodigo AS codigo, RTRIM(CalzadoModelo) AS modelo, CalzadoTalla AS talla,
           RTRIM(CalzadoColor) AS color, CalzadoPrecioVenta AS precio, CalzadoStock AS stock
    FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    ORDER BY CalzadoModelo ASC, CalzadoTalla ASC
END
GO

-- 4.14 Inventario - Registrar Producción Calzado
CREATE OR ALTER PROCEDURE Inventario.USP_ProduccionCalzado_Registrar
    @CalzadoCodigo NCHAR(8),
    @CantidadPares INT,
    @UsuarioID NCHAR(8),
    @MaterialesJSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @NuevaOrdenID INT
        
        INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID)
        VALUES (@CalzadoCodigo, @CantidadPares, @UsuarioID)
        SET @NuevaOrdenID = SCOPE_IDENTITY()

        INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
        SELECT @NuevaOrdenID, j.codigo, (j.cantidadPorPar * @CantidadPares)
        FROM OPENJSON(@MaterialesJSON) WITH (codigo NCHAR(8) '$.codigo', cantidadPorPar DECIMAL(10,2) '$.cantidadPorPar') AS j

        UPDATE m SET m.MaterialCantidad = m.MaterialCantidad - (j.cantidadPorPar * @CantidadPares)
        FROM Inventario.Material m INNER JOIN OPENJSON(@MaterialesJSON) WITH (codigo NCHAR(8) '$.codigo', cantidadPorPar DECIMAL(10,2) '$.cantidadPorPar') AS j ON m.MaterialCodigo = j.codigo

        UPDATE Inventario.Calzado SET CalzadoStock = CalzadoStock + @CantidadPares WHERE CalzadoCodigo = @CalzadoCodigo

        INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID, HistorialCalzadoFecha)
        VALUES (@CalzadoCodigo, 'E02', @CantidadPares, @UsuarioID, GETDATE())

        INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialFecha, HistorialMaterialNota)
        SELECT j.codigo, 'S01', (j.cantidadPorPar * @CantidadPares), @UsuarioID, GETDATE(), N'Consumo por Producción - Orden #' + CAST(@NuevaOrdenID AS NVARCHAR(10))
        FROM OPENJSON(@MaterialesJSON) WITH (codigo NCHAR(8) '$.codigo', cantidadPorPar DECIMAL(10,2) '$.cantidadPorPar') AS j

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, N'Producción guardada con éxito. Orden #' + CAST(@NuevaOrdenID AS NVARCHAR(10)) AS Mensaje
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.15 Seguridad - Validar Acceso
CREATE OR ALTER PROCEDURE Seguridad.USP_Usuario_ValidarAcceso
    @UsuarioInput NVARCHAR(100),
    @UsuarioPassword NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON
    IF EXISTS (
        SELECT 1
        FROM Seguridad.Usuario
        WHERE (UsuarioLogin = @UsuarioInput OR UsuarioCorreo = @UsuarioInput)
          AND UsuarioPassword = @UsuarioPassword
          AND UsuarioEstado = 'A'
    )
    BEGIN
        SELECT
            'EXITO' AS Resultado,
            RTRIM(UsuarioID) AS UsuarioID,
            UsuarioNombre,
            RTRIM(UsuarioLogin) AS UsuarioLogin,
            RTRIM(UsuarioCorreo) AS UsuarioCorreo,
            RTRIM(TipoUsuarioCodigo) AS TipoUsuarioCodigo
        FROM Seguridad.Usuario
        WHERE (UsuarioLogin = @UsuarioInput OR UsuarioCorreo = @UsuarioInput)
          AND UsuarioPassword = @UsuarioPassword
    END
    ELSE
    BEGIN
        SELECT 'ERROR' AS Resultado, 'Usuario/Correo o contraseña incorrectos' AS Mensaje
    END
END
GO

-- 4.16 Seguridad - Restablecer Contraseña
CREATE OR ALTER PROCEDURE Seguridad.USP_Usuario_RestablecerPassword
    @UsuarioLogin NVARCHAR(20),
    @NuevaPassword NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION

        IF NOT EXISTS (SELECT 1 FROM Seguridad.Usuario WHERE UsuarioLogin = @UsuarioLogin AND UsuarioEstado = 'A')
        BEGIN
            RAISERROR('El nombre de usuario especificado no existe o está inactivo.', 16, 1)
        END

        UPDATE Seguridad.Usuario
        SET UsuarioPassword = @NuevaPassword
        WHERE UsuarioLogin = @UsuarioLogin

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, 'La contraseña ha sido restablecida correctamente.' AS Mensaje
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.17 Carrito - Obtener Detalle
CREATE OR ALTER PROCEDURE Inventario.USP_Carrito_ObtenerDetalle
    @UsuarioID NCHAR(8) = NULL,
    @CarritoID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @CarritoIDFinal INT

    IF @CarritoID IS NULL AND @UsuarioID IS NOT NULL
    BEGIN
        SELECT TOP 1 @CarritoIDFinal = CarritoID
        FROM Inventario.Carrito
        WHERE UsuarioID = @UsuarioID AND Estado = 'A'
        ORDER BY CarritoID DESC
    END
    ELSE
    BEGIN
        SET @CarritoIDFinal = @CarritoID
    END

    IF @CarritoIDFinal IS NULL
    BEGIN
        SELECT
            NULL AS CarritoID,
            NULL AS UsuarioID,
            NULL AS Total,
            CAST(0 AS INT) AS CantidadTotal,
            CAST(0 AS DECIMAL(10,2)) AS TotalGeneral,
            CAST(0 AS INT) AS NumeroItems
        RETURN
    END

    SELECT
        C.CarritoID,
        C.UsuarioID,
        U.UsuarioNombre AS UsuarioNombre,
        C.Total,
        C.FechaCreacion,
        C.FechaActualizacion,
        (SELECT COUNT(*) FROM Inventario.CarritoDetalle WHERE CarritoID = C.CarritoID) AS NumeroItems,
        (SELECT SUM(Cantidad) FROM Inventario.CarritoDetalle WHERE CarritoID = C.CarritoID) AS CantidadTotal
    FROM Inventario.Carrito C
    INNER JOIN Seguridad.Usuario U ON C.UsuarioID = U.UsuarioID
    WHERE C.CarritoID = @CarritoIDFinal

    SELECT
        CD.DetalleID,
        CD.CalzadoCodigo,
        CA.CalzadoModelo AS Modelo,
        CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla,
        CD.Cantidad,
        CD.PrecioUnitario,
        CD.Subtotal,
        CA.CalzadoStock AS StockDisponible,
        CD.FechaAgregado
    FROM Inventario.CarritoDetalle CD
    INNER JOIN Inventario.Calzado CA ON CD.CalzadoCodigo = CA.CalzadoCodigo
    WHERE CD.CarritoID = @CarritoIDFinal
    ORDER BY CD.FechaAgregado DESC
END
GO

-- 4.18 Carrito - Agregar Producto
CREATE OR ALTER PROCEDURE Inventario.USP_Carrito_AgregarProducto
    @UsuarioID NCHAR(8),
    @CalzadoCodigo NCHAR(8),
    @Cantidad INT
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @CarritoID INT
        DECLARE @PrecioUnitario DECIMAL(10,2)
        DECLARE @StockActual INT

        SELECT @StockActual = CalzadoStock, @PrecioUnitario = CalzadoPrecioVenta
        FROM Inventario.Calzado
        WHERE CalzadoCodigo = @CalzadoCodigo AND CalzadoEstado = 'A'

        IF @StockActual IS NULL
            RAISERROR('El calzado no existe o está inactivo.', 16, 1)

        IF @Cantidad > @StockActual
        BEGIN
            DECLARE @MsgStock NVARCHAR(200) = 'Stock insuficiente. Disponible: ' + CAST(@StockActual AS NVARCHAR(10))
            RAISERROR(@MsgStock, 16, 1)
        END

        SELECT TOP 1 @CarritoID = CarritoID
        FROM Inventario.Carrito
        WHERE UsuarioID = @UsuarioID AND Estado = 'A'
        ORDER BY CarritoID DESC

        IF @CarritoID IS NULL
        BEGIN
            INSERT INTO Inventario.Carrito (UsuarioID, Total)
            VALUES (@UsuarioID, 0.00)
            SET @CarritoID = SCOPE_IDENTITY()
        END

        IF EXISTS (
            SELECT 1 FROM Inventario.CarritoDetalle
            WHERE CarritoID = @CarritoID AND CalzadoCodigo = @CalzadoCodigo
        )
        BEGIN
            UPDATE Inventario.CarritoDetalle
            SET Cantidad = Cantidad + @Cantidad,
                Subtotal = (Cantidad + @Cantidad) * @PrecioUnitario,
                FechaAgregado = GETDATE()
            WHERE CarritoID = @CarritoID AND CalzadoCodigo = @CalzadoCodigo
        END
        ELSE
        BEGIN
            INSERT INTO Inventario.CarritoDetalle (CarritoID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
            VALUES (@CarritoID, @CalzadoCodigo, @Cantidad, @PrecioUnitario, @Cantidad * @PrecioUnitario)
        END

        UPDATE Inventario.Carrito
        SET Total = (SELECT SUM(Subtotal) FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID),
            FechaActualizacion = GETDATE()
        WHERE CarritoID = @CarritoID

        COMMIT TRANSACTION
        EXEC Inventario.USP_Carrito_ObtenerDetalle @CarritoID = @CarritoID
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.19 Carrito - Actualizar Cantidad
CREATE OR ALTER PROCEDURE Inventario.USP_Carrito_ActualizarCantidad
    @UsuarioID NCHAR(8),
    @DetalleID BIGINT,
    @NuevaCantidad INT
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @CarritoID INT
        DECLARE @CalzadoCodigo NCHAR(8)
        DECLARE @PrecioUnitario DECIMAL(10,2)
        DECLARE @StockActual INT

        SELECT @CarritoID = CD.CarritoID, @CalzadoCodigo = CD.CalzadoCodigo, @PrecioUnitario = CD.PrecioUnitario
        FROM Inventario.CarritoDetalle CD
        INNER JOIN Inventario.Carrito C ON CD.CarritoID = C.CarritoID
        WHERE CD.DetalleID = @DetalleID AND C.UsuarioID = @UsuarioID AND C.Estado = 'A'

        IF @CarritoID IS NULL
            RAISERROR('El producto no pertenece a tu carrito activo.', 16, 1)

        IF @NuevaCantidad <= 0
        BEGIN
            DELETE FROM Inventario.CarritoDetalle WHERE DetalleID = @DetalleID
            IF NOT EXISTS (SELECT 1 FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID)
            BEGIN
                UPDATE Inventario.Carrito SET Estado = 'E', Total = 0.00 WHERE CarritoID = @CarritoID
            END
        END
        ELSE
        BEGIN
            SELECT @StockActual = CalzadoStock FROM Inventario.Calzado WHERE CalzadoCodigo = @CalzadoCodigo AND CalzadoEstado = 'A'
            IF @NuevaCantidad > @StockActual
            BEGIN
                DECLARE @MsgStock2 NVARCHAR(200) = 'Stock insuficiente. Disponible: ' + CAST(@StockActual AS NVARCHAR(10))
                RAISERROR(@MsgStock2, 16, 1)
            END

            UPDATE Inventario.CarritoDetalle
            SET Cantidad = @NuevaCantidad, Subtotal = @NuevaCantidad * @PrecioUnitario
            WHERE DetalleID = @DetalleID
        END

        UPDATE Inventario.Carrito
        SET Total = (SELECT ISNULL(SUM(Subtotal), 0) FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID),
            FechaActualizacion = GETDATE()
        WHERE CarritoID = @CarritoID

        COMMIT TRANSACTION
        EXEC Inventario.USP_Carrito_ObtenerDetalle @UsuarioID = @UsuarioID
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.20 Carrito - Eliminar Producto
CREATE OR ALTER PROCEDURE Inventario.USP_Carrito_EliminarProducto
    @UsuarioID NCHAR(8),
    @DetalleID BIGINT
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @CarritoID INT

        SELECT @CarritoID = CD.CarritoID
        FROM Inventario.CarritoDetalle CD
        INNER JOIN Inventario.Carrito C ON CD.CarritoID = C.CarritoID
        WHERE CD.DetalleID = @DetalleID AND C.UsuarioID = @UsuarioID AND C.Estado = 'A'

        IF @CarritoID IS NULL
            RAISERROR('El producto no pertenece a tu carrito activo.', 16, 1)

        DELETE FROM Inventario.CarritoDetalle WHERE DetalleID = @DetalleID

        IF NOT EXISTS (SELECT 1 FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID)
        BEGIN
            UPDATE Inventario.Carrito SET Estado = 'E', Total = 0.00 WHERE CarritoID = @CarritoID
        END
        ELSE
        BEGIN
            UPDATE Inventario.Carrito
            SET Total = (SELECT ISNULL(SUM(Subtotal), 0) FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID),
                FechaActualizacion = GETDATE()
            WHERE CarritoID = @CarritoID
        END

        COMMIT TRANSACTION
        EXEC Inventario.USP_Carrito_ObtenerDetalle @UsuarioID = @UsuarioID
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.21 Carrito - Limpiar Carrito
CREATE OR ALTER PROCEDURE Inventario.USP_Carrito_Limpiar
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        DECLARE @CarritoID INT

        SELECT TOP 1 @CarritoID = CarritoID
        FROM Inventario.Carrito
        WHERE UsuarioID = @UsuarioID AND Estado = 'A'
        ORDER BY CarritoID DESC

        IF @CarritoID IS NOT NULL
        BEGIN
            DELETE FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID
            UPDATE Inventario.Carrito SET Estado = 'E', Total = 0.00 WHERE CarritoID = @CarritoID
        END

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, 'Carrito limpiado correctamente' AS Mensaje
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.22 Carrito - Confirmar Venta
CREATE OR ALTER PROCEDURE Inventario.USP_Carrito_ConfirmarVenta
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION
        
        DECLARE @CarritoID INT
        DECLARE @VentaID INT
        DECLARE @Total DECIMAL(10,2)
        DECLARE @ErrorStock NVARCHAR(MAX) = ''
        
        SELECT TOP 1 @CarritoID = CarritoID, @Total = Total
        FROM Inventario.Carrito
        WHERE UsuarioID = @UsuarioID AND Estado = 'A'
        ORDER BY CarritoID DESC
        
        IF @CarritoID IS NULL
        BEGIN
            RAISERROR('No tienes un carrito activo con productos.', 16, 1)
        END
        
        IF @Total = 0
        BEGIN
            RAISERROR('El carrito está vacío.', 16, 1)
        END
        
        SELECT @ErrorStock = @ErrorStock + 
            CA.CalzadoModelo + ' (Stock: ' + CAST(CA.CalzadoStock AS NVARCHAR(10)) + 
            ', Solicitado: ' + CAST(CD.Cantidad AS NVARCHAR(10)) + ')' + CHAR(10)
        FROM Inventario.CarritoDetalle CD
        INNER JOIN Inventario.Calzado CA ON CD.CalzadoCodigo = CA.CalzadoCodigo
        WHERE CD.CarritoID = @CarritoID AND CA.CalzadoStock < CD.Cantidad
        
        IF @ErrorStock <> ''
        BEGIN
            DECLARE @MsgError NVARCHAR(MAX) = 'Stock insuficiente para los siguientes productos:' + CHAR(10) + @ErrorStock
            RAISERROR(@MsgError, 16, 1)
        END
        
        INSERT INTO Inventario.Venta (
            UsuarioID,
            CarritoID,
            Total,
            FechaVenta,
            Estado
        )
        VALUES (
            @UsuarioID,
            @CarritoID,
            @Total,
            GETDATE(),
            'A'
        )
        
        SET @VentaID = SCOPE_IDENTITY()
        
        INSERT INTO Inventario.VentaDetalle (
            VentaID,
            CalzadoCodigo,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT 
            @VentaID,
            CalzadoCodigo,
            Cantidad,
            PrecioUnitario,
            Subtotal
        FROM Inventario.CarritoDetalle
        WHERE CarritoID = @CarritoID
        
        INSERT INTO Inventario.HistorialCalzado (
            CalzadoCodigo,
            TipoMovimientoCodigo,
            HistorialCalzadoCantidad,
            UsuarioID,
            HistorialCalzadoFecha
        )
        SELECT 
            CD.CalzadoCodigo,
            'S02', -- Salida por Venta
            CD.Cantidad,
            @UsuarioID,
            GETDATE()
        FROM Inventario.CarritoDetalle CD
        WHERE CD.CarritoID = @CarritoID
        
        UPDATE CA
        SET CA.CalzadoStock = CA.CalzadoStock - CD.Cantidad
        FROM Inventario.Calzado CA
        INNER JOIN Inventario.CarritoDetalle CD ON CA.CalzadoCodigo = CD.CalzadoCodigo
        WHERE CD.CarritoID = @CarritoID
        
        UPDATE Inventario.Carrito
        SET Estado = 'C',
            FechaActualizacion = GETDATE()
        WHERE CarritoID = @CarritoID
        
        COMMIT TRANSACTION
        
        SELECT 
            @VentaID AS VentaID,
            @CarritoID AS CarritoID,
            @Total AS Total,
            GETDATE() AS FechaVenta,
            'EXITO' AS Resultado,
            'Venta realizada con éxito. Venta #' + CAST(@VentaID AS NVARCHAR(10)) AS Mensaje
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- 4.23 Venta - Obtener Historial
CREATE OR ALTER PROCEDURE Inventario.USP_Venta_ObtenerHistorial
    @UsuarioID NCHAR(8) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @VentaID INT = NULL
AS
BEGIN
    SET NOCOUNT ON
    IF @FechaInicio IS NULL SET @FechaInicio = DATEADD(DAY, -30, GETDATE())
    IF @FechaFin IS NULL SET @FechaFin = GETDATE()

    SELECT
        V.VentaID,
        V.UsuarioID,
        U.UsuarioNombre,
        V.FechaVenta,
        V.Total,
        V.Estado,
        (SELECT COUNT(*) FROM Inventario.VentaDetalle VD WHERE VD.VentaID = V.VentaID) AS NumeroItems,
        (SELECT SUM(Cantidad) FROM Inventario.VentaDetalle VD WHERE VD.VentaID = V.VentaID) AS CantidadTotal
    FROM Inventario.Venta V
    INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
    WHERE (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)
        AND (@VentaID IS NULL OR V.VentaID = @VentaID)
        AND V.FechaVenta BETWEEN @FechaInicio AND @FechaFin
    ORDER BY V.FechaVenta DESC
END
GO

-- 4.24 Venta - Obtener Detalle
CREATE OR ALTER PROCEDURE Inventario.USP_Venta_ObtenerDetalle
    @VentaID INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        V.VentaID,
        V.UsuarioID,
        U.UsuarioNombre,
        V.FechaVenta,
        V.Total,
        V.Estado
    FROM Inventario.Venta V
    INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
    WHERE V.VentaID = @VentaID

    SELECT
        VD.VentaDetalleID,
        VD.CalzadoCodigo,
        CA.CalzadoModelo AS Modelo,
        CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla,
        VD.Cantidad,
        VD.PrecioUnitario,
        VD.Subtotal
    FROM Inventario.VentaDetalle VD
    INNER JOIN Inventario.Calzado CA ON VD.CalzadoCodigo = CA.CalzadoCodigo
    WHERE VD.VentaID = @VentaID
    ORDER BY VD.VentaDetalleID
END
GO

-- =========================================================================
-- 5. REPORTES - STORED PROCEDURES 
-- =========================================================================

-- =========================================================================
-- 5.1 REPORTE DE VENTAS - RESUMEN CON FILTROS
-- =========================================================================
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Ventas  
    @FechaInicio DATE = NULL,  
    @FechaFin DATE = NULL,  
    @TipoFiltro NVARCHAR(20) = 'MES',  
    @UsuarioID NCHAR(8) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON  
      
    IF @FechaInicio IS NULL  
        SET @FechaInicio = DATEADD(DAY, -30, GETDATE())  
    IF @FechaFin IS NULL  
        SET @FechaFin = GETDATE()  
      
    -- Ajustar según tipo de filtro  
    IF @TipoFiltro = 'DIA'  
    BEGIN  
        SET @FechaInicio = CAST(GETDATE() AS DATE)  
        SET @FechaFin = CAST(GETDATE() AS DATE)  
    END  
    ELSE IF @TipoFiltro = 'SEMANA'  
    BEGIN  
        SET @FechaInicio = DATEADD(DAY, -7, CAST(GETDATE() AS DATE))  
        SET @FechaFin = CAST(GETDATE() AS DATE)  
    END  
    ELSE IF @TipoFiltro = 'MES'  
    BEGIN  
        SET @FechaInicio = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE))  
        SET @FechaFin = CAST(GETDATE() AS DATE)  
    END  
    ELSE IF @TipoFiltro = 'ANIO'  
    BEGIN  
        SET @FechaInicio = DATEADD(YEAR, -1, CAST(GETDATE() AS DATE))  
        SET @FechaFin = CAST(GETDATE() AS DATE)  
    END  

    -- ====== 1. RESUMEN GENERAL ======  
    SELECT  
        @FechaInicio AS FechaInicio,  
        @FechaFin AS FechaFin,  
        @TipoFiltro AS TipoFiltro,  
        COUNT(DISTINCT V.VentaID) AS TotalVentas,  
        ISNULL(SUM(V.Total), 0) AS TotalIngresos,  
        ISNULL(SUM(VD.Cantidad), 0) AS TotalParesVendidos,  
        ISNULL(AVG(V.Total), 0) AS PromedioPorVenta,  
        COUNT(DISTINCT VD.CalzadoCodigo) AS ProductosVendidos,  
        COUNT(DISTINCT V.UsuarioID) AS VendedoresActivos  
    FROM Inventario.Venta V  
    LEFT JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID  
    WHERE CAST(V.FechaVenta AS DATE) BETWEEN @FechaInicio AND @FechaFin  
        AND V.Estado = 'A'  
        AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)  

    -- ====== 2. TOP 5 PRODUCTOS MÁS VENDIDOS ======  
    SELECT TOP 5  
        CA.CalzadoModelo AS Modelo,  
        CA.CalzadoTipo AS Tipo,  
        CA.CalzadoColor AS Color,  
        CA.CalzadoTalla AS Talla,  
        ISNULL(SUM(VD.Cantidad), 0) AS TotalVendido,  
        ISNULL(SUM(VD.Subtotal), 0) AS TotalIngresado  
    FROM Inventario.Venta V  
    INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID  
    INNER JOIN Inventario.Calzado CA ON VD.CalzadoCodigo = CA.CalzadoCodigo  
    WHERE CAST(V.FechaVenta AS DATE) BETWEEN @FechaInicio AND @FechaFin 
        AND V.Estado = 'A'  
        AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)  
    GROUP BY CA.CalzadoModelo, CA.CalzadoTipo, CA.CalzadoColor, CA.CalzadoTalla  
    ORDER BY ISNULL(SUM(VD.Cantidad), 0) DESC  

    -- ====== 3. VENTAS POR DÍA ======  
    SELECT  
        CAST(V.FechaVenta AS DATE) AS Fecha,  
        COUNT(*) AS NumeroVentas,  
        SUM(V.Total) AS IngresosDelDia,  
        ISNULL(SUM(VD.Cantidad), 0) AS ParesVendidos  
    FROM Inventario.Venta V  
    LEFT JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID  
    WHERE CAST(V.FechaVenta AS DATE) BETWEEN @FechaInicio AND @FechaFin  
        AND V.Estado = 'A'  
        AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)  
    GROUP BY CAST(V.FechaVenta AS DATE)  
    ORDER BY Fecha DESC  

    -- ====== 4. VENTAS POR TIPO DE CALZADO ======  
    SELECT  
        CA.CalzadoTipo AS TipoCalzado,  
        COUNT(DISTINCT V.VentaID) AS NumeroVentas,  
        ISNULL(SUM(VD.Cantidad), 0) AS ParesVendidos,  
        ISNULL(SUM(VD.Subtotal), 0) AS IngresosTotales  
    FROM Inventario.Venta V  
    INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID  
    INNER JOIN Inventario.Calzado CA ON VD.CalzadoCodigo = CA.CalzadoCodigo  
    WHERE CAST(V.FechaVenta AS DATE) BETWEEN @FechaInicio AND @FechaFin 
        AND V.Estado = 'A'  
        AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)  
    GROUP BY CA.CalzadoTipo  
    ORDER BY ISNULL(SUM(VD.Cantidad), 0) DESC  
END  
GO   

-- =========================================================================
-- 5.2 REPORTE DE PRODUCCIÓN - RESUMEN CON FILTROS
-- =========================================================================
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Produccion
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @TipoFiltro NVARCHAR(20) = 'MES', 
    @UsuarioID NCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @FechaInicio IS NULL
        SET @FechaInicio = DATEADD(DAY, -30, GETDATE())
    IF @FechaFin IS NULL
        SET @FechaFin = GETDATE()
    
    IF @TipoFiltro = 'DIA'
    BEGIN
        SET @FechaInicio = CAST(GETDATE() AS DATE)
        SET @FechaFin = CAST(GETDATE() AS DATE)
    END
    ELSE IF @TipoFiltro = 'SEMANA'
    BEGIN
        SET @FechaInicio = DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
        SET @FechaFin = CAST(GETDATE() AS DATE)
    END
    ELSE IF @TipoFiltro = 'MES'
    BEGIN
        SET @FechaInicio = DATEADD(MONTH, -1, CAST(GETDATE() AS DATE))
        SET @FechaFin = CAST(GETDATE() AS DATE)
    END
    ELSE IF @TipoFiltro = 'ANIO'
    BEGIN
        SET @FechaInicio = DATEADD(YEAR, -1, CAST(GETDATE() AS DATE))
        SET @FechaFin = CAST(GETDATE() AS DATE)
    END

    -- ====== 1. RESUMEN GENERAL ======
    SELECT
        @FechaInicio AS FechaInicio,
        @FechaFin AS FechaFin,
        @TipoFiltro AS TipoFiltro,
        COUNT(DISTINCT O.OrdenID) AS TotalOrdenes,
        ISNULL(SUM(O.CantidadPares), 0) AS TotalParesProducidos,
        ISNULL(AVG(O.CantidadPares), 0) AS PromedioParesPorOrden,
        COUNT(DISTINCT O.UsuarioID) AS OperariosActivos,
        COUNT(DISTINCT O.CalzadoCodigo) AS ModelosProducidos
    FROM Inventario.OrdenProduccion O
    WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)

    -- ====== 2. TOP 5 MODELOS PRODUCIDOS ======
    SELECT TOP 5
        CA.CalzadoModelo AS Modelo,
        CA.CalzadoTipo AS Tipo,
        CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla,
        SUM(O.CantidadPares) AS TotalProducido,
        COUNT(DISTINCT O.OrdenID) AS NumeroOrdenes
    FROM Inventario.OrdenProduccion O
    INNER JOIN Inventario.Calzado CA ON O.CalzadoCodigo = CA.CalzadoCodigo
    WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    GROUP BY CA.CalzadoModelo, CA.CalzadoTipo, CA.CalzadoColor, CA.CalzadoTalla
    ORDER BY SUM(O.CantidadPares) DESC

    -- ====== 3. PRODUCCIÓN POR DÍA ======
    SELECT
        CAST(O.OrdenFecha AS DATE) AS Fecha,
        COUNT(*) AS NumeroOrdenes,
        SUM(O.CantidadPares) AS ParesProducidos
    FROM Inventario.OrdenProduccion O
    WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    GROUP BY CAST(O.OrdenFecha AS DATE)
    ORDER BY Fecha DESC

    -- ====== 4. CONSUMO DE MATERIALES ======
    SELECT TOP 5
        M.MaterialNombre AS Material,
        M.MaterialCategoria AS Categoria,
        SUM(OD.CantidadConsumida) AS TotalConsumido,
        M.MaterialMedida AS Unidad
    FROM Inventario.OrdenProduccionDetalle OD
    INNER JOIN Inventario.Material M ON OD.MaterialCodigo = M.MaterialCodigo
    INNER JOIN Inventario.OrdenProduccion O ON OD.OrdenID = O.OrdenID
    WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    GROUP BY M.MaterialNombre, M.MaterialCategoria, M.MaterialMedida
    ORDER BY SUM(OD.CantidadConsumida) DESC
END
GO

-- =========================================================================
-- 5.3 REPORTE COMPARATIVO - VENTAS VS PRODUCCIÓN (SIMPLIFICADO)
-- =========================================================================
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Comparativo
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @FechaInicio IS NULL
        SET @FechaInicio = DATEADD(MONTH, -6, GETDATE())
    IF @FechaFin IS NULL
        SET @FechaFin = GETDATE()

    -- Ventas agrupadas por mes
    ;WITH Ventas AS (
        SELECT
            FORMAT(V.FechaVenta, 'yyyy-MM') AS Periodo,
            SUM(V.Total) AS TotalVentas,
            SUM(VD.Cantidad) AS ParesVendidos
        FROM Inventario.Venta V
        LEFT JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID
        WHERE V.FechaVenta BETWEEN @FechaInicio AND @FechaFin
            AND V.Estado = 'A'
        GROUP BY FORMAT(V.FechaVenta, 'yyyy-MM')
    ),
    Produccion AS (
        SELECT
            FORMAT(O.OrdenFecha, 'yyyy-MM') AS Periodo,
            SUM(O.CantidadPares) AS ParesProducidos
        FROM Inventario.OrdenProduccion O
        WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        GROUP BY FORMAT(O.OrdenFecha, 'yyyy-MM')
    )
    SELECT
        ISNULL(V.Periodo, P.Periodo) AS Periodo,
        ISNULL(V.TotalVentas, 0) AS IngresosPorVentas,
        ISNULL(V.ParesVendidos, 0) AS ParesVendidos,
        ISNULL(P.ParesProducidos, 0) AS ParesProducidos,
        -- Diferencia (Producción - Ventas)
        ISNULL(P.ParesProducidos, 0) - ISNULL(V.ParesVendidos, 0) AS DiferenciaPares,
        -- Porcentaje de conversión (Ventas / Producción)
        CASE 
            WHEN ISNULL(P.ParesProducidos, 0) = 0 THEN 0
            ELSE CAST(ISNULL(V.ParesVendidos, 0) AS DECIMAL(10,2)) / CAST(P.ParesProducidos AS DECIMAL(10,2)) * 100
        END AS PorcentajeConversion
    FROM Ventas V
    FULL OUTER JOIN Produccion P ON V.Periodo = P.Periodo
    ORDER BY Periodo DESC 
END
GO

-- =========================================================================
-- 5.4 REPORTE DE STOCK ACTUAL (SIMPLIFICADO)
-- =========================================================================
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Stock
    @Tipo NVARCHAR(20) = 'TODOS' 
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #StockTemp (
        Tipo NVARCHAR(20),
        Codigo NVARCHAR(10),
        Nombre NVARCHAR(100),
        Categoria NVARCHAR(50),
        Color NVARCHAR(50),
        Talla NVARCHAR(10),
        Stock NVARCHAR(20),
        Precio NVARCHAR(20),
        Estado NVARCHAR(20),
        Prioridad INT,
        StockNumero FLOAT
    )

    IF @Tipo = 'TODOS' OR @Tipo = 'CALZADO'
    BEGIN
        INSERT INTO #StockTemp (Tipo, Codigo, Nombre, Categoria, Color, Talla, Stock, Precio, Estado, Prioridad, StockNumero)
        SELECT
            'Calzado' AS Tipo,
            CalzadoCodigo AS Codigo,
            CalzadoModelo AS Nombre,
            CalzadoTipo AS Categoria,
            CalzadoColor AS Color,
            CAST(CalzadoTalla AS NVARCHAR(10)) AS Talla,
            CAST(CalzadoStock AS NVARCHAR(20)) AS Stock,
            CAST(CalzadoPrecioVenta AS NVARCHAR(20)) AS Precio,
            CASE 
                WHEN CalzadoStock = 0 THEN 'Sin Stock'
                WHEN CalzadoStock <= 5 THEN 'Stock Bajo'
                ELSE 'Stock Normal'
            END AS Estado,
            CASE 
                WHEN CalzadoStock = 0 THEN 1
                WHEN CalzadoStock <= 5 THEN 2
                ELSE 3
            END AS Prioridad,
            CAST(CalzadoStock AS FLOAT) AS StockNumero
        FROM Inventario.Calzado
        WHERE CalzadoEstado = 'A'
    END

    IF @Tipo = 'TODOS' OR @Tipo = 'MATERIAL'
    BEGIN
        INSERT INTO #StockTemp (Tipo, Codigo, Nombre, Categoria, Color, Talla, Stock, Precio, Estado, Prioridad, StockNumero)
        SELECT
            'Material' AS Tipo,
            MaterialCodigo AS Codigo,
            MaterialNombre AS Nombre,
            MaterialCategoria AS Categoria,
            '' AS Color,
            'N/A' AS Talla,
            CAST(MaterialCantidad AS NVARCHAR(20)) AS Stock,
            'S/.0.00' AS Precio,
            CASE 
                WHEN MaterialCantidad = 0 THEN 'Sin Stock'
                WHEN MaterialCantidad <= 5 THEN 'Stock Bajo'
                ELSE 'Stock Normal'
            END AS Estado,
            CASE 
                WHEN MaterialCantidad = 0 THEN 1
                WHEN MaterialCantidad <= 5 THEN 2
                ELSE 3
            END AS Prioridad,
            CAST(MaterialCantidad AS FLOAT) AS StockNumero
        FROM Inventario.Material
        WHERE MaterialEstado = 'A'
    END

    SELECT 
        Tipo,
        Codigo,
        Nombre,
        Categoria,
        Color,
        Talla,
        Stock,
        Precio,
        Estado
    FROM #StockTemp
    ORDER BY Prioridad ASC, StockNumero ASC

    DROP TABLE #StockTemp
END
GO

-- =========================================================================
-- 5.5 REPORTE DE VENTAS DETALLADO (para PDF)
-- =========================================================================
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Ventas_Detalle
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @UsuarioID NCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @FechaInicio IS NULL
        SET @FechaInicio = DATEADD(DAY, -30, GETDATE())
    IF @FechaFin IS NULL
        SET @FechaFin = GETDATE()

    SELECT
        V.VentaID,
        V.FechaVenta AS Fecha,
        V.Total AS TotalVenta,
        U.UsuarioNombre AS Vendedor,
        CA.CalzadoModelo AS Modelo,
        CA.CalzadoTipo AS Tipo,
        CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla,
        VD.Cantidad,
        VD.PrecioUnitario,
        VD.Subtotal
    FROM Inventario.Venta V
    INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID
    INNER JOIN Inventario.Calzado CA ON VD.CalzadoCodigo = CA.CalzadoCodigo
    INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
    WHERE V.FechaVenta BETWEEN @FechaInicio AND @FechaFin
        AND V.Estado = 'A'
        AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)
    ORDER BY V.FechaVenta DESC, V.VentaID DESC
END
GO

-- =========================================================================
-- 5.6 REPORTE DE PRODUCCIÓN DETALLADO (para PDF)
-- =========================================================================
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Produccion_Detalle
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @UsuarioID NCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @FechaInicio IS NULL
        SET @FechaInicio = DATEADD(DAY, -30, GETDATE())
    IF @FechaFin IS NULL
        SET @FechaFin = GETDATE()

    -- Cabecera
    SELECT
        O.OrdenID,
        O.OrdenFecha AS Fecha,
        O.CantidadPares AS ParesProducidos,
        U.UsuarioNombre AS Operario,
        CA.CalzadoModelo AS Modelo,
        CA.CalzadoTipo AS Tipo,
        CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla
    FROM Inventario.OrdenProduccion O
    INNER JOIN Inventario.Calzado CA ON O.CalzadoCodigo = CA.CalzadoCodigo
    INNER JOIN Seguridad.Usuario U ON O.UsuarioID = U.UsuarioID
    WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    ORDER BY O.OrdenFecha DESC, O.OrdenID DESC

    -- Materiales consumidos
    SELECT
        OD.OrdenID,
        M.MaterialNombre AS Material,
        OD.CantidadConsumida AS Cantidad,
        M.MaterialMedida AS Unidad
    FROM Inventario.OrdenProduccionDetalle OD
    INNER JOIN Inventario.Material M ON OD.MaterialCodigo = M.MaterialCodigo
    WHERE OD.OrdenID IN (
        SELECT O.OrdenID
        FROM Inventario.OrdenProduccion O
        WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
            AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    )
    ORDER BY OD.OrdenID, M.MaterialNombre
END
GO


