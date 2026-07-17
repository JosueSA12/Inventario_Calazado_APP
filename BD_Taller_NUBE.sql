
USE [db_acbcc3_dbtaller] 
GO

-- =========================================================================
-- CREACIÓN DE SCHEMAS
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

-- ====================================
-- 2. TABLAS
-- ====================================

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

-- 2.6 Inventario.CalzadoMaterial
CREATE TABLE Inventario.CalzadoMaterial (
    CalzadoMaterialID BIGINT IDENTITY(1,1) PRIMARY KEY,
    CalzadoCodigo NCHAR(8) NOT NULL,
    MaterialCodigo NCHAR(8) NOT NULL,
    CantidadPorPar DECIMAL(10,2) NOT NULL CHECK (CantidadPorPar > 0),
    FechaCreacion DATETIME DEFAULT GETDATE(),
    UsuarioCreacion NCHAR(8) NOT NULL,
    CONSTRAINT CalzadoMaterial_CalzadoFK FOREIGN KEY (CalzadoCodigo) REFERENCES Inventario.Calzado(CalzadoCodigo),
    CONSTRAINT CalzadoMaterial_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo),
    CONSTRAINT CalzadoMaterial_Unique UNIQUE (CalzadoCodigo, MaterialCodigo)
)
GO

-- 2.7 Inventario.HistorialMaterial
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

-- 2.8 Inventario.HistorialCalzado
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

-- 2.9 Inventario.OrdenProduccion
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

-- 2.10 Inventario.OrdenProduccionDetalle
CREATE TABLE Inventario.OrdenProduccionDetalle (
    DetalleID BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrdenID INT NOT NULL,
    MaterialCodigo NCHAR(8) NOT NULL,
    CantidadConsumida DECIMAL(10,2) NOT NULL CHECK (CantidadConsumida > 0),
    CONSTRAINT Detalle_OrdenFK FOREIGN KEY (OrdenID) REFERENCES Inventario.OrdenProduccion(OrdenID),
    CONSTRAINT Detalle_MaterialFK FOREIGN KEY (MaterialCodigo) REFERENCES Inventario.Material(MaterialCodigo)
)
GO

-- 2.11 Inventario.Carrito
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

-- 2.12 Inventario.CarritoDetalle
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

-- 2.13 Inventario.Venta
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

-- 2.14 Inventario.VentaDetalle
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
-- 3. PROCEDIMIENTOS ALMACENADOS (ORDENADOS POR MÓDULO)
-- =========================================================================

-- ==========================================
-- SEGURIDAD
-- ==========================================

-- 3.1 Validar Acceso
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

-- 3.2 Restablecer Contraseña
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

-- ==========================================
-- DASHBOARD
-- ==========================================

-- 4.1 Obtener Resumen
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

-- 4.2 Listar Actividad Reciente
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ListarActividadReciente
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE)
    
    SELECT
        V.VentaID AS Id,
        CAST(V.FechaVenta AS DATE) AS Fecha,
        'VENTA' AS Tipo,
        'Venta #' + CAST(V.VentaID AS NVARCHAR(10)) AS Descripcion,
        CONVERT(NVARCHAR(20), SUM(VD.Cantidad)) + ' Pares' AS Cantidad,
        'Total: S/.' + CONVERT(NVARCHAR(20), CAST(V.Total AS DECIMAL(10,2))) AS Movimiento,
        U.UsuarioNombre AS Encargado,
        V.VentaID AS ReferenciaId,
        'VENTA' AS ReferenciaTipo
    FROM Inventario.Venta V
    INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
    INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID
    WHERE CAST(V.FechaVenta AS DATE) = @FechaActual
        AND V.Estado = 'A'
    GROUP BY V.VentaID, V.FechaVenta, V.Total, U.UsuarioNombre

    UNION ALL

    SELECT
        O.OrdenID AS Id,
        CAST(O.OrdenFecha AS DATE) AS Fecha,
        'PRODUCCION' AS Tipo,
        'Orden #' + CAST(O.OrdenID AS NVARCHAR(10)) + ' - ' + C.CalzadoModelo AS Descripcion,
        CONVERT(NVARCHAR(20), O.CantidadPares) + ' Pares' AS Cantidad,
        'Produccion: ' + CAST(O.CantidadPares AS NVARCHAR(10)) + ' pares' AS Movimiento,
        U.UsuarioNombre AS Encargado,
        O.OrdenID AS ReferenciaId,
        'PRODUCCION' AS ReferenciaTipo
    FROM Inventario.OrdenProduccion O
    INNER JOIN Seguridad.Usuario U ON O.UsuarioID = U.UsuarioID
    INNER JOIN Inventario.Calzado C ON O.CalzadoCodigo = C.CalzadoCodigo
    WHERE CAST(O.OrdenFecha AS DATE) = @FechaActual
        AND O.OrdenEstado = 'A'

    ORDER BY Id DESC 
END
GO

