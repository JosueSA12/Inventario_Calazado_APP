-- =========================================================================
-- CREACIÓN DE LA BASE DE DATOS
-- =========================================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DB_TallerCalzado')
    DROP DATABASE DB_TallerCalzado;
GO

CREATE DATABASE DB_TallerCalzado
ON PRIMARY 
( 
    NAME = TallerCalzado_Data,
    FILENAME = 'C:\DB_TallerCalzado\TallerCalzadoData.mdf',
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB 
)
LOG ON
( 
    NAME = TallerCalzado_Log,
    FILENAME = 'C:\DB_TallerCalzado\TallerCalzadoLog.ldf',
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 2MB 
)
GO

-- =========================================================================
-- CREACIÓN DE ESQUEMAS
-- =========================================================================
USE DB_TallerCalzado;
GO

CREATE SCHEMA Seguridad;
GO

CREATE SCHEMA Inventario;
GO

-- =========================================================================
-- CREACIÓN DE TABLAS
-- =========================================================================

-- TABLA: Seguridad.TipoUsuario
Create table Seguridad.TipoUsuario
	(
	TipoUsuarioCodigo nchar(5),
	TipoUsuarioDescripcion nvarchar(50) not null,
	TipoUsuarioEstado nchar(1) constraint TipoUsuarioEstadoDF Default 'A',
	constraint TipoUsuarioPK Primary key (TipoUsuarioCodigo),
	constraint TipoUsuarioDescripcionUQ Unique (TipoUsuarioDescripcion),
	constraint TipoUsuarioEstadoCK Check (TipoUsuarioEstado = 'A' or TipoUsuarioEstado = 'E')
	)
	on [Primary]
go

-- TABLA: Seguridad.Usuario (Login)
Create table Seguridad.Usuario
	(
	UsuarioID nchar(8),
	UsuarioNombre nvarchar(100) not null,
	UsuarioLogin nvarchar(20) not null,
	UsuarioPassword nvarchar(50) not null,
	TipoUsuarioCodigo nchar(5) not null,
	UsuarioFechaCreacion Date constraint UsuarioFechaCreacionDF Default GetDate(),
	UsuarioEstado nchar(1) constraint UsuarioEstadoDF Default 'A',
	constraint UsuarioPK Primary key (UsuarioID),
	constraint UsuarioLoginUQ Unique (UsuarioLogin),
	constraint UsuarioTipoUsuarioFK Foreign key (TipoUsuarioCodigo) 
		references Seguridad.TipoUsuario(TipoUsuarioCodigo),
	constraint UsuarioFechaCreacionCK check (UsuarioFechaCreacion <= GetDate()),
	constraint UsuarioEstadoCK Check (UsuarioEstado = 'A' or UsuarioEstado = 'E')
	)
	on [Primary]
go

-- TABLA: Inventario.Material (Insumos del taller)
Create table Inventario.Material
	(
	MaterialCodigo nchar(8),
	MaterialNombre nvarchar(100) not null,
	MaterialCategoria nvarchar(50) not null,
	MaterialCantidad Decimal(10,2) constraint MaterialCantidadDF Default 0.00,
	MaterialMedida nvarchar(20) not null,
	MaterialProveedor nvarchar(100),
	MaterialEstado nchar(1) constraint MaterialEstadoDF Default 'A',
	constraint MaterialPK Primary key (MaterialCodigo),
	constraint MaterialCantidadCK Check (MaterialCantidad >= 0),
	constraint MaterialCategoriaCK Check 
		(MaterialCategoria in ('Cuero', 'Suelas', 'Hilos', 'Pegamentos / Tintes', 'Herrajes / Ojales')),
	constraint MaterialEstadoCK Check (MaterialEstado = 'A' or MaterialEstado = 'E')
	)
	on [Primary]
go

-- TABLA: Inventario.Calzado (Productos terminados)
Create table Inventario.Calzado
	(
	CalzadoCodigo nchar(8),
	CalzadoModelo nvarchar(100) not null,
	CalzadoTipo nvarchar(30) not null,
	CalzadoColor nvarchar(50) not null,
	CalzadoTalla int not null,
	CalzadoStock int constraint CalzadoStockDF Default 0,
	CalzadoPrecioVenta Decimal(10,2) not null,
	CalzadoEstado nchar(1) constraint CalzadoEstadoDF Default 'A',
	constraint CalzadoPK Primary key (CalzadoCodigo),
	constraint CalzadoStockCK Check (CalzadoStock >= 0),
	constraint CalzadoPrecioCK Check (CalzadoPrecioVenta > 0),
	constraint CalzadoTallaCK Check (CalzadoTalla between 25 and 45),
	constraint CalzadoEstadoCK Check (CalzadoEstado = 'A' or CalzadoEstado = 'E')
	)
	on [Primary]
