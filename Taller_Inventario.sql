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
INSERT INTO Inventario.Calzado (CalzadoCodigo, CalzadoModelo, CalzadoTipo, CalzadoColor, CalzadoTalla, CalzadoStock, CalzadoPrecioVenta) VALUES
	('ZAP00001', 'Bota Casual Ranger', 'bota', 'Marrón Cuero', 40, 15, 89.99),
	('ZAP00002', 'Bota Casual Ranger', 'bota', 'Marrón Cuero', 41, 24, 89.99),
	('ZAP00003', 'Mocasín Ejecutivo Premium', 'formal', 'Negro Brillante', 42, 8, 110.00),
	('ZAP00004', 'Zapatilla Urbana Canvas', 'urbano', 'Blanco / Azul', 38, 4, 65.50);
GO

-- =========================================================================
-- 5. INSERCIÓN EN: Inventario.TipoMovimiento
-- =========================================================================
INSERT INTO Inventario.TipoMovimiento (TipoMovimientoCodigo, TipoMovimientoDescripcion, TipoMovimientoFactor) VALUES
	('E01', 'Entrada por Compra / Abastecimiento', 1),
	('E02', 'Entrada por Producción Terminada', 1),
	('S01', 'Salida por Consumo de Taller', -1),
	('S02', 'Salida por Venta de Producto', -1);
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

CREATE or ALTER PROCEDURE Inventario.USP_Dashboard_ListarActividadReciente
AS
BEGIN
    SET NOCOUNT ON

    SELECT TOP 5 
        Actividad.Fecha,
        Actividad.Tipo,
        Actividad.Descripcion,
        Actividad.Cantidad,
        Actividad.Movimiento,
        U.UsuarioNombre AS Encargado
    FROM 
    (
        -- Movimientos de Materiales
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

        -- Movimientos de Calzado
        SELECT 
            HC.HistorialCalzadoFecha AS Fecha,
            'Calzado' AS Tipo,
            C.CalzadoModelo + ' (Talla ' + CONVERT(NVARCHAR(3), C.CalzadoTalla) + ')' AS Descripcion,
            CONVERT(NVARCHAR(20), HC.HistorialCalzadoCantidad) + ' Pares' AS Cantidad,
            TM.TipoMovimientoDescripcion AS Movimiento,
            HC.UsuarioID
        FROM Inventario.HistorialCalzado HC
        INNER JOIN Inventario.Calzado C ON HC.CalzadoCodigo = C.CalzadoCodigo
        INNER JOIN Inventario.TipoMovimiento TM ON HC.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
    ) AS Actividad
    INNER JOIN Seguridad.Usuario U ON Actividad.UsuarioID = U.UsuarioID
    ORDER BY Actividad.Fecha DESC;
END
GO

--EXEC Inventario.USP_Dashboard_ObtenerResumen;
--EXEC Inventario.USP_Dashboard_ListarActividadReciente;


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
    @MaterialProveedor NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @CodigoExistente NCHAR(8)

        SELECT @CodigoExistente = MaterialCodigo 
        FROM Inventario.Material
        WHERE UPPER(RTRIM(MaterialNombre)) = UPPER(RTRIM(@MaterialNombre))
          AND MaterialCategoria = @MaterialCategoria
          AND MaterialEstado = 'A'

        IF @CodigoExistente IS NOT NULL
        BEGIN
            UPDATE Inventario.Material
            SET MaterialCantidad = MaterialCantidad + @MaterialCantidad,
                MaterialProveedor = ISNULL(@MaterialProveedor, MaterialProveedor),
                MaterialMedida = @MaterialMedida
            WHERE MaterialCodigo = @CodigoExistente;

            COMMIT TRANSACTION;

            SELECT @CodigoExistente AS CodigoResultado, 'ACCION_SUMAR' AS Accion;
        END
        ELSE
        BEGIN
           
            DECLARE @NuevoCodigo NCHAR(8);
            DECLARE @MaxId INT;

            SELECT @MaxId = ISNULL(MAX(CAST(SUBSTRING(MaterialCodigo, 4, 5) AS INT)), 0) 
            FROM Inventario.Material;

            SET @NuevoCodigo = 'MAT' + RIGHT('00000' + CAST((@MaxId + 1) AS VARCHAR(5)), 5);

            INSERT INTO Inventario.Material (
                MaterialCodigo, MaterialNombre, MaterialCategoria, 
                MaterialCantidad, MaterialMedida, MaterialProveedor, MaterialEstado
            )
            VALUES (
                @NuevoCodigo, @MaterialNombre, @MaterialCategoria, 
                @MaterialCantidad, @MaterialMedida, @MaterialProveedor, 'A'
            );

            COMMIT TRANSACTION
            SELECT @NuevoCodigo AS CodigoResultado, 'ACCION_CREAR' AS Accion;
        END

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


-- EDITAR MATERIAL 

CREATE PROCEDURE Inventario.USP_Inventario_EditarMaterial
    @MaterialCodigo NCHAR(8),
    @MaterialNombre NVARCHAR(100),
    @MaterialCategoria NVARCHAR(50),
    @MaterialCantidad DECIMAL(10,2),
    @MaterialMedida NVARCHAR(20),
    @MaterialProveedor NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

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

CREATE PROCEDURE Inventario.USP_Inventario_EliminarMaterial
    @MaterialCodigo NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION        
        IF NOT EXISTS (SELECT 1 FROM Inventario.Material WHERE MaterialCodigo = @MaterialCodigo AND MaterialEstado = 'A')
        BEGIN
            RAISERROR('El material que intenta eliminar no existe o ya se encuentra inactivo.', 16, 1)
        END

        UPDATE Inventario.Material
        SET MaterialEstado = 'E'
        WHERE MaterialCodigo = @MaterialCodigo

        COMMIT TRANSACTION;

        SELECT 'EXITO' AS Resultado, 'Material eliminado correctamente.' AS Mensaje

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO


CREATE PROCEDURE Inventario.USP_Inventario_ListarCalzado
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
    ORDER BY CalzadoModelo ASC, CalzadoTalla DESC;
END
GO

--EXEC Inventario.USP_Inventario_ListarCalzado;
