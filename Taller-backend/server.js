const express = require('express');
const sql = require('mssql/msnodesqlv8');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

//CONEXIÓN A SQL SERVER CON AUTENTICACIÓN DE WINDOWS
const dbConfig = {
    connectionString: 'Driver={ODBC Driver 17 for SQL Server};Server=localhost\\MSSQLSERVER01;Database=DB_TallerCalzado;Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;'
};

// Conectar una sola vez
let poolPromise = sql.connect(dbConfig)
    .then(pool => {
        console.log(' Conectado a SQL Server mediante Autenticación de Windows');
        return pool;
    })
    .catch(err => {
        console.error(' Error de conexión:', err);
    });

// Tu endpoint para el Dashboard
app.get('/api/dashboard/resumen', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute('Inventario.USP_Dashboard_ObtenerResumen');
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).send(err.message);
    }
});
// =========================================================================
// Endpoint para la Actividad Reciente
// =========================================================================
app.get('/api/dashboard/actividad', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute('Inventario.USP_Dashboard_ListarActividadReciente');
        
        // SQL Server a veces guarda las filas en result.recordset o dentro del arreglo result.recordsets[0]
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        // Mapeamos los datos para asegurar que no viajen formatos incompatibles
        const datosLimpios = filas.map(item => ({
            Fecha: item.Fecha,
            Tipo: item.Tipo,
            Descripcion: item.Descripcion,
            Cantidad: item.Cantidad ? item.Cantidad.toString() : '0',
            Movimiento: item.Movimiento,
            Encargado: item.Encargado
        }));

        // Enviamos la lista procesada a Flutter
        res.json(datosLimpios);
    } catch (err) {
        console.error("Error detectado en el endpoint de actividad:", err.message);
        res.status(500).send(err.message);
    }
});

// =========================================================================
//Endpoint para MOSTRAR INVENTARIO DE MATERIALES 
// =========================================================================
app.get('/api/materiales', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute('Inventario.USP_Inventario_ListarMateriales');
        
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        // Mapeamos 
        const datosLimpios = filas.map(item => ({
            codigo: item.codigo.trim(),
            insumo: item.insumo,
            categoria: item.categoria,
            cantidad: item.cantidad ? parseFloat(item.cantidad) : 0.0,
            medida: item.medida,
            proveedor: item.proveedor || 'Sin Proveedor'
        }));

        res.json(datosLimpios);
    } catch (err) {
        console.error("Error en endpoint de materiales:", err.message);
        res.status(500).send(err.message);
    }
});

// =========================================================================
// ENDPOINT: AlERTAS DE BAJO STOCK
// =========================================================================
app.get('/api/materiales/alertas', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().execute('Inventario.USP_Inventario_ListarAlertasBajoStock');
        
        const filas = result.recordset || (result.recordsets && result.recordsets[0]) || [];
        
        // Mapeamos los datos igual que en el listado general
        const alertasLimpias = filas.map(item => ({
            codigo: item.codigo.trim(),
            insumo: item.insumo,
            categoria: item.categoria,
            cantidad: item.cantidad ? parseFloat(item.cantidad) : 0.0,
            medida: item.medida,
            proveedor: item.proveedor || 'Sin Proveedor'
        }));

        res.json(alertasLimpias);
    } catch (err) {
        console.error("Error en endpoint de alertas de stock:", err.message);
        res.status(500).send(err.message);
    }
});


// =========================================================================
// ENDPOINT: INSERTAR O INCREMENTAR MATERIAL
// =========================================================================
app.post('/api/materiales', async (req, res) => {
    const { insumo, categoria, cantidad, medida, proveedor } = req.body;

    // Validación
    if (!insumo || !categoria || !medida) {
        return res.status(400).json({ 
            error: 'Faltan campos obligatorios: insumo, categoria y medida son requeridos.' 
        });
    }

    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .input('MaterialNombre', sql.NVarChar(100), insumo)
            .input('MaterialCategoria', sql.NVarChar(50), categoria)
            .input('MaterialCantidad', sql.Decimal(10, 2), cantidad || 0.00)
            .input('MaterialMedida', sql.NVarChar(20), medida)
            .input('MaterialProveedor', sql.NVarChar(100), proveedor || null)
            .execute('Inventario.USP_Inventario_InsertarMaterial');

        const { CodigoResultado, Accion } = result.recordset[0];

        if (Accion === 'ACCION_SUMAR') {
            res.status(200).json({ 
                estatus: 'success',
                mensaje: `El insumo ya existía. Se incrementó el stock con éxito al código ${CodigoResultado.trim()}.`, 
                codigo: CodigoResultado.trim()
            });
        } else {
            res.status(201).json({ 
                estatus: 'created',
                mensaje: `Nuevo material registrado correctamente con el código ${CodigoResultado.trim()}.`, 
                codigo: CodigoResultado.trim()
            });
        }

    } catch (err) {
        console.error("Error en el servidor al procesar el material:", err.message);
        res.status(500).send("Error interno del servidor: " + err.message);
    }
});

// =========================================================================
// ENDPOINT: EDITAR / ACTUALIZAR MATERIAL
// =========================================================================
app.put('/api/materiales', async (req, res) => {
    const { codigo, insumo, categoria, cantidad, medida, proveedor } = req.body;

    if (!codigo || !insumo || !categoria || !medida) {
        return res.status(400).json({ 
            error: 'Faltan campos obligatorios para actualizar el material.' 
        });
    }

    try {
        const pool = await poolPromise;
        await pool.request()
            .input('MaterialCodigo', sql.NChar(8), codigo)
            .input('MaterialNombre', sql.NVarChar(100), insumo)
            .input('MaterialCategoria', sql.NVarChar(50), categoria)
            .input('MaterialCantidad', sql.Decimal(10, 2), cantidad || 0.00)
            .input('MaterialMedida', sql.NVarChar(20), medida)
            .input('MaterialProveedor', sql.NVarChar(100), proveedor || null)
            .execute('Inventario.USP_Inventario_EditarMaterial');

        res.status(200).json({ 
            estatus: 'success',
            mensaje: 'Material actualizado correctamente en el taller.' 
        });

    } catch (err) {
        console.error("Error en el servidor al editar material:", err.message);
        res.status(400).send(err.message);
    }
});


// =========================================================================
// ENDPOINT: ELIMINACIÓN DE MATERIAL
// =========================================================================
app.delete('/api/materiales/:codigo', async (req, res) => {
    const { codigo } = req.params;

    if (!codigo) {
        return res.status(400).json({ error: 'El código del material es requerido.' });
    }

    try {
        const pool = await poolPromise;
        await pool.request()
            .input('MaterialCodigo', sql.NChar(8), codigo)
            .execute('Inventario.USP_Inventario_EliminarMaterial');

        res.status(200).json({ 
            estatus: 'success',
            mensaje: 'Material eliminado correctamente en el taller.' 
        });

    } catch (err) {
        console.error("Error al eliminar material:", err.message);
        res.status(400).send(err.message);
    }
});

// =========================================================================
// ENDPOINT: LISTAR CALZADOS DISPONIBLES
// =========================================================================
app.get('/api/calzados', async (req, res) => {
    try {
        const pool = await poolPromise;
        
        // Ejecutamos el SP
        const result = await pool.request()
            .execute('Inventario.USP_Inventario_ListarCalzado');

        res.status(200).json(result.recordset);

    } catch (err) {
        console.error("Error al listar calzado:", err.message);
        res.status(400).send(err.message);
    }
});



// Levantar el servidor
app.listen(3000, '0.0.0.0', () => {
    console.log('API lista en el puerto 3000');
});