go


-- TABLA: Inventario.TipoMovimiento
Create table Inventario.TipoMovimiento
	(
	TipoMovimientoCodigo nchar(3),
	TipoMovimientoDescripcion nvarchar(50) not null, 
	TipoMovimientoFactor int not null, -- 1 para entradas, -1 para salidas
	TipoMovimientoEstado nchar(1) constraint TipoMovimientoEstadoDF Default 'A',
	constraint TipoMovimientoPK Primary key (TipoMovimientoCodigo),
	constraint TipoMovimientoDescripcionUQ Unique (TipoMovimientoDescripcion),
	constraint TipoMovimientoFactorCK Check (TipoMovimientoFactor = 1 or TipoMovimientoFactor = -1),
	constraint TipoMovimientoEstadoCK Check (TipoMovimientoEstado = 'A' or TipoMovimientoEstado = 'E')
	)
	on [Primary]
go

-- TABLA: Inventario.HistorialMaterial (Historial de uso de insumos)
Create table Inventario.HistorialMaterial
	(
	HistorialMaterialId bigint identity(1,1),
	MaterialCodigo nchar(8) not null,
	TipoMovimientoCodigo nchar(3) not null,
	HistorialMaterialCantidad Decimal(10,2) not null,
	HistorialMaterialFecha Date constraint HistorialMaterialFechaDF Default GetDate(),
	UsuarioID nchar(8) not null, 
	HistorialMaterialNota nvarchar(255), 
	constraint HistorialMaterialPK Primary key (HistorialMaterialId),
	constraint HistorialMaterialCantidadCK Check (HistorialMaterialCantidad > 0),
	constraint HistorialMaterial_MaterialFK Foreign key (MaterialCodigo) 
		references Inventario.Material(MaterialCodigo),
	constraint HistorialMaterial_TipoMovimientoFK Foreign key (TipoMovimientoCodigo) 
		references Inventario.TipoMovimiento(TipoMovimientoCodigo),
	constraint HistorialMaterial_UsuarioFK Foreign key (UsuarioID) 
		references Seguridad.Usuario(UsuarioID),
	constraint HistorialMaterialFechaCK check (HistorialMaterialFecha <= GetDate())
	)
	on [Primary]
go

-- TABLA: Inventario.HistorialCalzado (Historial de producción y ventas)
Create table Inventario.HistorialCalzado
	(
	HistorialCalzadoId bigint identity(1,1),
	CalzadoCodigo nchar(8) not null,
	TipoMovimientoCodigo nchar(3) not null,
	HistorialCalzadoCantidad int not null,
	HistorialCalzadoFecha Date constraint HistorialCalzadoFechaDF Default GetDate(),
	UsuarioID nchar(8) not null, 
	constraint HistorialCalzadoPK Primary key (HistorialCalzadoId),
	constraint HistorialCalzadoCantidadCK Check (HistorialCalzadoCantidad > 0),
	constraint HistorialCalzado_CalzadoFK Foreign key (CalzadoCodigo) 
		references Inventario.Calzado(CalzadoCodigo),
	constraint HistorialCalzado_TipoMovimientoFK Foreign key (TipoMovimientoCodigo) 
		references Inventario.TipoMovimiento(TipoMovimientoCodigo),
	constraint HistorialCalzado_UsuarioFK Foreign key (UsuarioID) 
		references Seguridad.Usuario(UsuarioID),
	constraint HistorialCalzadoFechaCK check (HistorialCalzadoFecha <= GetDate())
	)
	on [Primary]
go

-- =========================================================================
-- INSERCIÓN DE DATOS 
-- =========================================================================
INSERT INTO Seguridad.TipoUsuario (TipoUsuarioCodigo, TipoUsuarioDescripcion) VALUES
	('ADM01', 'Administrador General'),
	('EMP01', 'Operario / Artesano de Taller');
GO

-- =========================================================================
-- 2. INSERCIÓN EN: Seguridad.Usuario (Credenciales solicitadas)
-- =========================================================================
INSERT INTO Seguridad.Usuario (UsuarioID, UsuarioNombre, UsuarioLogin, UsuarioPassword, TipoUsuarioCodigo) VALUES
	('USR00001', 'Jorge Luis Admin', 'admin', '123', 'ADM01'),
	('USR00002', 'Maestro Carlos Artesano', 'empleado', '456', 'EMP01');
GO

