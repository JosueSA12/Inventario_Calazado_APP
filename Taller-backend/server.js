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
        console.log("Conectado exitosamente a la base de datos de SQL Server en la nube!");
        app.set('pool', pool);
        return pool;
    })
    .catch(err => {
        console.error("Error al intentar conectar con la nube:", err);
    });

// =========================================================================
// SEGURIDAD
// =========================================================================

// Login
app.post("/api/seguridad/login", async (req, res) => {
    const { usuarioInput, usuarioPassword } = req.body;

    if (!usuarioInput || !usuarioPassword) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usuario/correo y la contrasena son requeridos."
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

// Restablecer contrasena
app.post("/api/seguridad/restablecer-password", async (req, res) => {
    const { usuarioLogin, nuevaPassword } = req.body;

    if (!usuarioLogin || !nuevaPassword) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El usuario y la nueva contrasena son obligatorios."
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
                mensaje: respuestaSP ? respuestaSP.Mensaje : "No se pudo restablecer la contrasena."
            });
        }
    } catch (err) {
        console.error("Error en el servidor al restablecer contrasena:", err.message);
        return res.status(500).json({
            estatus: "error",
            mensaje: "Error de servidor: " + err.message
        });
    }
});

// =========================================================================
// DASHBOARD
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
            Id: item.Id,
            Fecha: item.Fecha,
            Tipo: item.Tipo,
            Descripcion: item.Descripcion,
            Cantidad: item.Cantidad ? item.Cantidad.toString() : "0",
            Movimiento: item.Movimiento,
            Encargado: item.Encargado,
            ReferenciaId: item.ReferenciaId ?? item.Id,
            ReferenciaTipo: item.ReferenciaTipo ?? item.Tipo
        }));

        res.json(datosLimpios);
    } catch (err) {
        console.error("Error en /api/dashboard/actividad:", err.message);
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

app.get("/api/produccion/detalle/:ordenID", async (req, res) => {
    const { ordenID } = req.params;

    if (!ordenID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El ordenID es obligatorio."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("OrdenID", sql.Int, parseInt(ordenID))
            .execute("Inventario.USP_Produccion_ObtenerDetalle");

        const cabecera = result.recordsets[0] || [];
        const materiales = result.recordsets[1] || [];

        if (cabecera.length === 0) {
            return res.status(404).json({
                estatus: "error",
                mensaje: "Orden de producción no encontrada."
            });
        }

        res.status(200).json({
            estatus: "success",
            data: {
                orden: cabecera[0],
                materiales: materiales
            }
        });
    } catch (err) {
        console.error("Error en /api/produccion/detalle:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al obtener detalle de producción: " + err.message
        });
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
            Id: item.Id,
            Fecha: item.Fecha,
            Tipo: item.Tipo,
            Descripcion: item.Descripcion,
            Cantidad: item.Cantidad ? item.Cantidad.toString() : "0",
            Movimiento: item.Movimiento,
            Encargado: item.Encargado,
            ReferenciaId: item.ReferenciaId ?? item.Id,
            ReferenciaTipo: item.ReferenciaTipo ?? item.Tipo
        }));

        res.json(datosLimpios);
    } catch (err) {
        console.error("Error en /api/dashboard/filtrar-movimientos:", err.message);
        res.status(500).send(err.message);
    }
});



// =========================================================================
// MATERIALES
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
                mensaje: "Se incremento el stock con exito",
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
// CALZADO
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
            mensaje: "Error en el servidor al obtener el catalogo de calzados: " + err.message
        });
    }
});

// =========================================================================
// PRODUCCION
// =========================================================================

// Obtener calzados con receta
app.get("/api/produccion/calzados-con-receta", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .query(`
                SELECT DISTINCT
                    C.CalzadoCodigo,
                    C.CalzadoModelo,
                    C.CalzadoTipo,
                    C.CalzadoColor,
                    C.CalzadoTalla,
                    C.CalzadoStock,
                    C.CalzadoPrecioVenta
                FROM Inventario.Calzado C
                INNER JOIN Inventario.CalzadoMaterial CM 
                    ON C.CalzadoCodigo = CM.CalzadoCodigo
                WHERE C.CalzadoEstado = 'A'
                ORDER BY C.CalzadoModelo, C.CalzadoTalla
            `);

        res.status(200).json({
            estatus: "success",
            data: result.recordset
        });
    } catch (err) {
        console.error("Error en /api/produccion/calzados-con-receta:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al obtener calzados con receta: " + err.message
        });
    }
});

