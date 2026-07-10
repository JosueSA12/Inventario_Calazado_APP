USE [DB_TallerCalzado] 
GO

-- =========================================================================
-- CREACIÓN DE SCHEMAS (SI NO EXISTEN)
-- =========================================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Seguridad')
BEGIN
    EXEC('CREATE SCHEMA Seguridad ') 
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Inventario')
BEGIN
    EXEC('CREATE SCHEMA Inventario ') 
END
GO

-- =========================================================================
-- CREACIÓN DE TABLAS (ORDENADAS POR DEPENDENCIAS)
-- =========================================================================

-- TABLA: Seguridad.TipoUsuario (Independiente)
CREATE TABLE Seguridad.TipoUsuario (
    TipoUsuarioCodigo NCHAR(5),
    TipoUsuarioDescription NVARCHAR(50) NOT NULL,
    TipoUsuarioEstado NCHAR(1) CONSTRAINT TipoUsuarioEstadoDF DEFAULT 'A',
    CONSTRAINT TipoUsuarioPK PRIMARY KEY (TipoUsuarioCodigo),
    CONSTRAINT TipoUsuarioDescripcionUQ UNIQUE (TipoUsuarioDescription),
    CONSTRAINT TipoUsuarioEstadoCK CHECK (TipoUsuarioEstado = 'A' or TipoUsuarioEstado = 'E')
) ON [Primary] 
GO

-- TABLA: Seguridad.Usuario (Depende de TipoUsuario)
CREATE TABLE Seguridad.Usuario (
    UsuarioID NCHAR(8),
    UsuarioNombre NVARCHAR(100) NOT NULL,
    UsuarioLogin NVARCHAR(20) NOT NULL,
    UsuarioPassword NVARCHAR(50) NOT NULL,
    TipoUsuarioCodigo NCHAR(5) NOT NULL,
    UsuarioFechaCreacion DATE CONSTRAINT UsuarioFechaCreacionDF DEFAULT GETDATE(),
    UsuarioEstado NCHAR(1) CONSTRAINT UsuarioEstadoDF DEFAULT 'A',
    CONSTRAINT UsuarioPK PRIMARY KEY (UsuarioID),
    CONSTRAINT UsuarioLoginUQ UNIQUE (UsuarioLogin),
    CONSTRAINT UsuarioTipoUsuarioFK FOREIGN KEY (TipoUsuarioCodigo) REFERENCES Seguridad.TipoUsuario(TipoUsuarioCodigo),
    CONSTRAINT UsuarioFechaCreacionCK CHECK (UsuarioFechaCreacion <= GETDATE()),
    CONSTRAINT UsuarioEstadoCK CHECK (UsuarioEstado = 'A' or UsuarioEstado = 'E')
) ON [Primary] 
GO

-- TABLA: Inventario.Material (Independiente)
CREATE TABLE Inventario.Material (
    MaterialCodigo NCHAR(8),
    MaterialNombre NVARCHAR(100) NOT NULL,
    MaterialCategoria NVARCHAR(50) NOT NULL,
    MaterialCantidad DECIMAL(10,2) CONSTRAINT MaterialCantidadDF DEFAULT 0.00,
    MaterialMedida NVARCHAR(20) NOT NULL,
    MaterialProveedor NVARCHAR(100),
    MaterialEstado NCHAR(1) CONSTRAINT MaterialEstadoDF DEFAULT 'A',
    CONSTRAINT MaterialPK PRIMARY KEY (MaterialCodigo),
    CONSTRAINT MaterialCantidadCK CHECK (MaterialCantidad >= 0),
    CONSTRAINT MaterialCategoriaCK CHECK (MaterialCategoria IN ('Cuero', 'Suelas', 'Hilos', 'Pegamentos / Tintes', 'Herrajes / Ojales')),
    CONSTRAINT MaterialEstadoCK CHECK (MaterialEstado = 'A' or MaterialEstado = 'E')
) ON [Primary] 
GO