-- =========================================================================
-- 3. INSERCIÓN EN: Inventario.Material (Insumos con stock normal y bajo stock)
-- =========================================================================
-- NOTA: Mantenemos las categorías idénticas al Check Constraint de tu tabla
INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor) VALUES
	('MAT00001', 'Cuero Badana Marrón Premium', 'Cuero', 18.50, 'Metros', 'Curtiembre San José'),
	('MAT00002', 'Suelas de Caucho Negro N° 42', 'Suelas', 3.00, 'Pares', 'Suelas del Norte'), 
	('MAT00003', 'Hilo Nylon Italiano N° 40', 'Hilos', 12.00, 'Bobinas', 'Hilos Tex S.A.'),
	('MAT00004', 'Pegamento de Contacto Extra XL', 'Pegamentos / Tintes', 1.20, 'Litros', 'Químicos Distribuidora'),
	('MAT00005', 'Ojales de Bronce Pavonado 8mm', 'Herrajes / Ojales', 500.00, 'Unidades', 'Herrajes Perú SRL');
GO

INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor) VALUES
	('MAT00006', 'Cuerdo de Cocodrillo', 'Cuero', 20, 'Metros', 'Josue Fernando Solano SAC')
	
GO

--INSERT INTO Inventario.Material (MaterialCodigo, MaterialNombre, MaterialCategoria, MaterialCantidad, MaterialMedida, MaterialProveedor) VALUES
--	('MAT00007', 'Cuero Gamuza Azul Marino', 'Cuero', 14.20, 'Metros', 'Curtiembre San José'),
--	('MAT00008', 'Suelas de Poliuretano Confort N° 38', 'Suelas', 2.00, 'Pares', 'Suelas del Norte'), 
--	('MAT00009', 'Suelas de Cuero Genuino (Crupon)', 'Suelas', 25.00, 'Pares', 'Suelas Pro'),
--	('MAT00010', 'Hilo de Algodón Encerado Negro', 'Hilos', 4.50, 'Bobinas', 'Hilos Tex S.A.'), 
--	('MAT00011', 'Tinte Base Alcohol Marrón Oscuro', 'Pegamentos / Tintes', 6.00, 'Litros', 'Químicos Distribuidora'),
--	('MAT00012', 'Solución Limpiadora Pre-pegado', 'Pegamentos / Tintes', 0.80, 'Litros', 'Químicos del Norte'),
--	('MAT00013', 'Hebillas Metálicas Pavonadas 15mm', 'Herrajes / Ojales', 120.00, 'Unidades', 'Herrajes Perú SRL'),
--	('MAT00014', 'Cremalleras de Cobre Fijas 20cm', 'Herrajes / Ojales', 35.00, 'Unidades', 'Importaciones Maquinarias SAC'),
--	('MAT00015', 'Cuero Charol Negro Espejo', 'Cuero', 8.00, 'Metros', 'Josue Fernando Solano SAC'),
--	('MAT00016', 'Pegamento de Poliuretano (P.U.)', 'Pegamentos / Tintes', 15.00, 'Litros', 'Químicos Distribuidora');
--GO



-- =========================================================================
-- 4. INSERCIÓN EN: Inventario.Calzado (Modelos y tallas para el catálogo)
-- =========================================================================
--INSERT INTO Inventario.Calzado (CalzadoCodigo, CalzadoModelo, CalzadoTipo, CalzadoColor, CalzadoTalla, CalzadoStock, CalzadoPrecioVenta) VALUES
--	('ZAP00001', 'Bota Casual Ranger', 'bota', 'Marron ', 40, 15, 89.99),
--	('ZAP00002', 'Bota Casual Ranger', 'bota', 'Marron ', 41, 24, 89.99),
--	('ZAP00003', 'Mocasín Ejecutivo Premium', 'formal', 'Negro Brillante', 42, 8, 110.00),
--	('ZAP00004', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 38, 4, 65.50);
--GO

-- =========================================================================
-- 5. INSERCIÓN EN: Inventario.TipoMovimiento
-- =========================================================================
INSERT INTO Inventario.TipoMovimiento (TipoMovimientoCodigo, TipoMovimientoDescripcion, TipoMovimientoFactor) VALUES
	('E01', 'Entrada por Compra / Abastecimiento', 1),
	('E02', 'Entrada por Producción Terminada', 1),
	('S01', 'Salida por Consumo de Taller', -1),
	('S02', 'Salida por Venta de Producto', -1);
GO

IF NOT EXISTS (SELECT 1 FROM Inventario.TipoMovimiento WHERE TipoMovimientoCodigo = 'S03')
BEGIN
    INSERT INTO Inventario.TipoMovimiento (TipoMovimientoCodigo, TipoMovimientoDescripcion, TipoMovimientoFactor)
    VALUES ('S03', 'Salida por Eliminación / Descarte de Taller', -1);
