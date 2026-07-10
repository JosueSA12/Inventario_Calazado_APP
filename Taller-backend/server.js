const express = require("express");
const cors = require("cors");
const sql = require("mssql");
//const sql = require("mssql/msnodesqlv8");

const app = express();
app.use(express.json());
app.use(cors());

// =========================================================================
// Opciones de Conexión a la Base de Datos
// =========================================================================

/*
// Opción A: CONEXIÓN A SQL SERVER CON AUTENTICACIÓN DE WINDOWS (LOCAL)
const dbConfig = {
    connectionString: "Driver={ODBC Driver 17 for SQL Server};Server=localhost\\\\MSSQLSERVER01;Database=DB_TallerCalzado;Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;"
};

let poolPromise = sql.connect(dbConfig)
    .then(pool => {
        console.log(" Conectado a SQL Server mediante Autenticación de Windows");
        return pool;
    })
    .catch(err => {
        console.error(" Error de conexión local:", err);
    });
*/

// Opción B: BASE DE DATOS EN LA NUBE 
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
        return pool;
    })
    .catch(err => {
        console.error("Error al intentar conectar con la nube:", err);
    });


// =========================================================================
// MÓDULO 1: DASHBOARD
// =========================================================================

// Endpoint: Obtener Resumen General Numérico
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

// Endpoint: Listar Actividad Reciente (Materiales y Calzados)
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


// =========================================================================
// MÓDULO 2: GESTIÓN DE MATERIALES (INSUMOS)
// =========================================================================

// Endpoint: Listar todos los Materiales Activos
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

// Endpoint: Listar Materiales con Alerta de Bajo Stock
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

// Endpoint: Obtener Lista de Materiales para Selectores (Dropdowns)
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

// Endpoint: Insertar o Incrementar Stock de Material
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

// Endpoint: Editar Datos de un Material
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

// Endpoint: Desactivar / Eliminar 
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

// Endpoint: Listar todos los Calzados Disponibles
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

// Endpoint: Obtener Lista de Calzados Activos para Selectores (Dropdowns)
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

// Endpoint: Registrar Venta
app.post("/api/calzado/venta-multiple", async (req, res) => {
    const { usuarioID, productos } = req.body;

    if (!usuarioID || !productos || !Array.isArray(productos) || productos.length === 0) {
        return res.status(400).json({
            estatus: "error",
            mensaje: "Faltan parámetros obligatorios o el carrito de productos está vacío."
        });
    }

    const pool = await poolPromise;
    const transaction = new sql.Transaction(pool);

    try {
        await transaction.begin();

        for (const item of productos) {
            const { calzadoCodigo, cantidad } = item;
            const cantidadInt = parseInt(cantidad, 10);
            
            if (isNaN(cantidadInt) || cantidadInt <= 0) {
                throw new Error(`La cantidad para el calzado ${calzadoCodigo} debe ser un entero mayor a cero.`);
            }

            const request = new sql.Request(transaction);
            await request
                .input("CalzadoCodigo", sql.NChar(8), calzadoCodigo)
                .input("CantidadAVender", sql.Int, cantidadInt)
                .input("UsuarioID", sql.NChar(8), usuarioID)
                .execute("Inventario.USP_Calzado_RegistrarVenta");
        }

        await transaction.commit();
        res.status(200).json({
            estatus: "success",
            mensaje: "¡Venta múltiple registrada con éxito en el sistema!"
        });
    } catch (err) {
        if (transaction._id !== null) {
            await transaction.rollback();
        }
        console.error("Error en venta múltiple (Rollback aplicado):", err.message);
        res.status(400).json({
            estatus: "error",
            mensaje: `Error al procesar la venta: ${err.message}`
        });
    }
});


// =========================================================================
// MÓDULO 4: PRODUCCIÓN EN TALLER
// =========================================================================

// Endpoint: Registrar Orden de Producción de Calzado (JSON)
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
// Encendido del Servidor HTTP
// =========================================================================
const PUERTO = 3000;
app.listen(PUERTO, "0.0.0.0", () => {
   console.log(`🌐 API activa y escuchando peticiones en el puerto ${PUERTO}`);
});