-- TABLA: Inventario.Calzado (Independiente)
CREATE TABLE Inventario.Calzado (
    CalzadoCodigo NCHAR(8),
    CalzadoModelo NVARCHAR(100) NOT NULL,
    CalzadoTipo NVARCHAR(30) NOT NULL,
    CalzadoColor NVARCHAR(50) NOT NULL,
    CalzadoTalla INT NOT NULL,
    CalzadoStock INT CONSTRAINT CalzadoStockDF DEFAULT 0,
    CalzadoPrecioVenta DECIMAL(10,2) NOT NULL,
    CalzadoEstado NCHAR(1) CONSTRAINT CalzadoEstadoDF DEFAULT 'A',
    CONSTRAINT CalzadoPK PRIMARY KEY (CalzadoCodigo),
    CONSTRAINT CalzadoStockCK CHECK (CalzadoStock >= 0),
    CONSTRAINT CalzadoPrecioCK CHECK (CalzadoPrecioVenta > 0),
    CONSTRAINT CalzadoTallaCK CHECK (CalzadoTalla BETWEEN 25 AND 45),
    CONSTRAINT CalzadoEstadoCK CHECK (CalzadoEstado = 'A' or CalzadoEstado = 'E')
) ON [Primary] 
GO

-- TABLA: Inventario.TipoMovimiento (Independiente)
CREATE TABLE Inventario.TipoMovimiento (
    TipoMovimientoCodigo NCHAR(3),
    TipoMovimientoDescripcion NVARCHAR(50) NOT NULL, 
    TipoMovimientoFactor INT NOT NULL, -- 1 entradas, -1 salidas
    TipoMovimientoEstado NCHAR(1) CONSTRAINT TipoMovimientoEstadoDF DEFAULT 'A',
    CONSTRAINT TipoMovimientoPK PRIMARY KEY (TipoMovimientoCodigo),
    CONSTRAINT TipoMovimientoDescripcionUQ UNIQUE (TipoMovimientoDescripcion),
    CONSTRAINT TipoMovimientoFactorCK CHECK (TipoMovimientoFactor = 1 or TipoMovimientoFactor = -1),
    CONSTRAINT TipoMovimientoEstadoCK CHECK (TipoMovimientoEstado = 'A' or TipoMovimientoEstado = 'E')
) ON [Primary] 
GO

-- TABLA: Inventario.HistorialMaterial (Depende de Material, TipoMovimiento y Usuario)
CREATE TABLE Inventario.HistorialMaterial (
    HistorialMaterialId BIGINT IDENTITY(1,1),
    MaterialCodigo NCHAR(8) NOT NULL,
    TipoMovimientoCodigo NCHAR(3) NOT NULL,
    HistorialMaterialCantidad DECIMAL(10,2) NOT NULL,
    HistorialMaterialFecha DATETIME CONSTRAINT HistorialMaterialFechaDF DEFAULT GETDATE(),
    UsuarioID NCHAR(8) NOT NULL, 
    HistorialMaterialNota NVARCHAR(255), 
    CONSTRAINT HistorialMaterialPK PRIMARY KEY (HistorialMaterialId),
    CONSTRAINT HistorialMaterialCantidadCK CHECK (HistorialMaterialCantidad > 0),
    CONSTRAINT HistorialMaterial_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo),
    CONSTRAINT HistorialMaterial_TipoMovimientoFK FOREIGN KEY (TipoMovimientoCodigo) REFERENCES Inventario.TipoMovimiento(TipoMovimientoCodigo),
    CONSTRAINT HistorialMaterial_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID),
    CONSTRAINT HistorialMaterialFechaCK CHECK (HistorialMaterialFecha <= GETDATE())
) ON [Primary] 
GO