END
GO
-- =========================================================================
-- 6. INSERCIÓN EN: Inventario.HistorialMaterial (Actividad reciente)
-- =========================================================================
INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialNota) VALUES
	('MAT00001', 'S01', 5.50, 'USR00002', 'Consumo de cuero para lote de botas Ranger'),
	('MAT00004', 'E01', 10.00, 'USR00001', 'Abastecimiento mensual de pegamento de contacto');
GO

-- =========================================================================
-- 7. INSERCIÓN EN: Inventario.HistorialCalzado (Actividad reciente)
-- =========================================================================
INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID) VALUES
	('ZAP00001', 'E02', 10, 'USR00002'), -- El operario metió 10 botas terminadas
	('ZAP00004', 'S02', 2, 'USR00001');  -- El admin vendió 2 zapatillas urbanas
GO




-- =======================
-- STORE PROCEDUREs
-- ======================
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ObtenerResumen
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @TotalModelos INT;
    DECLARE @TotalMateriales INT;
    DECLARE @AlertasCriticas INT;

    -- Contar cuántos modelos de calzado distintos tenemos registrados
    SELECT @TotalModelos = COUNT(DISTINCT CalzadoModelo) 
    FROM Inventario.Calzado 
    WHERE CalzadoEstado = 'A'

    -- Contar cuántos materiales diferentes hay en el taller
    SELECT @TotalMateriales = COUNT(*) 
    FROM Inventario.Material 
    WHERE MaterialEstado = 'A'

    -- Contar materiales con bajo stock 
    SELECT @AlertasCriticas = COUNT(*) 
    FROM Inventario.Material 
    WHERE MaterialCantidad < 5.00 AND MaterialEstado = 'A'

    SELECT 
        ISNULL(@TotalModelos, 0) AS TotalModelos,
        ISNULL(@TotalMateriales, 0) AS TotalMateriales,
        ISNULL(@AlertasCriticas, 0) AS AlertasCriticas;
END
GO


--Mostrar Actividad Reciente
-- Eliminar restricciones antiguas
ALTER TABLE Inventario.HistorialMaterial DROP CONSTRAINT HistorialMaterialFechaCK;
ALTER TABLE Inventario.HistorialMaterial DROP CONSTRAINT HistorialMaterialFechaDF;

--Cambiar el tipo de dato a DATETIME
ALTER TABLE Inventario.HistorialMaterial ALTER COLUMN HistorialMaterialFecha DATETIME;

ALTER TABLE Inventario.HistorialMaterial ADD CONSTRAINT HistorialMaterialFechaDF DEFAULT GETDATE() FOR HistorialMaterialFecha;
ALTER TABLE Inventario.HistorialMaterial ADD CONSTRAINT HistorialMaterialFechaCK CHECK (HistorialMaterialFecha <= GETDATE());
GO

-- Eliminar restricciones antiguas
ALTER TABLE Inventario.HistorialCalzado DROP CONSTRAINT HistorialCalzadoFechaCK;
ALTER TABLE Inventario.HistorialCalzado DROP CONSTRAINT HistorialCalzadoFechaDF;

-- Cambiar el tipo de dato a DATETIME
ALTER TABLE Inventario.HistorialCalzado ALTER COLUMN HistorialCalzadoFecha DATETIME;

-- Volver a crear las restricciones para DATETIME
ALTER TABLE Inventario.HistorialCalzado ADD CONSTRAINT HistorialCalzadoFechaDF DEFAULT GETDATE() FOR HistorialCalzadoFecha;
ALTER TABLE Inventario.HistorialCalzado ADD CONSTRAINT HistorialCalzadoFechaCK CHECK (HistorialCalzadoFecha <= GETDATE());
GO
-- =========================================================================
--  STORED PROCEDURE
-- =========================================================================

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
        --MOVIMIENTOS DE MATERIALES
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

        --MOVIMIENTOS DE CALZADO 
        SELECT 
            HC.HistorialCalzadoFecha AS Fecha,
            'Calzado' AS Tipo,
            C.CalzadoModelo + ' (' + RTRIM(C.CalzadoColor) + ', Talla ' + CONVERT(NVARCHAR(3), C.CalzadoTalla) + ')' AS Descripcion,
            
            -- LÓGICA: Si es una salida por venta
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

--EXEC Inventario.USP_Dashboard_ObtenerResumen;
EXEC Inventario.USP_Dashboard_ListarActividadReciente
go


--Mostrar INVENTARIO DE MATERIALES

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

--EXEC Inventario.USP_Inventario_ListarMateriales;


