/* ============================================================
   NeptunoDB - Pedidos, detalle de pedidos y reportes
   Laboratorio 04 - ADO .NET
   ------------------------------------------------------------
   Ejecutar despues de 01_NeptunoDB_Procedimientos.sql
   ============================================================ */

USE NeptunoDB;
GO

/* ============================================================
   CATALOGOS DE APOYO (combos de la interfaz)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClienteID, Empresa, NombreContacto, Ciudad, Pais, Telefono
    FROM dbo.Clientes
    ORDER BY Empresa;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Empleado_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EmpleadoID, Nombre, Apellidos, Cargo, Ciudad, Pais,
           Nombre + ' ' + Apellidos AS NombreCompleto
    FROM dbo.Empleados
    ORDER BY Apellidos, Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Transportista_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TransportistaID, CompaniaNombre, Telefono
    FROM dbo.Transportistas
    ORDER BY CompaniaNombre;
END
GO

/* ============================================================
   PEDIDOS
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
    WHERE ped.PedidoID = @PedidoID;
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
    @PaisDestino     NVARCHAR(30) = NULL
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

        SELECT SCOPE_IDENTITY() AS PedidoID;
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
        WHERE PedidoID = @PedidoID;

        IF @@ROWCOUNT = 0
            THROW 50403, 'El pedido no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* Elimina el pedido junto con su detalle dentro de una transaccion,
   porque DetallePedidos tiene FK hacia Pedidos. */
CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Eliminar
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

            DELETE FROM dbo.DetallePedidos WHERE PedidoID = @PedidoID;
            DELETE FROM dbo.Pedidos        WHERE PedidoID = @PedidoID;

            IF @@ROWCOUNT = 0
                THROW 50404, 'El pedido no existe.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* ============================================================
   DETALLE DE PEDIDOS
   La clave primaria es compuesta (PedidoID, ProductoID), por eso
   no hay SCOPE_IDENTITY y las operaciones piden las dos claves.
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_ListarPorPedido
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT det.PedidoID, det.ProductoID, det.PrecioUnidad, det.Cantidad, det.Descuento,
           pro.NombreProducto,
           det.PrecioUnidad * det.Cantidad * (1 - det.Descuento) AS Subtotal
    FROM dbo.DetallePedidos det
    INNER JOIN dbo.Productos pro ON pro.ProductoID = det.ProductoID
    WHERE det.PedidoID = @PedidoID
    ORDER BY pro.NombreProducto;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_Agregar
    @PedidoID     INT,
    @ProductoID   INT,
    @PrecioUnidad DECIMAL(10,2),
    @Cantidad     SMALLINT,
    @Descuento    DECIMAL(4,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Cantidad <= 0
            THROW 50501, 'La cantidad debe ser mayor que cero.', 1;

        IF @Descuento < 0 OR @Descuento > 1
            THROW 50502, 'El descuento debe estar entre 0 y 1.', 1;

        IF EXISTS (SELECT 1 FROM dbo.DetallePedidos
                   WHERE PedidoID = @PedidoID AND ProductoID = @ProductoID)
            THROW 50503, 'El producto ya esta registrado en este pedido.', 1;

        INSERT INTO dbo.DetallePedidos (PedidoID, ProductoID, PrecioUnidad, Cantidad, Descuento)
        VALUES (@PedidoID, @ProductoID, @PrecioUnidad, @Cantidad, @Descuento);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_Actualizar
    @PedidoID     INT,
    @ProductoID   INT,
    @PrecioUnidad DECIMAL(10,2),
    @Cantidad     SMALLINT,
    @Descuento    DECIMAL(4,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Cantidad <= 0
            THROW 50504, 'La cantidad debe ser mayor que cero.', 1;

        IF @Descuento < 0 OR @Descuento > 1
            THROW 50505, 'El descuento debe estar entre 0 y 1.', 1;

        UPDATE dbo.DetallePedidos
        SET PrecioUnidad = @PrecioUnidad,
            Cantidad     = @Cantidad,
            Descuento    = @Descuento
        WHERE PedidoID = @PedidoID AND ProductoID = @ProductoID;

        IF @@ROWCOUNT = 0
            THROW 50506, 'El detalle no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_Eliminar
    @PedidoID   INT,
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.DetallePedidos
        WHERE PedidoID = @PedidoID AND ProductoID = @ProductoID;

        IF @@ROWCOUNT = 0
            THROW 50507, 'El detalle no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   REPORTE
   Listado de detalles de pedidos con INNER JOIN a pedidos,
   filtrando por un intervalo de fechas.
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
    ORDER BY ped.FechaPedido, ped.PedidoID, pro.NombreProducto;
END
GO