-- TABLA: Inventario.HistorialCalzado (Depende de Calzado, TipoMovimiento y Usuario)
CREATE TABLE Inventario.HistorialCalzado (
    HistorialCalzadoId BIGINT IDENTITY(1,1),
    CalzadoCodigo NCHAR(8) NOT NULL,
    TipoMovimientoCodigo NCHAR(3) NOT NULL,
    HistorialCalzadoCantidad INT NOT NULL,
    HistorialCalzadoFecha DATETIME CONSTRAINT HistorialCalzadoFechaDF DEFAULT GETDATE(), 
    UsuarioID NCHAR(8) NOT NULL, 
    CONSTRAINT HistorialCalzadoPK PRIMARY KEY (HistorialCalzadoId),
    CONSTRAINT HistorialCalzadoCantidadCK CHECK (HistorialCalzadoCantidad > 0),
    CONSTRAINT HistorialCalzado_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo),
    CONSTRAINT HistorialCalzado_TipoMovimientoFK FOREIGN KEY (TipoMovimientoCodigo) REFERENCES Inventario.TipoMovimiento(TipoMovimientoCodigo),
    CONSTRAINT HistorialCalzado_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID),
    CONSTRAINT HistorialCalzadoFechaCK CHECK (HistorialCalzadoFecha <= GETDATE())
) ON [Primary] 
GO

-- TABLA: Inventario.OrdenProduccion (Depende de Calzado y Usuario)
CREATE TABLE Inventario.OrdenProduccion (
    OrdenID INT IDENTITY(1,1),
    CalzadoCodigo NCHAR(8) NOT NULL,
    CantidadPares INT NOT NULL,
    OrdenFecha DATETIME CONSTRAINT OrdenFechaDF DEFAULT GETDATE(),
    UsuarioID NCHAR(8) NOT NULL,
    OrdenEstado NCHAR(1) CONSTRAINT OrdenEstadoDF DEFAULT 'A', 
    CONSTRAINT OrdenProduccionPK PRIMARY KEY (OrdenID),
    CONSTRAINT OrdenProduccion_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo),
    CONSTRAINT OrdenProduccion_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID),
    CONSTRAINT OrdenCantidadParesCK CHECK (CantidadPares > 0)
) ON [Primary] 
GO

-- TABLA: Inventario.OrdenProduccionDetalle (Depende de OrdenProduccion y Material)
CREATE TABLE Inventario.OrdenProduccionDetalle (
    DetalleID BIGINT IDENTITY(1,1),
    OrdenID INT NOT NULL,
    MaterialCodigo NCHAR(8) NOT NULL,
    CantidadConsumida DECIMAL(10,2) NOT NULL, 
    CONSTRAINT OrdenProduccionDetallePK PRIMARY KEY (DetalleID),
    CONSTRAINT Detalle_OrdenFK FOREIGN KEY (OrdenID) REFERENCES Inventario.OrdenProduccion(OrdenID),
    CONSTRAINT Detalle_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo),
    CONSTRAINT DetalleCantidadConsumidaCK CHECK (CantidadConsumida > 0)
) ON [Primary] 
GO


-- =========================================================================
-- INSERCIÓN DE DATOS INICIALES (ORDEN CRONOLÓGICO SEGURO)
-- =========================================================================

-- Tipos de Usuario
INSERT INTO Seguridad.TipoUsuario (TipoUsuarioCodigo, TipoUsuarioDescription) VALUES
	('ADM01', 'Administrador General'),
	('EMP01', 'Operario / Artesano de Taller') 
GO

-- Usuarios base
INSERT INTO Seguridad.Usuario (UsuarioID, UsuarioNombre, UsuarioLogin, UsuarioPassword, TipoUsuarioCodigo) VALUES
	('USR00001', 'Jorge Luis Admin', 'admin', '123', 'ADM01'),
	('USR00002', 'Maestro Carlos Artesano', 'empleado', '456', 'EMP01') 
GO

-- Catálogo de Insumos / Materiales
INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor) VALUES
	('MAT00001', 'Cuero Badana Marrón Premium', 'Cuero', 18.50, 'Metros', 'Curtiembre San José'),
	('MAT00002', 'Suelas de Caucho Negro N° 42', 'Suelas', 3.00, 'Pares', 'Suelas del Norte'), 
	('MAT00003', 'Hilo Nylon Italiano N° 40', 'Hilos', 12.00, 'Bobinas', 'Hilos Tex S.A.'),
	('MAT00004', 'Pegamento de Contacto Extra XL', 'Pegamentos / Tintes', 1.20, 'Litros', 'Químicos Distribuidora'),
	('MAT00005', 'Ojales de Bronce Pavonado 8mm', 'Herrajes / Ojales', 500.00, 'Unidades', 'Herrajes Perú SRL'),
    ('MAT00006', 'Cuero de Cocodrilo', 'Cuero', 20.00, 'Metros', 'Josue Fernando Solano SAC') 