--Mostrar Materiales con bajo stock 

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
    WHERE MaterialEstado = 'A'
      AND MaterialCantidad < 5.0 
    ORDER BY MaterialCantidad ASC
END
GO

--EXEC Inventario.USP_Inventario_ListarAlertasBajoStock

--INSERTAR MATERIAL 

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

        -- Buscar si el material existe
        SELECT @CodigoExistente = MaterialCodigo 
        FROM Inventario.Material
        WHERE UPPER(RTRIM(MaterialNombre)) = UPPER(RTRIM(@MaterialNombre))
          AND MaterialCategoria = @MaterialCategoria
          AND MaterialEstado = 'A'

        IF @CodigoExistente IS NOT NULL
        BEGIN
            -- CASO 1: SI EXISTE, SUMAMOS STOCK
            UPDATE Inventario.Material
            SET MaterialCantidad = MaterialCantidad + @MaterialCantidad,
                MaterialProveedor = ISNULL(@MaterialProveedor, MaterialProveedor),
                MaterialMedida = @MaterialMedida
            WHERE MaterialCodigo = @CodigoExistente;

            SET @CodigoFinal = @CodigoExistente;
            SET @AccionRealizada = 'ACCION_SUMAR';
        END
        ELSE
        BEGIN
            -- CASO 2: ES NUEVO, GENERAMOS CÓDIGO E INSERTAMOS
            DECLARE @MaxId INT;
            SELECT @MaxId = ISNULL(MAX(CAST(SUBSTRING(MaterialCodigo, 4, 5) AS INT)), 0) 
            FROM Inventario.Material;

            SET @CodigoFinal = 'MAT' + RIGHT('00000' + CAST((@MaxId + 1) AS VARCHAR(5)), 5);

            INSERT INTO Inventario.Material (
                MaterialCodigo, MaterialNombre, MaterialCategoria, 
                MaterialCantidad, MaterialMedida, MaterialProveedor, MaterialEstado
            )
            VALUES (
                @CodigoFinal, @MaterialNombre, @MaterialCategoria, 
                @MaterialCantidad, @MaterialMedida, @MaterialProveedor, 'A'
            );

            SET @AccionRealizada = 'ACCION_CREAR';
        END

        -- =========================================================================
        -- REGISTRO EN EL HISTORIAL DE MOVIMIENTOS
        -- =========================================================================
        INSERT INTO Inventario.HistorialMaterial (
            MaterialCodigo, 
            TipoMovimientoCodigo, 
            HistorialMaterialCantidad, 
            UsuarioID, 
            HistorialMaterialFecha,
            HistorialMaterialNota
        )
        VALUES (
            @CodigoFinal,
            'E01',
            @MaterialCantidad,
            @UsuarioID,
            GETDATE(),
            CASE 
                WHEN @AccionRealizada = 'ACCION_CREAR' THEN N'Ingreso inicial de nuevo material al taller.'
                ELSE N'Abastecimiento de stock / Compra adicional.'
            END
        )

        COMMIT TRANSACTION;

        -- Retornamos la información 
        SELECT @CodigoFinal AS CodigoResultado, @AccionRealizada AS Accion;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

---- PRUEBA 1: Insertar un insumo nuevo
--EXEC Inventario.USP_Inventario_InsertarMaterial 
--    @MaterialNombre = 'Broches de Presión Niquelados',
--    @MaterialCategoria = 'Herrajes / Ojales',
--    @MaterialCantidad = 100.00,
--    @MaterialMedida = 'Unidades',
--    @MaterialProveedor = 'Herrajes Perú SRL';

---- PRUEBA 2: Ingresar el mismo insumo (Debería sumar al stock existente)
--EXEC Inventario.USP_Inventario_InsertarMaterial 
--    @MaterialNombre = 'Broches de Presión Niquelados',
--    @MaterialCategoria = 'Herrajes / Ojales',
--    @MaterialCantidad = 50.00,
--    @MaterialMedida = 'Unidades',
--    @MaterialProveedor = 'Importaciones Metalicas SAC';

--    -- PRUEBA 3: Ver el estado real del inventario afectado
--SELECT 
--    MaterialCodigo, 
--    MaterialNombre, 
--    MaterialCategoria, 
--    MaterialCantidad, 
--    MaterialMedida, 
--    MaterialProveedor
--FROM Inventario.Material
--WHERE MaterialCategoria = 'Herrajes / Ojales';

--lISTAR MATERIALES 
CREATE OR ALTER PROCEDURE Inventario.USP_Material_ListarParaDropdown
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        
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

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO




-- EDITAR MATERIAL 
CREATE or alter PROCEDURE Inventario.USP_Inventario_EditarMaterial
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
        BEGIN
            RAISERROR('El material que intenta editar no existe o está inactivo.', 16, 1);
        END

        IF EXISTS (
            SELECT 1 FROM Inventario.Material 
            WHERE UPPER(RTRIM(MaterialNombre)) = UPPER(RTRIM(@MaterialNombre))
              AND MaterialCategoria = @MaterialCategoria
              AND MaterialCodigo <> @MaterialCodigo
              AND MaterialEstado = 'A'
        )
        BEGIN
            RAISERROR('Ya existe otro material registrado con ese mismo nombre y categoría.', 16, 1);
        END

        UPDATE Inventario.Material
        SET MaterialNombre = @MaterialNombre,
            MaterialCategoria = @MaterialCategoria,
            MaterialCantidad = @MaterialCantidad,
            MaterialMedida = @MaterialMedida,
            MaterialProveedor = ISNULL(@MaterialProveedor, MaterialProveedor)
        WHERE MaterialCodigo = @MaterialCodigo;

        COMMIT TRANSACTION;
        
        SELECT 'EXITO' AS Resultado, 'Material actualizado correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO


-- BORRAR MATERIAL
CREATE OR ALTER PROCEDURE Inventario.USP_Inventario_EliminarMaterial
    @MaterialCodigo NCHAR(8),
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Inventario.Material WHERE MaterialCodigo = @MaterialCodigo AND MaterialEstado = 'A')
        BEGIN
            RAISERROR('El material que intenta eliminar no existe o ya se encuentra inactivo.', 16, 1);
        END

        -- Cantidad que queda en stock antes de vaciarla
        DECLARE @CantidadActual DECIMAL(10,2);
        SELECT @CantidadActual = MaterialCantidad 
        FROM Inventario.Material 
        WHERE MaterialCodigo = @MaterialCodigo;

        -- Cambiamos estado a 'E'
        UPDATE Inventario.Material
        SET MaterialEstado = 'E',
            MaterialCantidad = 0.00
        WHERE MaterialCodigo = @MaterialCodigo;

        INSERT INTO Inventario.HistorialMaterial (
            MaterialCodigo, 
            TipoMovimientoCodigo, 
            HistorialMaterialCantidad, 
            UsuarioID, 
            HistorialMaterialFecha,
            HistorialMaterialNota
        )
        VALUES (
            @MaterialCodigo,
            'S03', 
            @CantidadActual,
            @UsuarioID,
            GETDATE(),
            N'Material eliminado del taller.'
        )

        COMMIT TRANSACTION;

        SELECT 'EXITO' AS Resultado, 'Material eliminado correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- LISTAR EL CALZADO 
CREATE or alter PROCEDURE Inventario.USP_Inventario_ListarCalzado
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        CalzadoCodigo AS codigo,
        CalzadoModelo AS modelo,
        CalzadoTipo AS tipo,
        CalzadoColor AS color,
        CalzadoTalla AS talla,
        CalzadoStock AS stock,
        CalzadoPrecioVenta AS precio,
        CASE 
            WHEN CalzadoStock < 5 THEN CAST(1 AS BIT) 
            ELSE CAST(0 AS BIT) 
        END AS bajoStock
    FROM Inventario.Calzado
    WHERE CalzadoEstado = 'A'
    ORDER BY CalzadoModelo ASC, CalzadoTalla DESC
END
GO

--EXEC Inventario.USP_Inventario_ListarCalzado;

