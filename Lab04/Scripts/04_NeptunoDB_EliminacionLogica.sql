/* ============================================================
   NeptunoDB - Eliminacion logica (campo Activo)
   Laboratorio 05 - ExecuteNonQuery
   ------------------------------------------------------------
   Requiere que 00, 01 y 02 ya se hayan ejecutado.
   Este script:
     1) Agrega la columna Activo BIT NOT NULL DEFAULT 1 a
        Productos, Categorias, Proveedores y Pedidos.
     2) Recrea los procedimientos de esas 4 entidades para que:
          - Los listados y busquedas solo devuelvan Activo = 1.
          - "Eliminar" haga UPDATE Activo = 0 en vez de DELETE.
          - "Crear" devuelva el ID generado por parametro OUTPUT
            (para poder invocarse con ExecuteNonQuery en vez de
            ExecuteScalar).
     3) Ajusta el reporte por rango de fechas para excluir
        pedidos con Activo = 0.
   Se puede volver a ejecutar sin problema (CREATE OR ALTER +
   verificacion de columna existente).
   ============================================================ */

USE NeptunoDB;
GO

/* ------------------------------------------------------------
   1) Columna Activo
   ------------------------------------------------------------ */

IF COL_LENGTH('dbo.Categorias', 'Activo') IS NULL
    ALTER TABLE dbo.Categorias ADD Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo DEFAULT (1);
GO

IF COL_LENGTH('dbo.Proveedores', 'Activo') IS NULL
    ALTER TABLE dbo.Proveedores ADD Activo BIT NOT NULL CONSTRAINT DF_Proveedores_Activo DEFAULT (1);
GO

IF COL_LENGTH('dbo.Productos', 'Activo') IS NULL
    ALTER TABLE dbo.Productos ADD Activo BIT NOT NULL CONSTRAINT DF_Productos_Activo DEFAULT (1);
GO

IF COL_LENGTH('dbo.Pedidos', 'Activo') IS NULL
    ALTER TABLE dbo.Pedidos ADD Activo BIT NOT NULL CONSTRAINT DF_Pedidos_Activo DEFAULT (1);
GO

/* ============================================================
   2) CATEGORIAS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoriaID, NombreCategoria, Descripcion
    FROM dbo.Categorias
    WHERE Activo = 1
    ORDER BY NombreCategoria;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_ObtenerPorId
    @CategoriaID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoriaID, NombreCategoria, Descripcion
    FROM dbo.Categorias
    WHERE CategoriaID = @CategoriaID AND Activo = 1;
END
GO

/* Crear ahora usa OUTPUT en vez de SELECT SCOPE_IDENTITY(),
   asi el repositorio lo invoca con ExecuteNonQuery. */
CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Crear
    @NombreCategoria NVARCHAR(30),
    @Descripcion     NVARCHAR(200) = NULL,
    @NuevoID         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Categorias (NombreCategoria, Descripcion)
        VALUES (@NombreCategoria, @Descripcion);

        SET @NuevoID = CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Actualizar
    @CategoriaID     INT,
    @NombreCategoria NVARCHAR(30),
    @Descripcion     NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Categorias
        SET NombreCategoria = @NombreCategoria,
            Descripcion     = @Descripcion
        WHERE CategoriaID = @CategoriaID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50101, 'La categoria no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* Eliminacion logica: ya no hace DELETE, actualiza Activo = 0. */
CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Eliminar
    @CategoriaID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Categorias
        SET Activo = 0
        WHERE CategoriaID = @CategoriaID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50103, 'La categoria no existe o ya fue eliminada.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   3) PROVEEDORES
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion,
           Ciudad, CodigoPostal, Pais, Telefono, Fax
    FROM dbo.Proveedores
    WHERE Activo = 1
    ORDER BY CompaniaNombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_ObtenerPorId
    @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion,
           Ciudad, CodigoPostal, Pais, Telefono, Fax
    FROM dbo.Proveedores
    WHERE ProveedorID = @ProveedorID AND Activo = 1;
END
GO

/* Listado de proveedores buscando por nombreContacto y ciudad.
   Solo debe mostrar registros con Activo = 1. */
CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Buscar
    @NombreContacto NVARCHAR(40) = NULL,
    @Ciudad         NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@NombreContacto, ''))) = '' SET @NombreContacto = NULL;
    IF LTRIM(RTRIM(ISNULL(@Ciudad, ''))) = '' SET @Ciudad = NULL;

    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion,
           Ciudad, CodigoPostal, Pais, Telefono, Fax
    FROM dbo.Proveedores
    WHERE Activo = 1
      AND (@NombreContacto IS NULL OR NombreContacto LIKE '%' + @NombreContacto + '%')
      AND (@Ciudad IS NULL OR Ciudad LIKE '%' + @Ciudad + '%')
    ORDER BY CompaniaNombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Crear
    @CompaniaNombre NVARCHAR(60),
    @NombreContacto NVARCHAR(40) = NULL,
    @CargoContacto  NVARCHAR(40) = NULL,
    @Direccion      NVARCHAR(80) = NULL,
    @Ciudad         NVARCHAR(30) = NULL,
    @CodigoPostal   NVARCHAR(10) = NULL,
    @Pais           NVARCHAR(30) = NULL,
    @Telefono       NVARCHAR(24) = NULL,
    @Fax            NVARCHAR(24) = NULL,
    @NuevoID        INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Proveedores
            (CompaniaNombre, NombreContacto, CargoContacto, Direccion, Ciudad,
             CodigoPostal, Pais, Telefono, Fax)
        VALUES
            (@CompaniaNombre, @NombreContacto, @CargoContacto, @Direccion, @Ciudad,
             @CodigoPostal, @Pais, @Telefono, @Fax);

        SET @NuevoID = CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Actualizar
    @ProveedorID    INT,
    @CompaniaNombre NVARCHAR(60),
    @NombreContacto NVARCHAR(40) = NULL,
    @CargoContacto  NVARCHAR(40) = NULL,
    @Direccion      NVARCHAR(80) = NULL,
    @Ciudad         NVARCHAR(30) = NULL,
    @CodigoPostal   NVARCHAR(10) = NULL,
    @Pais           NVARCHAR(30) = NULL,
    @Telefono       NVARCHAR(24) = NULL,
    @Fax            NVARCHAR(24) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Proveedores
        SET CompaniaNombre = @CompaniaNombre,
            NombreContacto = @NombreContacto,
            CargoContacto  = @CargoContacto,
            Direccion      = @Direccion,
            Ciudad         = @Ciudad,
            CodigoPostal   = @CodigoPostal,
            Pais           = @Pais,
            Telefono       = @Telefono,
            Fax            = @Fax
        WHERE ProveedorID = @ProveedorID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50201, 'El proveedor no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* Eliminacion logica. */
CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Eliminar
    @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Proveedores
        SET Activo = 0
        WHERE ProveedorID = @ProveedorID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50203, 'El proveedor no existe o ya fue eliminado.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   4) PRODUCTOS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductoID, p.NombreProducto, p.ProveedorID, p.CategoriaID,
           p.CantidadPorUnidad, p.PrecioUnidad, p.UnidadesEnExistencia,
           p.UnidadesEnPedido, p.NivelDeReorden, p.Descontinuado,
           c.NombreCategoria,
           pr.CompaniaNombre AS NombreProveedor
    FROM dbo.Productos p
    LEFT JOIN dbo.Categorias  c  ON c.CategoriaID  = p.CategoriaID
    LEFT JOIN dbo.Proveedores pr ON pr.ProveedorID = p.ProveedorID
    WHERE p.Activo = 1
    ORDER BY p.NombreProducto;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_ObtenerPorId
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductoID, p.NombreProducto, p.ProveedorID, p.CategoriaID,
           p.CantidadPorUnidad, p.PrecioUnidad, p.UnidadesEnExistencia,
           p.UnidadesEnPedido, p.NivelDeReorden, p.Descontinuado,
           c.NombreCategoria,
           pr.CompaniaNombre AS NombreProveedor
    FROM dbo.Productos p
    LEFT JOIN dbo.Categorias  c  ON c.CategoriaID  = p.CategoriaID
    LEFT JOIN dbo.Proveedores pr ON pr.ProveedorID = p.ProveedorID
    WHERE p.ProductoID = @ProductoID AND p.Activo = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Crear
    @NombreProducto       NVARCHAR(60),
    @ProveedorID          INT = NULL,
    @CategoriaID          INT = NULL,
    @CantidadPorUnidad    NVARCHAR(30) = NULL,
    @PrecioUnidad         DECIMAL(10,2) = 0,
    @UnidadesEnExistencia SMALLINT = 0,
    @UnidadesEnPedido     SMALLINT = 0,
    @NivelDeReorden       SMALLINT = 0,
    @Descontinuado        BIT = 0,
    @NuevoID              INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @PrecioUnidad < 0
            THROW 50301, 'El precio unitario no puede ser negativo.', 1;

        INSERT INTO dbo.Productos
            (NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, PrecioUnidad,
             UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado)
        VALUES
            (@NombreProducto, @ProveedorID, @CategoriaID, @CantidadPorUnidad, @PrecioUnidad,
             @UnidadesEnExistencia, @UnidadesEnPedido, @NivelDeReorden, @Descontinuado);

        SET @NuevoID = CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Actualizar
    @ProductoID           INT,
    @NombreProducto       NVARCHAR(60),
    @ProveedorID          INT = NULL,
    @CategoriaID          INT = NULL,
    @CantidadPorUnidad    NVARCHAR(30) = NULL,
    @PrecioUnidad         DECIMAL(10,2) = 0,
    @UnidadesEnExistencia SMALLINT = 0,
    @UnidadesEnPedido     SMALLINT = 0,
    @NivelDeReorden       SMALLINT = 0,
    @Descontinuado        BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @PrecioUnidad < 0
            THROW 50302, 'El precio unitario no puede ser negativo.', 1;

        UPDATE dbo.Productos
        SET NombreProducto       = @NombreProducto,
            ProveedorID          = @ProveedorID,
            CategoriaID          = @CategoriaID,
            CantidadPorUnidad    = @CantidadPorUnidad,
            PrecioUnidad         = @PrecioUnidad,
            UnidadesEnExistencia = @UnidadesEnExistencia,
            UnidadesEnPedido     = @UnidadesEnPedido,
            NivelDeReorden       = @NivelDeReorden,
            Descontinuado        = @Descontinuado
        WHERE ProductoID = @ProductoID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50303, 'El producto no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* Eliminacion logica: como ya no es un DELETE fisico, no hace
   falta bloquear por productos referenciados en pedidos. */
CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Productos
        SET Activo = 0
        WHERE ProductoID = @ProductoID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50305, 'El producto no existe o ya fue eliminado.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   5) PEDIDOS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ped.PedidoID, ped.ClienteID, ped.EmpleadoID, ped.FechaPedido,
           ped.FechaRequerida, ped.FechaEnvio, ped.TransportistaID,
           ped.Destinatario, ped.CiudadDestino, ped.PaisDestino,
           cli.Empresa AS NombreCliente,
           emp.Nombre + ' ' + emp.Apellidos AS NombreEmpleado,
           tra.CompaniaNombre AS NombreTransportista,
           ISNULL((SELECT SUM(det.PrecioUnidad * det.Cantidad * (1 - det.Descuento))
                   FROM dbo.DetallePedidos det
                   WHERE det.PedidoID = ped.PedidoID), 0) AS Total
    FROM dbo.Pedidos ped
    LEFT JOIN dbo.Clientes        cli ON cli.ClienteID       = ped.ClienteID
    LEFT JOIN dbo.Empleados       emp ON emp.EmpleadoID      = ped.EmpleadoID
    LEFT JOIN dbo.Transportistas  tra ON tra.TransportistaID = ped.TransportistaID
    WHERE ped.Activo = 1
    ORDER BY ped.FechaPedido DESC, ped.PedidoID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_ObtenerPorId
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ped.PedidoID, ped.ClienteID, ped.EmpleadoID, ped.FechaPedido,
           ped.FechaRequerida, ped.FechaEnvio, ped.TransportistaID,
           ped.Destinatario, ped.CiudadDestino, ped.PaisDestino,
           cli.Empresa AS NombreCliente,
           emp.Nombre + ' ' + emp.Apellidos AS NombreEmpleado,
           tra.CompaniaNombre AS NombreTransportista,
           ISNULL((SELECT SUM(det.PrecioUnidad * det.Cantidad * (1 - det.Descuento))
                   FROM dbo.DetallePedidos det
                   WHERE det.PedidoID = ped.PedidoID), 0) AS Total
    FROM dbo.Pedidos ped
    LEFT JOIN dbo.Clientes        cli ON cli.ClienteID       = ped.ClienteID
    LEFT JOIN dbo.Empleados       emp ON emp.EmpleadoID      = ped.EmpleadoID
    LEFT JOIN dbo.Transportistas  tra ON tra.TransportistaID = ped.TransportistaID
    WHERE ped.PedidoID = @PedidoID AND ped.Activo = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Crear
    @ClienteID       INT = NULL,
    @EmpleadoID      INT = NULL,
    @FechaPedido     DATE,
    @FechaRequerida  DATE = NULL,
    @FechaEnvio      DATE = NULL,
    @TransportistaID INT = NULL,
    @Destinatario    NVARCHAR(60) = NULL,
    @CiudadDestino   NVARCHAR(30) = NULL,
    @PaisDestino     NVARCHAR(30) = NULL,
    @NuevoID         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @FechaRequerida IS NOT NULL AND @FechaRequerida < @FechaPedido
            THROW 50401, 'La fecha requerida no puede ser anterior a la fecha del pedido.', 1;

        INSERT INTO dbo.Pedidos
            (ClienteID, EmpleadoID, FechaPedido, FechaRequerida, FechaEnvio,
             TransportistaID, Destinatario, CiudadDestino, PaisDestino)
        VALUES
            (@ClienteID, @EmpleadoID, @FechaPedido, @FechaRequerida, @FechaEnvio,
             @TransportistaID, @Destinatario, @CiudadDestino, @PaisDestino);

        SET @NuevoID = CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Actualizar
    @PedidoID        INT,
    @ClienteID       INT = NULL,
    @EmpleadoID      INT = NULL,
    @FechaPedido     DATE,
    @FechaRequerida  DATE = NULL,
    @FechaEnvio      DATE = NULL,
    @TransportistaID INT = NULL,
    @Destinatario    NVARCHAR(60) = NULL,
    @CiudadDestino   NVARCHAR(30) = NULL,
    @PaisDestino     NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @FechaRequerida IS NOT NULL AND @FechaRequerida < @FechaPedido
            THROW 50402, 'La fecha requerida no puede ser anterior a la fecha del pedido.', 1;

        UPDATE dbo.Pedidos
        SET ClienteID       = @ClienteID,
            EmpleadoID      = @EmpleadoID,
            FechaPedido     = @FechaPedido,
            FechaRequerida  = @FechaRequerida,
            FechaEnvio      = @FechaEnvio,
            TransportistaID = @TransportistaID,
            Destinatario    = @Destinatario,
            CiudadDestino   = @CiudadDestino,
            PaisDestino     = @PaisDestino
        WHERE PedidoID = @PedidoID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50403, 'El pedido no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* Eliminacion logica: ya no borra DetallePedidos, solo marca
   el pedido como inactivo (no necesita transaccion). */
CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Eliminar
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.Pedidos
        SET Activo = 0
        WHERE PedidoID = @PedidoID AND Activo = 1;

        IF @@ROWCOUNT = 0
            THROW 50404, 'El pedido no existe o ya fue eliminado.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   6) REPORTE POR RANGO DE FECHAS
   Excluir pedidos con Activo = 0.
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_ListarPorRangoFechas
    @FechaInicio DATE,
    @FechaFin    DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaInicio > @FechaFin
        THROW 50601, 'La fecha inicial no puede ser mayor que la fecha final.', 1;

    SELECT ped.PedidoID,
           ped.FechaPedido,
           cli.Empresa AS NombreCliente,
           pro.ProductoID,
           pro.NombreProducto,
           det.PrecioUnidad,
           det.Cantidad,
           det.Descuento,
           det.PrecioUnidad * det.Cantidad * (1 - det.Descuento) AS Subtotal
    FROM dbo.DetallePedidos det
    INNER JOIN dbo.Pedidos   ped ON ped.PedidoID   = det.PedidoID
    INNER JOIN dbo.Productos pro ON pro.ProductoID = det.ProductoID
    LEFT  JOIN dbo.Clientes  cli ON cli.ClienteID  = ped.ClienteID
    WHERE ped.FechaPedido BETWEEN @FechaInicio AND @FechaFin
      AND ped.Activo = 1
    ORDER BY ped.FechaPedido, ped.PedidoID, pro.NombreProducto;
END
GO