-- 4.3 Filtrar Movimientos
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_FiltrarMovimientos
    @TipoFiltro NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE)
    
    IF @TipoFiltro = 'VENTA'
    BEGIN
        SELECT
            V.VentaID AS Id,
            CAST(V.FechaVenta AS DATE) AS Fecha,
            'VENTA' AS Tipo,
            'Venta #' + CAST(V.VentaID AS NVARCHAR(10)) AS Descripcion,
            CONVERT(NVARCHAR(20), SUM(VD.Cantidad)) + ' Pares' AS Cantidad,
            'Total: S/.' + CONVERT(NVARCHAR(20), CAST(V.Total AS DECIMAL(10,2))) AS Movimiento,
            U.UsuarioNombre AS Encargado,
            V.VentaID AS ReferenciaId,
            'VENTA' AS ReferenciaTipo
        FROM Inventario.Venta V
        INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
        INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID
        WHERE CAST(V.FechaVenta AS DATE) = @FechaActual
            AND V.Estado = 'A'
        GROUP BY V.VentaID, V.FechaVenta, V.Total, U.UsuarioNombre
        ORDER BY V.VentaID DESC
        RETURN
    END

    IF @TipoFiltro = 'PRODUCCION'
    BEGIN
        SELECT
            O.OrdenID AS Id,
            CAST(O.OrdenFecha AS DATE) AS Fecha,
            'PRODUCCION' AS Tipo,
            'Orden #' + CAST(O.OrdenID AS NVARCHAR(10)) + ' - ' + C.CalzadoModelo AS Descripcion,
            CONVERT(NVARCHAR(20), O.CantidadPares) + ' Pares' AS Cantidad,
            'Produccion: ' + CAST(O.CantidadPares AS NVARCHAR(10)) + ' pares' AS Movimiento,
            U.UsuarioNombre AS Encargado,
            O.OrdenID AS ReferenciaId,
            'PRODUCCION' AS ReferenciaTipo
        FROM Inventario.OrdenProduccion O
        INNER JOIN Seguridad.Usuario U ON O.UsuarioID = U.UsuarioID
        INNER JOIN Inventario.Calzado C ON O.CalzadoCodigo = C.CalzadoCodigo
        WHERE CAST(O.OrdenFecha AS DATE) = @FechaActual
            AND O.OrdenEstado = 'A'
        ORDER BY O.OrdenFecha DESC, O.OrdenID DESC 
        RETURN
    END
    
    DECLARE @TipoMovimientoCodigo NCHAR(3)
    
    IF @TipoFiltro = 'ABASTECIMIENTO'
        SET @TipoMovimientoCodigo = 'E01'
    ELSE IF @TipoFiltro = 'CONSUMO'
        SET @TipoMovimientoCodigo = 'S01'
    ELSE IF @TipoFiltro = 'DESCARTE'
        SET @TipoMovimientoCodigo = 'S03'

    IF @TipoMovimientoCodigo IS NOT NULL
    BEGIN
        SELECT
            CAST(HM.HistorialMaterialId AS INT) AS Id,
            CAST(HM.HistorialMaterialFecha AS DATE) AS Fecha,
            'Material' AS Tipo,
            M.MaterialNombre AS Descripcion,
            CONVERT(NVARCHAR(20), HM.HistorialMaterialCantidad) + ' ' + M.MaterialMedida AS Cantidad,
            TM.TipoMovimientoDescripcion AS Movimiento,
            U.UsuarioNombre AS Encargado,
            NULL AS ReferenciaId,
            NULL AS ReferenciaTipo
        FROM Inventario.HistorialMaterial HM
        INNER JOIN Inventario.Material M ON HM.MaterialCodigo = M.MaterialCodigo
        INNER JOIN Inventario.TipoMovimiento TM ON HM.TipoMovimientoCodigo = TM.TipoMovimientoCodigo
        INNER JOIN Seguridad.Usuario U ON HM.UsuarioID = U.UsuarioID
        WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual
            AND TM.TipoMovimientoCodigo = @TipoMovimientoCodigo
        ORDER BY HM.HistorialMaterialFecha DESC, HM.HistorialMaterialId DESC
        RETURN
    END

    SELECT
        NULL AS Id,
        NULL AS Fecha,
        NULL AS Tipo,
        NULL AS Descripcion,
        NULL AS Cantidad,
        NULL AS Movimiento,
        NULL AS Encargado,
        NULL AS ReferenciaId,
        NULL AS ReferenciaTipo
    WHERE 1 = 0
END
GO