--INSERT INTO Inventario.Calzado 
--(CalzadoCodigo, CalzadoModelo, CalzadoTipo, CalzadoColor, CalzadoTalla, CalzadoStock, CalzadoPrecioVenta) 
--VALUES	
--('ZAP00001', 'Bota Casual Ranger', 'bota', 'Marrón', 40, 15, 89.99),
--('ZAP00002', 'Bota Casual Ranger', 'bota', 'Marrón', 41, 24, 89.99),
--('ZAP00003', 'Bota Casual Ranger', 'bota', 'Negro', 39, 8, 89.99),
--('ZAP00004', 'Bota Casual Ranger', 'bota', 'Negro', 42, 12, 89.99),
--('ZAP00005', 'Mocasín Ejecutivo Premium', 'formal', 'Negro', 42, 8, 110.00),
--('ZAP00006', 'Mocasín Ejecutivo Premium', 'formal', 'Negro', 40, 5, 110.00),
--('ZAP00007', 'Mocasín Ejecutivo Premium', 'formal', 'Marrón', 41, 6, 115.00),
--('ZAP00008', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 38, 4, 65.50),
--('ZAP00009', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco', 39, 10, 65.50),
--('ZAP00010', 'Zapatilla Urbana Canvas', 'urbano', 'Negro', 40, 15, 65.50),
--('ZAP00011', 'Bota Militar', 'bota', 'Negro', 40, 15, 125.00),
--('ZAP00012', 'Bota Militar', 'bota', 'Marrón', 41, 3, 125.00),
--('ZAP00013', 'Stiletto Gala Leather', 'tacos', 'Negro', 36, 12, 140.00),
--('ZAP00014', 'Stiletto Gala Leather', 'tacos', 'Blanco', 37, 2, 140.00),
--('ZAP00015', 'Sandalia Verano Confort', 'sandalia', 'Marrón', 37, 20, 45.00),
--('ZAP00016', 'Sandalia Verano Confort', 'sandalia', 'Blanco', 38, 14, 45.00),
--('ZAP00017', 'Zapato Derby Clásico', 'formal', 'Negro', 41, 10, 95.00),
--('ZAP00018', 'Zapato Derby Clásico', 'formal', 'Marrón', 42, 3, 98.00),
--('ZAP00019', 'Zapatilla Runner Pro', 'deportivo', 'Gris', 41, 18, 135.00),
--('ZAP00020', 'Zapatilla Runner Pro', 'deportivo', 'Azul', 42, 7, 135.00),
--('ZAP00021', 'Botín Chelsea Nobuck', 'bota', 'Marrón', 40, 9, 150.00),
--('ZAP00022', 'Botín Chelsea Nobuck', 'bota', 'Negro', 41, 11, 150.00),
--('ZAP00023', 'Mocasín Driver Casual', 'urbano', 'Azul', 40, 14, 79.90),
--('ZAP00024', 'Mocasín Driver Casual', 'urbano', 'Marrón', 39, 6, 79.90);
--GO

--- SP para registrar Registrar Venta: 

CREATE OR ALTER PROCEDURE Inventario.USP_Calzado_RegistrarVenta
    @CalzadoCodigo NCHAR(8),
    @CantidadAVender INT,
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY        
        BEGIN TRANSACTION;
        DECLARE @StockActual INT
        DECLARE @Estado NCHAR(1)
        SELECT @StockActual = CalzadoStock, @Estado = CalzadoEstado
        FROM Inventario.Calzado WITH (UPDLOCK)
        WHERE CalzadoCodigo = @CalzadoCodigo;

        IF @StockActual IS NULL OR @Estado <> 'A'
        BEGIN
            RAISERROR('El calzado especificado no existe o está inactivo en el catálogo.', 16, 1)
        END

        IF @StockActual < @CantidadAVender
        BEGIN
            DECLARE @ErrorStock NVARCHAR(255)
            SET @ErrorStock = N'Stock insuficiente para realizar la venta. Stock disponible: ' + CAST(@StockActual AS NVARCHAR(10)) + N' pares.';
            RAISERROR(@ErrorStock, 16, 1)
        END

        --Descontar el stock del calzado
        UPDATE Inventario.Calzado
        SET CalzadoStock = CalzadoStock - @CantidadAVender
        WHERE CalzadoCodigo = @CalzadoCodigo;

        -- Registrar en el historial de calzado
        INSERT INTO Inventario.HistorialCalzado (
            CalzadoCodigo, 
            TipoMovimientoCodigo, 
            HistorialCalzadoCantidad, 
            UsuarioID,
            HistorialCalzadoFecha
        )
        VALUES (
            @CalzadoCodigo, 
            'S02',
            @CantidadAVender, 
            @UsuarioID,
            GETDATE()
        );

        COMMIT TRANSACTION
        SELECT 
            'EXITO' AS Resultado, 
            N'Venta registrada correctamente. Se descontaron ' + CAST(@CantidadAVender AS NVARCHAR(10)) + N' pares.' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        -- Capturamos el error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO


--EXEC Inventario.USP_Calzado_RegistrarVenta 
--    @CalzadoCodigo = 'ZAP00003', 
--    @CantidadAVender = 2, 
--    @UsuarioID = 'USR00001'

--EXEC Inventario.USP_Calzado_RegistrarVenta 
--    @CalzadoCodigo = 'ZAP00001', 
--    @CantidadAVender = 500, 
--    @UsuarioID = 'USR00001'


-- SP PARA LISTAR LOS ZAPATOS PARA LA VENTA

CREATE OR ALTER PROCEDURE Inventario.USP_Calzado_ListarParaDropdown
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        
        SELECT 
            CalzadoCodigo AS codigo,
            RTRIM(CalzadoModelo) AS modelo,
            CalzadoTalla AS talla,
            RTRIM(CalzadoColor) AS color,
            CalzadoPrecioVenta AS precio,
            CalzadoStock AS stock
        FROM Inventario.Calzado
        WHERE CalzadoEstado = 'A'
        ORDER BY CalzadoModelo ASC, CalzadoTalla ASC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

---Creamos tablas para poder REALIZAR LA ACCIÓN DE NUEVO CALZADO

--Tabla Fabricación general
CREATE TABLE Inventario.OrdenProduccion (
    OrdenID INT IDENTITY(1,1),
    CalzadoCodigo NCHAR(8) NOT NULL,
    CantidadPares INT NOT NULL,
    OrdenFecha DATETIME CONSTRAINT OrdenFechaDF DEFAULT GETDATE(),
    UsuarioID NCHAR(8) NOT NULL,
    OrdenEstado NCHAR(1) CONSTRAINT OrdenEstadoDF DEFAULT 'A', -- 'A' Activo, 'E' Anulado
    CONSTRAINT OrdenProduccionPK PRIMARY KEY (OrdenID),
    CONSTRAINT OrdenProduccion_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo),
    CONSTRAINT OrdenProduccion_UsuarioFK FOREIGN KEY (UsuarioID) REFERENCES Seguridad.Usuario(UsuarioID),
    CONSTRAINT OrdenCantidadParesCK CHECK (CantidadPares > 0)
) ON [Primary];
GO

