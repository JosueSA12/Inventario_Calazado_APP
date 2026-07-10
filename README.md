# 👟 Sistema de Gestión de Inventario y Producción - Taller de Calzado

¡Bienvenido al sistema de control de inventario y producción en tiempo real para talleres de calzado! Este es un proyecto con arquitectura cliente-servidor real, diseñado para optimizar el flujo de fabricación de lotes, catalogación de modelos, abastecimiento de insumos y registro automatizado de ventas.

---

## 📐 Arquitectura del Sistema

El proyecto está compuesto por tres capas principales conectadas a través de Internet:

1. **📱 Aplicación Móvil (Cliente):** Construida en **Flutter**, ofrece una interfaz intuitiva con animaciones fluidas, dashboards dinámicos y control visual inteligente de stock crítico.
2. **🌐 Servidor API REST (Backend):** Desarrollado en **Node.js con Express**, encargado de gestionar la lógica de negocio de manera segura y exponer los endpoints consumidos por la app móvil.
3. **🗄️ Base de Datos (Nube):** Aloja un motor de **SQL Server** en un servidor remoto (`site4now.net`). Implementa restricciones relacionales avanzadas, disparadores (`Constraints`) y Procedimientos Almacenados (`Stored Procedures`) transaccionales con soporte JSON para recetas de fabricación.

---

## ✨ Características Principales

* **📊 Dashboard en Tiempo Real:** Métricas clave (KPIs) con el total de modelos, cantidad de materiales e indicadores visuales de alertas de stock bajo.
* **📜 Historial de Actividad Automatizado:** Cada ingreso, consumo en taller, descarte o venta genera un registro cronológico inmutable respaldado por llaves foráneas.
* **🧪 Módulo de Producción Inteligente (JSON):** Permite registrar la fabricación de un calzado enviando la receta de materiales en formato JSON. El motor SQL Server deduce automáticamente el inventario de insumos correspondientes usando `OPENJSON` en una transacción segura.
* **🛒 Carrito de Ventas Múltiples:** Registro transaccional seguro de salidas de calzado terminado con rollback automático ante quiebres de stock imprevistos.

---

## 🛠️ Tecnologías Utilizadas

* **Frontend:** Flutter (Dart), PandaBar (Navigation), Shimmer Loading, HTTP.
* **Backend:** Node.js, Express, Cors, Mssql (Driver oficial para SQL Server).
* **Database:** SQL Server 2019+, T-SQL, Programación Transaccional, JSON mapping.

---

## 🚀 Guía de Instalación y Configuración

### 1. Base de Datos (SQL Server)
Si deseas restaurar o limpiar la base de datos remota/local:
* Ejecuta primero el script de limpieza `DROP TABLE` respetando las dependencias de llaves foráneas.
* Ejecuta el script de estructura e inserción de datos iniciales en tu gestor (SSMS) para desplegar los esquemas `Seguridad` e `Inventario`, junto con los 24 calzados iniciales, 16 insumos base y los Procedimientos Almacenados (`USP_`).

### 2. Backend (Node.js API REST)
Navega a la carpeta de tu servidor, instala las dependencias y enciende el servicio:
```bash
# Instalar módulos de Node.js
npm install

# Iniciar el servidor API
node server.js