-- 4.4 Obtener KPIs por Filtro
CREATE OR ALTER PROCEDURE Inventario.USP_Dashboard_ObtenerKPIsPorFiltro
    @TipoFiltro NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @FechaActual DATE = CAST(GETDATE() AS DATE)
   
    DECLARE @TotalMateriales INT
    DECLARE @TotalModelos INT
    DECLARE @AlertasCriticas INT
    
    SELECT @TotalMateriales = COUNT(*) FROM Inventario.Material WHERE MaterialEstado = 'A'
    SELECT @TotalModelos = COUNT(DISTINCT CalzadoModelo) FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    SELECT @AlertasCriticas = COUNT(*) FROM Inventario.Material WHERE MaterialCantidad < 5.00 AND MaterialEstado = 'A'

    IF @TipoFiltro = 'VENTA'
    BEGIN
        SELECT
            @TotalMateriales AS TotalMateriales,
            @TotalModelos AS TotalModelos,
            @AlertasCriticas AS AlertasCriticas,
            
            ISNULL((SELECT SUM(Total) FROM Inventario.Venta WHERE CAST(FechaVenta AS DATE) = @FechaActual AND Estado = 'A'), 0) AS IngresosTotales,
            
            ISNULL((SELECT SUM(VD.Cantidad) FROM Inventario.Venta V INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID WHERE CAST(V.FechaVenta AS DATE) = @FechaActual AND V.Estado = 'A'), 0) AS TotalCalzado,
            
            (SELECT TOP 1 C.CalzadoModelo + '|' + RTRIM(C.CalzadoColor) + '|' + CONVERT(NVARCHAR(3), C.CalzadoTalla) + '|' + CONVERT(NVARCHAR(10), SUM(VD.Cantidad))
            FROM Inventario.Venta V INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID INNER JOIN Inventario.Calzado C ON VD.CalzadoCodigo = C.CalzadoCodigo
            WHERE CAST(V.FechaVenta AS DATE) = @FechaActual AND V.Estado = 'A'
            GROUP BY C.CalzadoModelo, C.CalzadoColor, C.CalzadoTalla
            ORDER BY SUM(VD.Cantidad) DESC) AS ProductoMasVendido,
            
            0 AS TotalMovimientosMateriales,
            0 AS TotalAbastecimiento,
            0 AS TotalDescarte,
            NULL AS MaterialMasConsumido,
            0 AS TotalMovimientos
        RETURN
    END

    IF @TipoFiltro = 'PRODUCCION'
    BEGIN
        SELECT
            @TotalMateriales AS TotalMateriales,
            @TotalModelos AS TotalModelos,
            @AlertasCriticas AS AlertasCriticas,
            
            ISNULL((SELECT SUM(CantidadPares) FROM Inventario.OrdenProduccion WHERE CAST(OrdenFecha AS DATE) = @FechaActual AND OrdenEstado = 'A'), 0) AS TotalCalzado,
            
            0 AS IngresosTotales,
            NULL AS ProductoMasVendido,
            0 AS TotalMovimientosMateriales,
            0 AS TotalAbastecimiento,
            0 AS TotalDescarte,
            NULL AS MaterialMasConsumido,
            0 AS TotalMovimientos
        RETURN
    END

    IF @TipoFiltro = 'ABASTECIMIENTO'
    BEGIN
        SELECT
            @TotalMateriales AS TotalMateriales,
            @TotalModelos AS TotalModelos,
            @AlertasCriticas AS AlertasCriticas,
            
            ISNULL((SELECT SUM(HistorialMaterialCantidad) FROM Inventario.HistorialMaterial WHERE CAST(HistorialMaterialFecha AS DATE) = @FechaActual AND TipoMovimientoCodigo = 'E01'), 0) AS TotalAbastecimiento,
            
            0 AS IngresosTotales,
            NULL AS ProductoMasVendido,
            0 AS TotalCalzado,
            0 AS TotalDescarte,
            NULL AS MaterialMasConsumido,
            0 AS TotalMovimientos
        RETURN
    END

    IF @TipoFiltro = 'CONSUMO'
    BEGIN
        SELECT
            @TotalMateriales AS TotalMateriales,
            @TotalModelos AS TotalModelos,
            @AlertasCriticas AS AlertasCriticas,
            
            ISNULL((SELECT SUM(HistorialMaterialCantidad) FROM Inventario.HistorialMaterial WHERE CAST(HistorialMaterialFecha AS DATE) = @FechaActual AND TipoMovimientoCodigo = 'S01'), 0) AS TotalMovimientos,
            
            (SELECT TOP 1 M.MaterialCategoria + '|' + M.MaterialNombre + '|' + CONVERT(NVARCHAR(10), SUM(HM.HistorialMaterialCantidad)) + ' ' + M.MaterialMedida
            FROM Inventario.HistorialMaterial HM INNER JOIN Inventario.Material M ON HM.MaterialCodigo = M.MaterialCodigo
            WHERE CAST(HM.HistorialMaterialFecha AS DATE) = @FechaActual AND HM.TipoMovimientoCodigo = 'S01'
            GROUP BY M.MaterialCategoria, M.MaterialNombre, M.MaterialMedida
            ORDER BY SUM(HM.HistorialMaterialCantidad) DESC) AS MaterialMasConsumido,
            
            0 AS IngresosTotales,
            NULL AS ProductoMasVendido,
            0 AS TotalCalzado,
            0 AS TotalAbastecimiento,
            0 AS TotalDescarte
        RETURN
    END

    IF @TipoFiltro = 'DESCARTE'
    BEGIN
        SELECT
            @TotalMateriales AS TotalMateriales,
            @TotalModelos AS TotalModelos,
            @AlertasCriticas AS AlertasCriticas,
            
            ISNULL((SELECT SUM(HistorialMaterialCantidad) FROM Inventario.HistorialMaterial WHERE CAST(HistorialMaterialFecha AS DATE) = @FechaActual AND TipoMovimientoCodigo = 'S03'), 0) AS TotalDescarte,
            
            0 AS IngresosTotales,
            NULL AS ProductoMasVendido,
            0 AS TotalCalzado,
            0 AS TotalAbastecimiento,
            0 AS TotalMovimientos,
            NULL AS MaterialMasConsumido
        RETURN
    END

    SELECT
        @TotalMateriales AS TotalMateriales,
        @TotalModelos AS TotalModelos,
        @AlertasCriticas AS AlertasCriticas,
        0 AS IngresosTotales,
        NULL AS ProductoMasVendido,
        0 AS TotalCalzado,
        0 AS TotalAbastecimiento,
        0 AS TotalDescarte,
        0 AS TotalMovimientos,
        NULL AS MaterialMasConsumido
END
GO

-- ==========================================
-- INVENTARIO - MATERIALES
-- ==========================================

-- 4.5 Listar Materiales
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

-- 4.6 Listar Alertas Bajo Stock
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

-- 4.7 Insertar Material
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

-- 4.8 Listar Materiales para Dropdown
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

-- 4.9 Editar Material
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

-- 4.10 Eliminar Material
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

-- ==========================================
-- INVENTARIO - CALZADO
-- ==========================================

-- 4.11 Listar Calzado
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

-- 4.12 Listar Calzado para Dropdown
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

-- ==========================================
-- PRODUCCIÓN
-- ==========================================

-- 4.13 Obtener Receta
CREATE OR ALTER PROCEDURE Inventario.USP_Produccion_ObtenerReceta
    @CalzadoCodigo NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT
        CM.CalzadoMaterialID,
        CM.CalzadoCodigo,
        CM.MaterialCodigo,
        M.MaterialNombre,
        M.MaterialCategoria,
        M.MaterialMedida,
        CM.CantidadPorPar,
        M.MaterialCantidad AS StockDisponible
    FROM Inventario.CalzadoMaterial CM
    INNER JOIN Inventario.Material M ON CM.MaterialCodigo = M.MaterialCodigo
    WHERE CM.CalzadoCodigo = @CalzadoCodigo
        AND M.MaterialEstado = 'A'
    ORDER BY M.MaterialCategoria, M.MaterialNombre