GO

-- Catálogo Completo de Calzado
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

-- Tipos de Movimientos de Almacén
INSERT INTO Inventario.TipoMovimiento (TipoMovimientoCodigo, TipoMovimientoDescripcion, TipoMovimientoFactor) VALUES
	('E01', 'Entrada por Compra / Abastecimiento', 1),
	('E02', 'Entrada por Production Terminada', 1),
	('S01', 'Salida por Consumo de Taller', -1),
	('S02', 'Salida por Venta de Producto', -1),
    ('S03', 'Salida por Eliminación / Descarte de Taller', -1) 
GO

-- Primeros movimientos del Historial (Ya existen los padres, corre sin errores)
INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialNota) VALUES
	('MAT00001', 'S01', 5.50, 'USR00002', 'Consumo de cuero para lote de botas Ranger'),
	('MAT00004', 'E01', 10.00, 'USR00001', 'Abastecimiento mensual de pegamento de contacto') 
GO

INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID) VALUES
	('ZAP00001', 'E02', 10, 'USR00002'), 
	('ZAP00004', 'S02', 2, 'USR00001') 
GO


-- =========================================================================
-- PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
-- =========================================================================

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

CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ListarActividadReciente
AS
BEGIN
    SET NOCOUNT ON 
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
    ) AS Actividad
    INNER JOIN Seguridad.Usuario U ON Actividad.UsuarioID = U.UsuarioID
    ORDER BY Actividad.Fecha DESC 
END
GO

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
    ORDER BY MaterialNombre ASC 
END
GO

CREATE OR ALTER  PROCEDURE Inventario.USP_Inventario_ListarAlertasBajoStock
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

CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_ListarCalzado
AS
BEGIN
    SET NOCOUNT ON 
    SELECT CalzadoCodigo AS codigo, CalzadoModelo AS modelo, CalzadoTipo AS tipo, CalzadoColor AS color, CalzadoTalla AS talla, CalzadoStock AS stock, CalzadoPrecioVenta AS precio,
        CASE WHEN CalzadoStock < 5 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS bajoStock
    FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    ORDER BY CalzadoModelo ASC, CalzadoTalla DESC 
END
GO

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

CREATE OR ALTER PROCEDURE Inventario.USP_Calzado_ListarParaDropdown
AS
BEGIN
    SET NOCOUNT ON 
    SELECT CalzadoCodigo AS codigo, RTRIM(CalzadoModelo) AS modelo, CalzadoTalla AS talla, RTRIM(CalzadoColor) AS color, CalzadoPrecioVenta AS precio, CalzadoStock AS stock
    FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    ORDER BY CalzadoModelo ASC, CalzadoTalla ASC 
END
GO

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

---- =========================================================================
---- SCRIPT DE LIMPIEZA TOTAL (BORRADO DE TABLAS EN ORDEN SEGURO)
---- =========================================================================

---- 1. Borramos primero las tablas "hijas" finales (las que no tienen dependientes)
--DROP TABLE IF EXISTS Inventario.OrdenProduccionDetalle 
--DROP TABLE IF EXISTS Inventario.OrdenProduccion 
--DROP TABLE IF EXISTS Inventario.HistorialCalzado 
--DROP TABLE IF EXISTS Inventario.HistorialMaterial 

---- 2. Borramos las tablas "padre" intermedias
--DROP TABLE IF EXISTS Inventario.TipoMovimiento 
--DROP TABLE IF EXISTS Inventario.Calzado 
--DROP TABLE IF EXISTS Inventario.Material 
--DROP TABLE IF EXISTS Seguridad.Usuario 

---- 3. Borramos la última tabla base
--DROP TABLE IF EXISTS Seguridad.TipoUsuario 
--GO

--PRINT '¡Base de datos limpia y vacía con éxito! Listo para el nuevo script.'