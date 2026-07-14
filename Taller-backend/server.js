const express = require("express");
const cors = require("cors");
const sql = require("mssql");

const app = express();
app.use(express.json());
app.use(cors());

// =========================================================================
// Opciones de Conexión a la Base de Datos
// =========================================================================
const dbConfig = {
    user: 'db_acbcc3_dbtaller_admin',
    password: '74532960josue',
    server: 'sql9001.site4now.net', 
    database: 'db_acbcc3_dbtaller',
    port: 1433,
    options: {
        encrypt: true, 
        trustServerCertificate: true 
    }
};

let poolPromise = sql.connect(dbConfig)
    .then(pool => {
        console.log("¡Conectado exitosamente a la base de datos de SQL Server en la nube!");
        app.set('pool', pool);
        return pool;
    })
    .catch(err => {
        console.error("Error al intentar conectar con la nube:", err);
    });

// =========================================================================
// ENDPOINT: INICIAR SESIÓN (LOGIN)
// =========================================================================
app.post("/api/seguridad/login", async (req, res) => {
    const { usuarioInput, usuarioPassword } = req.body;

    if (!usuarioInput || !usuarioPassword) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usario/correo y la contraseña son requeridos."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioInput", sql.NVarChar(100), usuarioInput)
            .input("UsuarioPassword", sql.NVarChar(50), usuarioPassword)
            .execute("Seguridad.USP_Usuario_ValidarAcceso");

        const respuestaSP = result.recordset[0];

        if (respuestaSP && respuestaSP.Resultado === "EXITO") {
            return res.status(200).json({
                estatus: "success",
                mensaje: "Acceso concedido.",
                usuario: {
                    id: respuestaSP.UsuarioID,
                    nombre: respuestaSP.UsuarioNombre,
                    login: respuestaSP.UsuarioLogin,
                    correo: respuestaSP.UsuarioCorreo,
                    tipo: respuestaSP.TipoUsuarioCodigo
                }
            });
        } else {
            return res.status(401).json({
                estatus: "error",
                mensaje: respuestaSP ? respuestaSP.Mensaje : "Credenciales incorrectas."
            });
        }
    } catch (err) {
        console.error("Error en el servidor al validar acceso:", err.message);
        return res.status(500).json({
            estatus: "error",
            mensaje: "Error interno en el servidor: " + err.message
        });
    }
});

// =========================================================================
// ENDPOINT: RESTABLECER CONTRASEÑA
// =========================================================================
app.post("/api/seguridad/restablecer-password", async (req, res) => {
    const { usuarioLogin, nuevaPassword } = req.body;

    if (!usuarioLogin || !nuevaPassword) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usuario y la nueva contraseña son obligatorios."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioLogin", sql.NVarChar(20), usuarioLogin)
            .input("NuevaPassword", sql.NVarChar(50), nuevaPassword)
            .execute("Seguridad.USP_Usuario_RestablecerPassword");

        const respuestaSP = result.recordset[0];

        if (respuestaSP && respuestaSP.Resultado === "EXITO") {
            return res.status(200).json({
                estatus: "success",
                mensaje: respuestaSP.Mensaje
            });
        } else {
            return res.status(400).json({
                estatus: "error",
                mensaje: respuestaSP ? respuestaSP.Mensaje : "No se pudo restablecer la contraseña."
            });
        }
    } catch (err) {
        console.error("Error en el servidor al restablecer contraseña:", err.message);
        return res.status(500).json({
            estatus: "error",
            mensaje: "Error de servidor: " + err.message
        });
    }
});

// =========================================================================
// MÓDULO 1: DASHBOARD
// =========================================================================

app.get("/api/dashboard/resumen", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Dashboard_ObtenerResumen");
        res.json(result.recordset[0]);
    } catch (err) {
        console.error("Error en /api/dashboard/resumen:", err.message);
        res.status(500).send(err.message);
    }
});

app.get("/api/dashboard/actividad", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Dashboard_ListarActividadReciente");
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        const datosLimpios = filas.map(item => ({
            Fecha: item.Fecha,
            Tipo: item.Tipo,
            Descripcion: item.Descripcion,
            Cantidad: item.Cantidad ? item.Cantidad.toString() : "0",
            Movimiento: item.Movimiento,
            Encargado: item.Encargado
        }));

        res.json(datosLimpios);
    } catch (err) {
        console.error("Error en /api/dashboard/actividad:", err.message);
        res.status(500).send(err.message);
    }
});

app.get("/api/dashboard/filtrar-movimientos", async (req, res) => {
    const { tipo } = req.query;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("TipoFiltro", sql.NVarChar(20), tipo || null)
            .execute("Inventario.USP_Dashboard_FiltrarMovimientos");
        
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        const datosLimpios = filas.map(item => ({
            Fecha: item.Fecha,
            Tipo: item.Tipo,
            Descripcion: item.Descripcion,
            Cantidad: item.Cantidad ? item.Cantidad.toString() : "0",
            Movimiento: item.Movimiento,
            Encargado: item.Encargado
        }));

        res.json(datosLimpios);
    } catch (err) {
        console.error("Error en /api/dashboard/filtrar-movimientos:", err.message);
        res.status(500).send(err.message);
    }
});

app.get("/api/dashboard/kpis-filtro", async (req, res) => {
    const { tipo } = req.query;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("TipoFiltro", sql.NVarChar(20), tipo || null)
            .execute("Inventario.USP_Dashboard_ObtenerKPIsPorFiltro");
        
        const kpis = result.recordset[0];
        res.json(kpis);
    } catch (err) {
        console.error("Error en /api/dashboard/kpis-filtro:", err.message);
        res.status(500).send(err.message);
    }
});

// =========================================================================
// MÓDULO 2: GESTIÓN DE MATERIALES (INSUMOS)
// =========================================================================

app.get("/api/materiales", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Inventario_ListarMateriales");
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        const datosLimpios = filas.map(item => ({
            codigo: item.codigo.trim(),
            insumo: item.insumo,
            categoria: item.categoria,
            cantidad: item.cantidad ? parseFloat(item.cantidad) : 0.0,
            medida: item.medida,
            proveedor: item.proveedor || "Sin Proveedor"
        }));

        res.json(datosLimpios);
    } catch (err) {
        console.error("Error en /api/materiales:", err.message);
        res.status(500).send(err.message);
    }
});

app.get("/api/materiales/alertas", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Inventario_ListarAlertasBajoStock");
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        const alertasLimpias = filas.map(item => ({
            codigo: item.codigo.trim(),
            insumo: item.insumo,
            categoria: item.categoria,
            cantidad: item.cantidad ? parseFloat(item.cantidad) : 0.0,
            medida: item.medida,
            proveedor: item.proveedor || "Sin Proveedor"
        }));

        res.json(alertasLimpias);
    } catch (err) {
        console.error("Error en /api/materiales/alertas:", err.message);
        res.status(500).send(err.message);
    }
});

app.get("/api/materiales/dropdown", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Material_ListarParaDropdown");
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error("Error en /api/materiales/dropdown:", err.message);
        res.status(500).json({ 
            error: "Error interno en el servidor de calzado", 
            detalles: err.message 
        });
    }
});

app.post("/api/materiales", async (req, res) => {
    const { insumo, categoria, cantidad, medida, proveedor, usuarioID } = req.body;

    if (!insumo || !categoria || !medida || !usuarioID) {
        return res.status(400).json({ 
            error: "Faltan campos obligatorios: insumo, categoria, medida y usuarioID son requeridos." 
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("MaterialNombre", sql.NVarChar(100), insumo)
            .input("MaterialCategoria", sql.NVarChar(50), categoria)
            .input("MaterialCantidad", sql.Decimal(10, 2), cantidad || 0.00)
            .input("MaterialMedida", sql.NVarChar(20), medida)
            .input("MaterialProveedor", sql.NVarChar(100), proveedor || null)
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .execute("Inventario.USP_Inventario_InsertarMaterial");

        const { CodigoResultado, Accion } = result.recordset[0];

        if (Accion === "ACCION_SUMAR") {
            res.status(200).json({ 
                estatus: "success",
                mensaje: "Se incrementó el stock con éxito", 
                codigo: CodigoResultado.trim()
            });
        } else {
            res.status(201).json({ 
                estatus: "created",
                mensaje: "Nuevo material registrado correctamente.", 
                codigo: CodigoResultado.trim()
            });
        }
    } catch (err) {
        console.error("Error en POST /api/materiales:", err.message);
        res.status(500).send("Error interno del servidor: " + err.message);
    }
});

app.put("/api/materiales", async (req, res) => {
    const { codigo, insumo, categoria, cantidad, medida, proveedor } = req.body;

    if (!codigo || !insumo || !categoria || !medida) {
        return res.status(400).json({ 
            error: "Faltan campos obligatorios para actualizar el material." 
        });
    }

    try {
        const pool = await poolPromise;
        await pool.request()
            .input("MaterialCodigo", sql.NChar(8), codigo)
            .input("MaterialNombre", sql.NVarChar(100), insumo)
            .input("MaterialCategoria", sql.NVarChar(50), categoria)
            .input("MaterialCantidad", sql.Decimal(10, 2), cantidad || 0.00)
            .input("MaterialMedida", sql.NVarChar(20), medida)
            .input("MaterialProveedor", sql.NVarChar(100), proveedor || null)
            .execute("Inventario.USP_Inventario_EditarMaterial");

        res.status(200).json({ 
            estatus: "success",
            mensaje: "Material actualizado correctamente." 
        });
    } catch (err) {
        console.error("Error en PUT /api/materiales:", err.message);
        res.status(400).send(err.message);
    }
});

app.delete("/api/materiales/:codigo", async (req, res) => {
    const { codigo } = req.params;    
    const { usuarioID } = req.body; 

    if (!usuarioID) {
        return res.status(400).json({ 
            estatus: "error", 
            mensaje: "El usuarioID es requerido para registrar el movimiento en el historial." 
        });
    }

    try {
        const pool = await poolPromise; 
        const result = await pool.request()
            .input("MaterialCodigo", sql.NChar(8), codigo)
            .input("UsuarioID", sql.NChar(8), usuarioID) 
            .execute("Inventario.USP_Inventario_EliminarMaterial");

        res.status(200).json({
            estatus: "success",
            mensaje: result.recordset[0].Mensaje
        });
    } catch (err) {
        console.error("Error en DELETE /api/materiales:", err.message);
        res.status(500).send("Error interno del servidor: " + err.message);
    }
});

// =========================================================================
// MÓDULO 3: CATÁLOGO Y VENTAS DE CALZADO
// =========================================================================

app.get("/api/calzados", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Inventario_ListarCalzado");
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error("Error en /api/calzados:", err.message);
        res.status(400).send(err.message);
    }
});

app.get("/api/calzado/lista-dropdown", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute("Inventario.USP_Calzado_ListarParaDropdown");
        res.status(200).json({
            estatus: "success",
            data: result.recordset
        });
    } catch (err) {
        console.error("Error en /api/calzado/lista-dropdown:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error en el servidor al obtener el catálogo de calzados: " + err.message
        });
    }
});


// =========================================================================
// MÓDULO 4: PRODUCCIÓN EN TALLER
// =========================================================================

app.post("/api/produccion/registrar", async (req, res) => {
    const { calzadoCodigo, cantidadPares, usuarioID, materiales } = req.body;

    if (!calzadoCodigo) {
        return res.status(400).json({ estatus: "error", mensaje: "El código del calzado es obligatorio." });
    }
    if (!cantidadPares || parseInt(cantidadPares) <= 0) {
        return res.status(400).json({ estatus: "error", mensaje: "La cantidad de pares debe ser mayor a 0." });
    }
    if (!materiales || !Array.isArray(materiales) || materiales.length === 0) {
        return res.status(400).json({ estatus: "error", mensaje: "Debe incluir al menos un insumo en la receta de fabricación." });
    }

    try {
        const pool = await poolPromise; 
        const materialesJSONTexto = JSON.stringify(materiales);
        
        const result = await pool.request()
            .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
            .input("CantidadPares", sql.Int, parseInt(cantidadPares))
            .input("UsuarioID", sql.NChar(8), usuarioID || "USR00001")
            .input("MaterialesJSON", sql.NVarChar(sql.MAX), materialesJSONTexto)
            .execute("Inventario.USP_ProduccionCalzado_Registrar");

        const respuestaSP = result.recordset[0];

        if (respuestaSP && respuestaSP.Resultado === "EXITO") {
            return res.status(200).json({
                estatus: "success",
                mensaje: respuestaSP.Mensaje
            });
        } else {
            return res.status(400).json({
                estatus: "error",
                mensaje: respuestaSP.Mensaje || "No se pudo completar el registro en la base de datos."
            });
        }
    } catch (err) {
        console.error("Error en el servidor al registrar producción:", err.message);
        
        if (err.message.includes("MaterialCantidadCK")) {
            return res.status(400).json({
                estatus: "error",
                mensaje: "Operación rechazada: Uno o más materiales seleccionados no cuentan con suficiente stock para cubrir esta orden."
            });
        }

        return res.status(500).json({
            estatus: "error",
            mensaje: "Error interno en el servidor: " + err.message
        });
    }
});

// =========================================================================
// MÓDULO 5: CARRITO DE COMPRAS
// =========================================================================

// Endpoint: Agregar producto al carrito
app.post("/api/carrito/agregar", async (req, res) => {
    const { usuarioID, calzadoCodigo, cantidad } = req.body;

    if (!usuarioID || !calzadoCodigo || !cantidad) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parámetros: usuarioID, calzadoCodigo y cantidad son obligatorios."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
            .input("Cantidad", sql.Int, parseInt(cantidad))
            .execute("Inventario.USP_Carrito_AgregarProducto");

        // El SP devuelve el detalle del carrito
        res.status(200).json({
            estatus: "success",
            mensaje: "Producto agregado al carrito correctamente.",
            data: result.recordset
        });
    } catch (err) {
        console.error("Error en /api/carrito/agregar:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al agregar producto al carrito: " + err.message
        });
    }
});

// Endpoint: Obtener carrito del usuario
app.get("/api/carrito/obtener", async (req, res) => {
    const { usuarioID } = req.query;

    if (!usuarioID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usuarioID es obligatorio."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .execute("Inventario.USP_Carrito_ObtenerDetalle");

        const cabecera = result.recordsets[0] || [];
        const detalle = result.recordsets[1] || [];

        // Verificar si hay carrito activo
        if (cabecera.length === 0) {
            return res.status(200).json({
                estatus: "success",
                mensaje: "No hay carrito activo.",
                data: {
                    carrito: null,
                    items: []
                }
            });
        }

        res.status(200).json({
            estatus: "success",
            data: {
                carrito: cabecera[0],
                items: detalle
            }
        });
    } catch (err) {
        console.error("Error en /api/carrito/obtener:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al obtener el carrito: " + err.message
        });
    }
});

// Endpoint: Actualizar cantidad de un producto en el carrito
app.put("/api/carrito/actualizar", async (req, res) => {
    const { usuarioID, detalleID, nuevaCantidad } = req.body;

    if (!usuarioID || !detalleID || nuevaCantidad === undefined) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parámetros: usuarioID, detalleID y nuevaCantidad son obligatorios."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .input("DetalleID", sql.BigInt, detalleID)
            .input("NuevaCantidad", sql.Int, parseInt(nuevaCantidad))
            .execute("Inventario.USP_Carrito_ActualizarCantidad");

        const cabecera = result.recordsets[0] || [];
        const detalle = result.recordsets[1] || [];

        res.status(200).json({
            estatus: "success",
            mensaje: "Cantidad actualizada correctamente.",
            data: {
                carrito: cabecera[0] || null,
                items: detalle
            }
        });
    } catch (err) {
        console.error("Error en /api/carrito/actualizar:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al actualizar cantidad: " + err.message
        });
    }
});

// Endpoint: Eliminar producto del carrito
app.delete("/api/carrito/eliminar", async (req, res) => {
    const { usuarioID, detalleID } = req.body;

    if (!usuarioID || !detalleID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parámetros: usuarioID y detalleID son obligatorios."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .input("DetalleID", sql.BigInt, detalleID)
            .execute("Inventario.USP_Carrito_EliminarProducto");

        const cabecera = result.recordsets[0] || [];
        const detalle = result.recordsets[1] || [];

        res.status(200).json({
            estatus: "success",
            mensaje: "Producto eliminado del carrito.",
            data: {
                carrito: cabecera[0] || null,
                items: detalle
            }
        });
    } catch (err) {
        console.error("Error en /api/carrito/eliminar:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al eliminar producto: " + err.message
        });
    }
});

// Endpoint: Limpiar carrito
app.delete("/api/carrito/limpiar", async (req, res) => {
    const { usuarioID } = req.body;

    if (!usuarioID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usuarioID es obligatorio."
        });
    }

    try {
        const pool = await poolPromise;
        await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .execute("Inventario.USP_Carrito_Limpiar");

        res.status(200).json({
            estatus: "success",
            mensaje: "Carrito limpiado correctamente."
        });
    } catch (err) {
        console.error("Error en /api/carrito/limpiar:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al limpiar el carrito: " + err.message
        });
    }
});

// Endpoint: Confirmar venta desde el carrito
app.post("/api/carrito/confirmar-venta", async (req, res) => {
    const { usuarioID } = req.body;

    if (!usuarioID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usuarioID es obligatorio."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .execute("Inventario.USP_Carrito_ConfirmarVenta");

        const venta = result.recordset[0];

        res.status(200).json({
            estatus: "success",
            mensaje: venta.Mensaje,
            data: {
                ventaID: venta.VentaID,
                carritoID: venta.CarritoID,
                total: venta.Total,
                fechaVenta: venta.FechaVenta
            }
        });
    } catch (err) {
        console.error("Error en /api/carrito/confirmar-venta:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al confirmar la venta: " + err.message
        });
    }
});

// =========================================================================
// MÓDULO 6: HISTORIAL DE VENTAS
// =========================================================================

// Endpoint: Obtener historial de ventas
app.get("/api/ventas/historial", async (req, res) => {
    const { usuarioID, fechaInicio, fechaFin, ventaID } = req.query;

    try {
        const pool = await poolPromise;
        const request = pool.request();

        if (usuarioID) {
            request.input("UsuarioID", sql.NChar(8), usuarioID);
        }
        if (fechaInicio) {
            request.input("FechaInicio", sql.Date, fechaInicio);
        }
        if (fechaFin) {
            request.input("FechaFin", sql.Date, fechaFin);
        }
        if (ventaID) {
            request.input("VentaID", sql.Int, parseInt(ventaID));
        }

        const result = await request.execute("Inventario.USP_Venta_ObtenerHistorial");

        res.status(200).json({
            estatus: "success",
            data: result.recordset
        });
    } catch (err) {
        console.error("Error en /api/ventas/historial:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al obtener historial de ventas: " + err.message
        });
    }
});

// Endpoint: Obtener detalle de una venta
app.get("/api/ventas/detalle/:ventaID", async (req, res) => {
    const { ventaID } = req.params;

    if (!ventaID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El ventaID es obligatorio."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("VentaID", sql.Int, parseInt(ventaID))
            .execute("Inventario.USP_Venta_ObtenerDetalle");

        const cabecera = result.recordsets[0] || [];
        const detalle = result.recordsets[1] || [];

        if (cabecera.length === 0) {
            return res.status(404).json({
                estatus: "error",
                mensaje: "Venta no encontrada."
            });
        }

        res.status(200).json({
            estatus: "success",
            data: {
                venta: cabecera[0],
                items: detalle
            }
        });
    } catch (err) {
        console.error("Error en /api/ventas/detalle:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al obtener detalle de la venta: " + err.message
        });
    }
});


// ==========================================
// REPORTE DE VENTAS
// ==========================================
app.post('/api/reportes/ventas', async (req, res) => {
    try {
        const { fechaInicio, fechaFin, tipoFiltro, usuarioID } = req.body;
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('FechaInicio', sql.Date, fechaInicio || null)
            .input('FechaFin', sql.Date, fechaFin || null)
            .input('TipoFiltro', sql.NVarChar(20), tipoFiltro || 'MES')
            .input('UsuarioID', sql.NChar(8), usuarioID || null)
            .execute('Inventario.USP_Reporte_Ventas');

        // El SP devuelve 4 conjuntos de resultados
        const resumen = result.recordsets[0] || [];
        const topProductos = result.recordsets[1] || [];
        const ventasPorDia = result.recordsets[2] || [];
        const ventasPorTipo = result.recordsets[3] || [];

        res.json({
            success: true,
            data: {
                resumen: resumen[0] || {},
                topProductos,
                ventasPorDia,
                ventasPorTipo
            }
        });
    } catch (error) {
        console.error('Error en reporte ventas:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// ==========================================
// REPORTE DE PRODUCCIÓN
// ==========================================
app.post('/api/reportes/produccion', async (req, res) => {
    try {
        const { fechaInicio, fechaFin, tipoFiltro, usuarioID } = req.body;
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('FechaInicio', sql.Date, fechaInicio || null)
            .input('FechaFin', sql.Date, fechaFin || null)
            .input('TipoFiltro', sql.NVarChar(20), tipoFiltro || 'MES')
            .input('UsuarioID', sql.NChar(8), usuarioID || null)
            .execute('Inventario.USP_Reporte_Produccion');

        const resumen = result.recordsets[0] || [];
        const topModelos = result.recordsets[1] || [];
        const produccionPorDia = result.recordsets[2] || [];
        const consumoMateriales = result.recordsets[3] || [];

        res.json({
            success: true,
            data: {
                resumen: resumen[0] || {},
                topModelos,
                produccionPorDia,
                consumoMateriales
            }
        });
    } catch (error) {
        console.error('Error en reporte producción:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// ==========================================
// REPORTE COMPARATIVO
// ==========================================
app.post('/api/reportes/comparativo', async (req, res) => {
    try {
        const { fechaInicio, fechaFin } = req.body;
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('FechaInicio', sql.Date, fechaInicio || null)
            .input('FechaFin', sql.Date, fechaFin || null)
            .execute('Inventario.USP_Reporte_Comparativo');

        res.json({
            success: true,
            data: result.recordsets[0] || []
        });
    } catch (error) {
        console.error('Error en reporte comparativo:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// ==========================================
// REPORTE DE STOCK
// ==========================================
app.post('/api/reportes/stock', async (req, res) => {
    try {
        const { tipo } = req.body;
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('Tipo', sql.NVarChar(20), tipo || 'TODOS')
            .execute('Inventario.USP_Reporte_Stock');

        res.json({
            success: true,
            data: result.recordsets[0] || []
        });
    } catch (error) {
        console.error('Error en reporte stock:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// ==========================================
// REPORTE DE VENTAS DETALLADO (PDF)
// ==========================================
app.post('/api/reportes/ventas-detalle', async (req, res) => {
    try {
        const { fechaInicio, fechaFin, usuarioID } = req.body;
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('FechaInicio', sql.Date, fechaInicio || null)
            .input('FechaFin', sql.Date, fechaFin || null)
            .input('UsuarioID', sql.NChar(8), usuarioID || null)
            .execute('Inventario.USP_Reporte_Ventas_Detalle');

        res.json({
            success: true,
            data: result.recordsets[0] || []
        });
    } catch (error) {
        console.error('Error en detalle ventas:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// ==========================================
// REPORTE DE PRODUCCIÓN DETALLADO (PDF)
// ==========================================
app.post('/api/reportes/produccion-detalle', async (req, res) => {
    try {
        const { fechaInicio, fechaFin, usuarioID } = req.body;
        
        const pool = await poolPromise;
        const result = await pool.request()
            .input('FechaInicio', sql.Date, fechaInicio || null)
            .input('FechaFin', sql.Date, fechaFin || null)
            .input('UsuarioID', sql.NChar(8), usuarioID || null)
            .execute('Inventario.USP_Reporte_Produccion_Detalle');

        const cabecera = result.recordsets[0] || [];
        const materiales = result.recordsets[1] || [];

        res.json({
            success: true,
            data: {
                cabecera,
                materiales
            }
        });
    } catch (error) {
        console.error('Error en detalle producción:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// =========================================================================
// Encendido del Servidor HTTP
// =========================================================================
const PUERTO = 3000;
app.listen(PUERTO, "0.0.0.0", () => {
   console.log(`🌐 API activa y escuchando peticiones en el puerto ${PUERTO}`);
});