END
GO

-- 4.14 Obtener Receta con Validación de Stock
CREATE OR ALTER PROCEDURE Inventario.USP_Produccion_ObtenerRecetaConStock
    @CalzadoCodigo NCHAR(8),
    @CantidadPares INT
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT
        CM.CalzadoMaterialID,
        CM.CalzadoCodigo,
        CM.MaterialCodigo,
        M.MaterialNombre,
        M.MaterialCategoria,
        M.MaterialMedida,
        CM.CantidadPorPar,
        M.MaterialCantidad AS StockActual,
        (CM.CantidadPorPar * @CantidadPares) AS CantidadNecesaria,
        CASE 
            WHEN M.MaterialCantidad >= (CM.CantidadPorPar * @CantidadPares) THEN 1 
            ELSE 0 
        END AS StockSuficiente,
        CASE 
            WHEN M.MaterialCantidad < (CM.CantidadPorPar * @CantidadPares) 
            THEN (CM.CantidadPorPar * @CantidadPares) - M.MaterialCantidad
            ELSE 0
        END AS Faltante,
        M.MaterialCantidad - (CM.CantidadPorPar * @CantidadPares) AS StockRestante
    FROM Inventario.CalzadoMaterial CM
    INNER JOIN Inventario.Material M ON CM.MaterialCodigo = M.MaterialCodigo
    WHERE CM.CalzadoCodigo = @CalzadoCodigo
        AND M.MaterialEstado = 'A'
    ORDER BY M.MaterialCategoria, M.MaterialNombre
END
GO

-- 4.15 Registrar Producción Automática
CREATE OR ALTER PROCEDURE Inventario.USP_Produccion_RegistrarAutomatica
    @CalzadoCodigo NCHAR(8),
    @CantidadPares INT,
    @UsuarioID NCHAR(8)
AS
BEGIN
    SET NOCOUNT ON
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        DECLARE @OrdenID INT
        DECLARE @ErrorMateriales NVARCHAR(MAX) = ''
        DECLARE @CalzadoNombre NVARCHAR(100)
        DECLARE @MensajeError NVARCHAR(MAX)
        
        SELECT @CalzadoNombre = CalzadoModelo 
        FROM Inventario.Calzado 
        WHERE CalzadoCodigo = @CalzadoCodigo AND CalzadoEstado = 'A'
        
        IF @CalzadoNombre IS NULL
        BEGIN
            RAISERROR('El calzado no existe o está inactivo.', 16, 1)
        END
        
        IF NOT EXISTS (SELECT 1 FROM Inventario.CalzadoMaterial WHERE CalzadoCodigo = @CalzadoCodigo)
        BEGIN
            RAISERROR('El calzado "%s" no tiene una receta de materiales configurada.', 16, 1, @CalzadoNombre)
        END
        
        CREATE TABLE #ValidacionMateriales (
            MaterialCodigo NCHAR(8),
            MaterialNombre NVARCHAR(100),
            Medida NVARCHAR(20),
            CantidadPorPar DECIMAL(10,2),
            StockActual DECIMAL(10,2),
            CantidadNecesaria DECIMAL(10,2),
            StockSuficiente BIT DEFAULT 0,
            Faltante DECIMAL(10,2) DEFAULT 0
        )
        
        INSERT INTO #ValidacionMateriales (MaterialCodigo, MaterialNombre, Medida, CantidadPorPar, StockActual)
        SELECT
            CM.MaterialCodigo,
            M.MaterialNombre,
            M.MaterialMedida,
            CM.CantidadPorPar,
            M.MaterialCantidad
        FROM Inventario.CalzadoMaterial CM
        INNER JOIN Inventario.Material M ON CM.MaterialCodigo = M.MaterialCodigo
        WHERE CM.CalzadoCodigo = @CalzadoCodigo
            AND M.MaterialEstado = 'A'
        
        UPDATE #ValidacionMateriales
        SET 
            CantidadNecesaria = CantidadPorPar * @CantidadPares,
            StockSuficiente = CASE 
                WHEN StockActual >= (CantidadPorPar * @CantidadPares) THEN 1 
                ELSE 0 
            END,
            Faltante = CASE 
                WHEN StockActual < (CantidadPorPar * @CantidadPares) 
                THEN (CantidadPorPar * @CantidadPares) - StockActual
                ELSE 0
            END
        
        SELECT @ErrorMateriales = STUFF((
            SELECT CHAR(10) + 
                MaterialNombre + ' (Disponible: ' + CAST(StockActual AS NVARCHAR(10)) + 
                ' ' + Medida + ', Necesario: ' + CAST(CantidadNecesaria AS NVARCHAR(10)) + 
                ' ' + Medida + ', Faltante: ' + CAST(Faltante AS NVARCHAR(10)) + ' ' + Medida + ')'
            FROM #ValidacionMateriales
            WHERE StockSuficiente = 0
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
        
        IF @ErrorMateriales IS NOT NULL AND @ErrorMateriales <> ''
        BEGIN
            SET @MensajeError = 'Stock insuficiente para los siguientes materiales:' + CHAR(10) + @ErrorMateriales
            RAISERROR(@MensajeError, 16, 1)
        END
        
        INSERT INTO Inventario.OrdenProduccion (CalzadoCodigo, CantidadPares, UsuarioID, OrdenFecha)
        VALUES (@CalzadoCodigo, @CantidadPares, @UsuarioID, GETDATE())
        SET @OrdenID = SCOPE_IDENTITY()
        
        INSERT INTO Inventario.OrdenProduccionDetalle (OrdenID, MaterialCodigo, CantidadConsumida)
        SELECT @OrdenID, MaterialCodigo, CantidadNecesaria
        FROM #ValidacionMateriales
        
        UPDATE M
        SET M.MaterialCantidad = M.MaterialCantidad - VM.CantidadNecesaria
        FROM Inventario.Material M
        INNER JOIN #ValidacionMateriales VM ON M.MaterialCodigo = VM.MaterialCodigo
        
        INSERT INTO Inventario.HistorialMaterial (MaterialCodigo, TipoMovimientoCodigo, HistorialMaterialCantidad, UsuarioID, HistorialMaterialFecha, HistorialMaterialNota)
        SELECT
            MaterialCodigo,
            'S01',
            CantidadNecesaria,
            @UsuarioID,
            GETDATE(),
            'Consumo por Producción - Orden #' + CAST(@OrdenID AS NVARCHAR(10)) + 
            ' - ' + CAST(@CantidadPares AS NVARCHAR(10)) + ' pares de ' + @CalzadoNombre
        FROM #ValidacionMateriales
        
        UPDATE Inventario.Calzado
        SET CalzadoStock = CalzadoStock + @CantidadPares
        WHERE CalzadoCodigo = @CalzadoCodigo
        
        INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID, HistorialCalzadoFecha)
        VALUES (@CalzadoCodigo, 'E02', @CantidadPares, @UsuarioID, GETDATE())
        
        DROP TABLE #ValidacionMateriales
        
        COMMIT TRANSACTION
        
        SELECT @OrdenID AS OrdenID, @CantidadPares AS CantidadPares, 'EXITO' AS Resultado,
               'Producción registrada correctamente. Orden #' + CAST(@OrdenID AS NVARCHAR(10)) AS Mensaje
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        
        IF OBJECT_ID('tempdb..#ValidacionMateriales') IS NOT NULL
            DROP TABLE #ValidacionMateriales
        
        DECLARE @ErrorNumber INT = ERROR_NUMBER()
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        
        IF @ErrorNumber = 50000
        BEGIN
            RAISERROR(@ErrorMessage, 16, 1)
        END
        ELSE
        BEGIN
            RAISERROR('Error interno: %s', 16, 1, @ErrorMessage)
        END
    END CATCH
END
GO

-- 4.16 Obtener Detalle de Orden
CREATE OR ALTER PROCEDURE Inventario.USP_Produccion_ObtenerDetalle
    @OrdenID INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        O.OrdenID,
        O.CalzadoCodigo,
        C.CalzadoModelo,
        C.CalzadoColor,
        C.CalzadoTalla,
        O.CantidadPares,
        O.OrdenFecha,
        U.UsuarioNombre AS Operario,
        O.OrdenEstado
    FROM Inventario.OrdenProduccion O
    INNER JOIN Inventario.Calzado C ON O.CalzadoCodigo = C.CalzadoCodigo
    INNER JOIN Seguridad.Usuario U ON O.UsuarioID = U.UsuarioID
    WHERE O.OrdenID = @OrdenID

    SELECT
        OD.DetalleID,
        OD.MaterialCodigo,
        M.MaterialNombre,
        M.MaterialCategoria,
        M.MaterialMedida,
        OD.CantidadConsumida
    FROM Inventario.OrdenProduccionDetalle OD
    INNER JOIN Inventario.Material M ON OD.MaterialCodigo = M.MaterialCodigo
    WHERE OD.OrdenID = @OrdenID
    ORDER BY M.MaterialCategoria, M.MaterialNombre
END
GO

-- ==========================================
-- CARRITO
-- ==========================================

-- 4.17 Obtener Detalle Carrito
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
        SELECT NULL AS CarritoID, NULL AS UsuarioID, NULL AS Total, CAST(0 AS INT) AS CantidadTotal,
               CAST(0 AS DECIMAL(10,2)) AS TotalGeneral, CAST(0 AS INT) AS NumeroItems
        RETURN
    END

    SELECT
        C.CarritoID, C.UsuarioID, U.UsuarioNombre AS UsuarioNombre, C.Total,
        C.FechaCreacion, C.FechaActualizacion,
        (SELECT COUNT(*) FROM Inventario.CarritoDetalle WHERE CarritoID = C.CarritoID) AS NumeroItems,
        (SELECT SUM(Cantidad) FROM Inventario.CarritoDetalle WHERE CarritoID = C.CarritoID) AS CantidadTotal
    FROM Inventario.Carrito C
    INNER JOIN Seguridad.Usuario U ON C.UsuarioID = U.UsuarioID
    WHERE C.CarritoID = @CarritoIDFinal

    SELECT
        CD.DetalleID, CD.CalzadoCodigo, CA.CalzadoModelo AS Modelo, CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla, CD.Cantidad, CD.PrecioUnitario, CD.Subtotal,
        CA.CalzadoStock AS StockDisponible, CD.FechaAgregado
    FROM Inventario.CarritoDetalle CD
    INNER JOIN Inventario.Calzado CA ON CD.CalzadoCodigo = CA.CalzadoCodigo
    WHERE CD.CarritoID = @CarritoIDFinal
    ORDER BY CD.FechaAgregado DESC
END
GO

-- 4.18 Agregar Producto al Carrito
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
            INSERT INTO Inventario.Carrito (UsuarioID, Total) VALUES (@UsuarioID, 0.00)
            SET @CarritoID = SCOPE_IDENTITY()
        END

        IF EXISTS (SELECT 1 FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID AND CalzadoCodigo = @CalzadoCodigo)
        BEGIN
            UPDATE Inventario.CarritoDetalle
            SET Cantidad = Cantidad + @Cantidad, Subtotal = (Cantidad + @Cantidad) * @PrecioUnitario, FechaAgregado = GETDATE()
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

-- 4.19 Actualizar Cantidad Carrito
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

-- 4.20 Eliminar Producto del Carrito
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

-- 4.21 Limpiar Carrito
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

-- 4.22 Confirmar Venta desde Carrito
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
            RAISERROR('No tienes un carrito activo con productos.', 16, 1)
        
        IF @Total = 0
            RAISERROR('El carrito está vacío.', 16, 1)
        
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
        
        INSERT INTO Inventario.Venta (UsuarioID, CarritoID, Total, FechaVenta, Estado)
        VALUES (@UsuarioID, @CarritoID, @Total, GETDATE(), 'A')
        SET @VentaID = SCOPE_IDENTITY()
        
        INSERT INTO Inventario.VentaDetalle (VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal)
        SELECT @VentaID, CalzadoCodigo, Cantidad, PrecioUnitario, Subtotal
        FROM Inventario.CarritoDetalle WHERE CarritoID = @CarritoID
        
        INSERT INTO Inventario.HistorialCalzado (CalzadoCodigo, TipoMovimientoCodigo, HistorialCalzadoCantidad, UsuarioID, HistorialCalzadoFecha)
        SELECT CD.CalzadoCodigo, 'S02', CD.Cantidad, @UsuarioID, GETDATE()
        FROM Inventario.CarritoDetalle CD WHERE CD.CarritoID = @CarritoID
        
        UPDATE CA
        SET CA.CalzadoStock = CA.CalzadoStock - CD.Cantidad
        FROM Inventario.Calzado CA
        INNER JOIN Inventario.CarritoDetalle CD ON CA.CalzadoCodigo = CD.CalzadoCodigo
        WHERE CD.CarritoID = @CarritoID
        
        UPDATE Inventario.Carrito SET Estado = 'C', FechaActualizacion = GETDATE()
        WHERE CarritoID = @CarritoID
        
        COMMIT TRANSACTION
        
        SELECT @VentaID AS VentaID, @CarritoID AS CarritoID, @Total AS Total, GETDATE() AS FechaVenta,
               'EXITO' AS Resultado, 'Venta realizada con éxito. Venta #' + CAST(@VentaID AS NVARCHAR(10)) AS Mensaje
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

-- ==========================================
-- VENTAS
-- ==========================================

-- 4.23 Obtener Historial de Ventas
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
        V.VentaID, V.UsuarioID, U.UsuarioNombre, V.FechaVenta, V.Total, V.Estado,
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

-- 4.24 Obtener Detalle de Venta
CREATE OR ALTER PROCEDURE Inventario.USP_Venta_ObtenerDetalle
    @VentaID INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT V.VentaID, V.UsuarioID, U.UsuarioNombre, V.FechaVenta, V.Total, V.Estado
    FROM Inventario.Venta V
    INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
    WHERE V.VentaID = @VentaID

    SELECT VD.VentaDetalleID, VD.CalzadoCodigo, CA.CalzadoModelo AS Modelo,
           CA.CalzadoColor AS Color, CA.CalzadoTalla AS Talla,
           VD.Cantidad, VD.PrecioUnitario, VD.Subtotal
    FROM Inventario.VentaDetalle VD
    INNER JOIN Inventario.Calzado CA ON VD.CalzadoCodigo = CA.CalzadoCodigo
    WHERE VD.VentaID = @VentaID
    ORDER BY VD.VentaDetalleID
END
GO

-- ==========================================
-- REPORTES
-- ==========================================

-- 5.1 Reporte de Ventas
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Ventas  
    @FechaInicio DATE = NULL,  
    @FechaFin DATE = NULL,  
    @TipoFiltro NVARCHAR(20) = 'MES',  
    @UsuarioID NCHAR(8) = NULL  
AS  
BEGIN  
    SET NOCOUNT ON      
    
    -- ==========================================
    -- 1. CONFIGURAR FECHAS SEGÚN FILTRO
    -- ==========================================
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
    
    IF @FechaInicio IS NULL  
        SET @FechaInicio = DATEADD(MONTH, -1, GETDATE())  
    IF @FechaFin IS NULL  
        SET @FechaFin = GETDATE()  

    -- ==========================================
    -- 2. RESUMEN GENERAL
    -- ==========================================
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

    -- ==========================================
    -- 3. TOP 5 PRODUCTOS MÁS VENDIDOS
    -- ==========================================
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

    -- ==========================================
    -- 4. VENTAS POR DÍA/MES
    -- ==========================================
    IF @TipoFiltro = 'ANIO'  
    BEGIN  
        SELECT  
            DATEFROMPARTS(YEAR(V.FechaVenta), MONTH(V.FechaVenta), 1) AS Fecha,  
            COUNT(*) AS NumeroVentas,  
            SUM(V.Total) AS IngresosDelDia,  
            ISNULL(SUM(VD.Cantidad), 0) AS ParesVendidos  
        FROM Inventario.Venta V  
        LEFT JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID  
        WHERE CAST(V.FechaVenta AS DATE) BETWEEN @FechaInicio AND @FechaFin  
            AND V.Estado = 'A'  
            AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)  
        GROUP BY YEAR(V.FechaVenta), MONTH(V.FechaVenta)  
        ORDER BY YEAR(V.FechaVenta) DESC, MONTH(V.FechaVenta) DESC  
    END  
    ELSE  
    BEGIN  
        -- ✅ Para DIA, SEMANA, MES: agrupar por DÍA
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
    END  

    -- ==========================================
    -- 5. VENTAS POR TIPO DE CALZADO
    -- ==========================================
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

-- 5.2 Reporte de Producción
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Produccion
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @TipoFiltro NVARCHAR(20) = 'MES', 
    @UsuarioID NCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON
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
    
    IF @FechaInicio IS NULL
        SET @FechaInicio = DATEADD(MONTH, -1, GETDATE())
    IF @FechaFin IS NULL
        SET @FechaFin = GETDATE()

    SELECT
        @FechaInicio AS FechaInicio,
        @FechaFin AS FechaFin,
        @TipoFiltro AS TipoFiltro,
        COUNT(DISTINCT O.OrdenID) AS TotalOrdenes,
        ISNULL(SUM(O.CantidadPares), 0) AS TotalParesProducidos,
        ISNULL(AVG(CAST(O.CantidadPares AS DECIMAL(10,2))), 0) AS PromedioParesPorOrden,
        COUNT(DISTINCT O.UsuarioID) AS OperariosActivos,
        COUNT(DISTINCT O.CalzadoCodigo) AS ModelosProducidos
    FROM Inventario.OrdenProduccion O
    WHERE CAST(O.OrdenFecha AS DATE) BETWEEN @FechaInicio AND @FechaFin
        AND O.OrdenEstado = 'A'
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)

    -- ==========================================
    -- 3. TOP 5 MODELOS PRODUCIDOS
    -- ==========================================
    SELECT TOP 5
        CA.CalzadoModelo AS Modelo,
        CA.CalzadoTipo AS Tipo,
        CA.CalzadoColor AS Color,
        CA.CalzadoTalla AS Talla,
        SUM(O.CantidadPares) AS TotalProducido,
        COUNT(DISTINCT O.OrdenID) AS NumeroOrdenes
    FROM Inventario.OrdenProduccion O
    INNER JOIN Inventario.Calzado CA ON O.CalzadoCodigo = CA.CalzadoCodigo
    WHERE CAST(O.OrdenFecha AS DATE) BETWEEN @FechaInicio AND @FechaFin
        AND O.OrdenEstado = 'A'
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    GROUP BY CA.CalzadoModelo, CA.CalzadoTipo, CA.CalzadoColor, CA.CalzadoTalla
    ORDER BY SUM(O.CantidadPares) DESC
  
    IF @TipoFiltro = 'ANIO'  
    BEGIN  
        SELECT  
            DATEFROMPARTS(YEAR(O.OrdenFecha), MONTH(O.OrdenFecha), 1) AS Fecha,  
            COUNT(*) AS NumeroOrdenes,  
            SUM(O.CantidadPares) AS ParesProducidos  
        FROM Inventario.OrdenProduccion O  
        WHERE CAST(O.OrdenFecha AS DATE) BETWEEN @FechaInicio AND @FechaFin  
            AND O.OrdenEstado = 'A'  
            AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)  
        GROUP BY YEAR(O.OrdenFecha), MONTH(O.OrdenFecha)  
        ORDER BY YEAR(O.OrdenFecha) DESC, MONTH(O.OrdenFecha) DESC  
    END  
    ELSE  
    BEGIN  
        SELECT  
            CAST(O.OrdenFecha AS DATE) AS Fecha,  
            COUNT(*) AS NumeroOrdenes,  
            SUM(O.CantidadPares) AS ParesProducidos  
        FROM Inventario.OrdenProduccion O  
        WHERE CAST(O.OrdenFecha AS DATE) BETWEEN @FechaInicio AND @FechaFin  
            AND O.OrdenEstado = 'A'  
            AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)  
        GROUP BY CAST(O.OrdenFecha AS DATE)  
        ORDER BY Fecha DESC  
    END  
  
    SELECT TOP 5
        M.MaterialNombre AS Material,
        M.MaterialCategoria AS Categoria,
        SUM(OD.CantidadConsumida) AS TotalConsumido,
        M.MaterialMedida AS Unidad
    FROM Inventario.OrdenProduccionDetalle OD
    INNER JOIN Inventario.Material M ON OD.MaterialCodigo = M.MaterialCodigo
    INNER JOIN Inventario.OrdenProduccion O ON OD.OrdenID = O.OrdenID
    WHERE CAST(O.OrdenFecha AS DATE) BETWEEN @FechaInicio AND @FechaFin
        AND O.OrdenEstado = 'A'
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    GROUP BY M.MaterialNombre, M.MaterialCategoria, M.MaterialMedida
    ORDER BY SUM(OD.CantidadConsumida) DESC
END
GO

-- 5.3 Reporte Comparativo
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

    ;WITH Ventas AS (
        SELECT FORMAT(V.FechaVenta, 'yyyy-MM') AS Periodo, SUM(V.Total) AS TotalVentas, SUM(VD.Cantidad) AS ParesVendidos
        FROM Inventario.Venta V
        LEFT JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID
        WHERE V.FechaVenta BETWEEN @FechaInicio AND @FechaFin AND V.Estado = 'A'
        GROUP BY FORMAT(V.FechaVenta, 'yyyy-MM')
    ),
    Produccion AS (
        SELECT FORMAT(O.OrdenFecha, 'yyyy-MM') AS Periodo, SUM(O.CantidadPares) AS ParesProducidos
        FROM Inventario.OrdenProduccion O
        WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        GROUP BY FORMAT(O.OrdenFecha, 'yyyy-MM')
    )
    SELECT
        ISNULL(V.Periodo, P.Periodo) AS Periodo,
        ISNULL(V.TotalVentas, 0) AS IngresosPorVentas,
        ISNULL(V.ParesVendidos, 0) AS ParesVendidos,
        ISNULL(P.ParesProducidos, 0) AS ParesProducidos,
        ISNULL(P.ParesProducidos, 0) - ISNULL(V.ParesVendidos, 0) AS DiferenciaPares,
        CASE 
            WHEN ISNULL(P.ParesProducidos, 0) = 0 THEN 0
            ELSE CAST(ISNULL(V.ParesVendidos, 0) AS DECIMAL(10,2)) / CAST(P.ParesProducidos AS DECIMAL(10,2)) * 100
        END AS PorcentajeConversion
    FROM Ventas V
    FULL OUTER JOIN Produccion P ON V.Periodo = P.Periodo
    ORDER BY Periodo DESC 
END
GO

-- 5.4 Reporte de Stock
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Stock
    @Tipo NVARCHAR(20) = 'TODOS' 
AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #StockTemp (
        Tipo NVARCHAR(20), Codigo NVARCHAR(10), Nombre NVARCHAR(100), Categoria NVARCHAR(50),
        Color NVARCHAR(50), Talla NVARCHAR(10), Stock NVARCHAR(20), Precio NVARCHAR(20),
        Estado NVARCHAR(20), Prioridad INT, StockNumero FLOAT
    )

    IF @Tipo = 'TODOS' OR @Tipo = 'CALZADO'
    BEGIN
        INSERT INTO #StockTemp (Tipo, Codigo, Nombre, Categoria, Color, Talla, Stock, Precio, Estado, Prioridad, StockNumero)
        SELECT
            'Calzado' AS Tipo, CalzadoCodigo AS Codigo, CalzadoModelo AS Nombre, CalzadoTipo AS Categoria,
            CalzadoColor AS Color, CAST(CalzadoTalla AS NVARCHAR(10)) AS Talla,
            CAST(CalzadoStock AS NVARCHAR(20)) AS Stock, CAST(CalzadoPrecioVenta AS NVARCHAR(20)) AS Precio,
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
        FROM Inventario.Calzado WHERE CalzadoEstado = 'A'
    END

    IF @Tipo = 'TODOS' OR @Tipo = 'MATERIAL'
    BEGIN
        INSERT INTO #StockTemp (Tipo, Codigo, Nombre, Categoria, Color, Talla, Stock, Precio, Estado, Prioridad, StockNumero)
        SELECT
            'Material' AS Tipo, MaterialCodigo AS Codigo, MaterialNombre AS Nombre, MaterialCategoria AS Categoria,
            '' AS Color, 'N/A' AS Talla,
            CAST(MaterialCantidad AS NVARCHAR(20)) AS Stock, 'S/.0.00' AS Precio,
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
        FROM Inventario.Material WHERE MaterialEstado = 'A'
    END

    SELECT Tipo, Codigo, Nombre, Categoria, Color, Talla, Stock, Precio, Estado
    FROM #StockTemp ORDER BY Prioridad ASC, StockNumero ASC

    DROP TABLE #StockTemp
END
GO

-- 5.5 Reporte de Ventas Detallado
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Ventas_Detalle
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @UsuarioID NCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @FechaInicio IS NULL SET @FechaInicio = DATEADD(DAY, -30, GETDATE())
    IF @FechaFin IS NULL SET @FechaFin = GETDATE()

    SELECT
        V.VentaID, V.FechaVenta AS Fecha, V.Total AS TotalVenta, U.UsuarioNombre AS Vendedor,
        CA.CalzadoModelo AS Modelo, CA.CalzadoTipo AS Tipo, CA.CalzadoColor AS Color, CA.CalzadoTalla AS Talla,
        VD.Cantidad, VD.PrecioUnitario, VD.Subtotal
    FROM Inventario.Venta V
    INNER JOIN Inventario.VentaDetalle VD ON V.VentaID = VD.VentaID
    INNER JOIN Inventario.Calzado CA ON VD.CalzadoCodigo = CA.CalzadoCodigo
    INNER JOIN Seguridad.Usuario U ON V.UsuarioID = U.UsuarioID
    WHERE V.FechaVenta BETWEEN @FechaInicio AND @FechaFin
        AND V.Estado = 'A' AND (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)
    ORDER BY V.FechaVenta DESC, V.VentaID DESC
END
GO

-- 5.6 Reporte de Producción Detallado
CREATE OR ALTER PROCEDURE Inventario.USP_Reporte_Produccion_Detalle
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @UsuarioID NCHAR(8) = NULL
AS
BEGIN
    SET NOCOUNT ON
    
    IF @FechaInicio IS NULL SET @FechaInicio = DATEADD(DAY, -30, GETDATE())
    IF @FechaFin IS NULL SET @FechaFin = GETDATE()

    SELECT
        O.OrdenID, O.OrdenFecha AS Fecha, O.CantidadPares AS ParesProducidos,
        U.UsuarioNombre AS Operario, CA.CalzadoModelo AS Modelo,
        CA.CalzadoTipo AS Tipo, CA.CalzadoColor AS Color, CA.CalzadoTalla AS Talla
    FROM Inventario.OrdenProduccion O
    INNER JOIN Inventario.Calzado CA ON O.CalzadoCodigo = CA.CalzadoCodigo
    INNER JOIN Seguridad.Usuario U ON O.UsuarioID = U.UsuarioID
    WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin
        AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID)
    ORDER BY O.OrdenFecha DESC, O.OrdenID DESC

    SELECT
        OD.OrdenID, M.MaterialNombre AS Material, OD.CantidadConsumida AS Cantidad, M.MaterialMedida AS Unidad
    FROM Inventario.OrdenProduccionDetalle OD
    INNER JOIN Inventario.Material M ON OD.MaterialCodigo = M.MaterialCodigo
    WHERE OD.OrdenID IN (SELECT O.OrdenID FROM Inventario.OrdenProduccion O WHERE O.OrdenFecha BETWEEN @FechaInicio AND @FechaFin AND (@UsuarioID IS NULL OR O.UsuarioID = @UsuarioID))
    ORDER BY OD.OrdenID, M.MaterialNombre
END
GO