// Obtener receta de calzado
app.get("/api/produccion/receta/:calzadoCodigo", async (req, res) => {
    const { calzadoCodigo } = req.params;

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
            .execute("Inventario.USP_Produccion_ObtenerReceta");

        res.status(200).json({
            estatus: "success",
            data: result.recordset
        });
    } catch (err) {
        console.error("Error en /api/produccion/receta:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al obtener receta: " + err.message
        });
    }
});

// Validar stock para produccion
app.post("/api/produccion/validar-stock", async (req, res) => {
    const { calzadoCodigo, cantidadPares } = req.body;

    if (!calzadoCodigo) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El codigo del calzado es obligatorio."
        });
    }

    if (!cantidadPares || parseInt(cantidadPares) <= 0) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "La cantidad de pares debe ser mayor a 0."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
            .input("CantidadPares", sql.Int, parseInt(cantidadPares))
            .execute("Inventario.USP_Produccion_ObtenerRecetaConStock");

        const materiales = result.recordset || [];
        const hayStockInsuficiente = materiales.some(m => m.StockSuficiente === 0);

        res.status(200).json({
            estatus: "success",
            data: {
                materiales,
                hayStockInsuficiente,
                puedeProducir: !hayStockInsuficiente && materiales.length > 0
            }
        });
    } catch (err) {
        console.error("Error en /api/produccion/validar-stock:", err.message);
        res.status(500).json({
            estatus: "error",
            mensaje: "Error al validar stock: " + err.message
        });
    }
});

// Registrar produccion 
app.post("/api/produccion/registrar", async (req, res) => {
    const { calzadoCodigo, cantidadPares, usuarioID } = req.body;

    if (!calzadoCodigo) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "El codigo del calzado es obligatorio."
        });
    }

    if (!cantidadPares || parseInt(cantidadPares) <= 0) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "La cantidad de pares debe ser mayor a 0."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
            .input("CantidadPares", sql.Int, parseInt(cantidadPares))
            .input("UsuarioID", sql.NChar(8), usuarioID || "USR00001")
            .execute("Inventario.USP_Produccion_RegistrarAutomatica");

        const respuestaSP = result.recordset[0];

        if (respuestaSP && respuestaSP.Resultado === "EXITO") {
            return res.status(200).json({
                estatus: "success",
                mensaje: respuestaSP.Mensaje,
                data: {
                    ordenID: respuestaSP.OrdenID,
                    cantidadPares: respuestaSP.CantidadPares
                }
            });
        } else {
            return res.status(400).json({
                estatus: "error",
                mensaje: respuestaSP?.Mensaje || "No se pudo completar la produccion."
            });
        }
    } catch (err) {
        console.error("Error en /api/produccion/registrar-automatica:", err.message);

        if (err.message.includes("Stock insuficiente")) {
            return res.status(400).json({
                estatus: "error",
                mensaje: err.message,
                tipo: "STOCK_INSUFICIENTE"
            });
        }

        if (err.message.includes("receta de materiales")) {
            return res.status(400).json({
                estatus: "error",
                mensaje: err.message,
                tipo: "SIN_RECETA"
            });
        }

        return res.status(500).json({
            estatus: "error",
            mensaje: "Error interno en el servidor: " + err.message
        });
    }
});

// =========================================================================
// CARRITO
// =========================================================================

app.post("/api/carrito/agregar", async (req, res) => {
    const { usuarioID, calzadoCodigo, cantidad } = req.body;

    if (!usuarioID || !calzadoCodigo || !cantidad) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parametros: usuarioID, calzadoCodigo y cantidad son obligatorios."
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input("UsuarioID", sql.NChar(8), usuarioID)
            .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
            .input("Cantidad", sql.Int, parseInt(cantidad))
            .execute("Inventario.USP_Carrito_AgregarProducto");

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

app.put("/api/carrito/actualizar", async (req, res) => {
    const { usuarioID, detalleID, nuevaCantidad } = req.body;

    if (!usuarioID || !detalleID || nuevaCantidad === undefined) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parametros: usuarioID, detalleID y nuevaCantidad son obligatorios."
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

app.delete("/api/carrito/eliminar", async (req, res) => {
    const { usuarioID, detalleID } = req.body;

    if (!usuarioID || !detalleID) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parametros: usuarioID y detalleID son obligatorios."
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
// VENTAS
// =========================================================================

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

// =========================================================================
// REPORTES
// =========================================================================

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
        console.error('Error en reporte produccion:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

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
        console.error('Error en detalle produccion:', error);
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
});

// =========================================================================
// ENCENDIDO DEL SERVIDOR
// =========================================================================

const PUERTO = 3000;
app.listen(PUERTO, "0.0.0.0", () => {
    console.log(`API activa y escuchando peticiones en el puerto ${PUERTO}`);
});