-- Tabla Detalle
CREATE TABLE Inventario.OrdenProduccionDetalle (
    DetalleID BIGINT IDENTITY(1,1),
    OrdenID INT NOT NULL,
    MaterialCodigo NCHAR(8) NOT NULL,
    CantidadConsumida DECIMAL(10,2) NOT NULL, 
    CONSTRAINT OrdenProduccionDetallePK PRIMARY KEY (DetalleID),
    CONSTRAINT Detalle_OrdenFK FOREIGN KEY (OrdenID) REFERENCES Inventario.OrdenProduccion(OrdenID),
    CONSTRAINT Detalle_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo),
    CONSTRAINT DetalleCantidadConsumidaCK CHECK (CantidadConsumida > 0)
) ON [Primary];
GO

-- SP para PODER REGISTRAR EL CALZADO NUEVO

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

        -- Insertar el detalle de materiales consumidos
        INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
        SELECT 
            @NuevaOrdenID,
            j.codigo,
            (j.cantidadPorPar * @CantidadPares)
        FROM OPENJSON(@MaterialesJSON)
        WITH (
            codigo NCHAR(8) '$.codigo',
            cantidadPorPar DECIMAL(10,2) '$.cantidadPorPar'
        ) AS j

        --DESCONTAR EL STOCK DE LOS MATERIALES
        UPDATE m
        SET m.MaterialCantidad = m.MaterialCantidad - (j.cantidadPorPar * @CantidadPares)
        FROM Inventario.Material m
        INNER JOIN OPENJSON(@MaterialesJSON)
        WITH (
            codigo NCHAR(8) '$.codigo',
            cantidadPorPar DECIMAL(10,2) '$.cantidadPorPar'
        ) AS j ON m.MaterialCodigo = j.codigo

        --AUMENTAR EL STOCK DEL CALZADO TERMINADO 
        UPDATE Inventario.Calzado
        SET CalzadoStock = CalzadoStock + @CantidadPares
        WHERE CalzadoCodigo = @CalzadoCodigo

        --HISTORIAL CALZADO: Tipo 'E02' (Entrada por Producción Terminada según tu tabla TipoMovimiento)
        INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID, HistorialCalzadoFecha)
        VALUES (@CalzadoCodigo, 'E02', @CantidadPares, @UsuarioID, GETDATE());

        --HISTORIAL MATERIALES: Tipo 'S01' (Salida por Consumo de Taller según tu tabla TipoMovimiento)
        INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialFecha, HistorialMaterialNota)
        SELECT 
            j.codigo,
            'S01',
            (j.cantidadPorPar * @CantidadPares),
            @UsuarioID,
            GETDATE(),
            N'Consumo por Producción de Calzado - Orden #' + CAST(@NuevaOrdenID AS NVARCHAR(10))
        FROM OPENJSON(@MaterialesJSON)
        WITH (
            codigo NCHAR(8) '$.codigo',
            cantidadPorPar DECIMAL(10,2) '$.cantidadPorPar'
        ) AS j

        COMMIT TRANSACTION
        SELECT 'EXITO' AS Resultado, N'Producción e historiales guardados con éxito. Orden #' + CAST(@NuevaOrdenID AS NVARCHAR(10)) AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO



