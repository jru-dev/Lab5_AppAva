/* ============================================================
   NeptunoDB - Procedimientos almacenados
   Laboratorio 04 - ADO .NET
   ------------------------------------------------------------
   Requiere que NeptunoDB.sql ya se haya ejecutado.
   Todos los procedimientos son CREATE OR ALTER, asi que este
   script se puede volver a ejecutar sin borrar la base de datos.
   ============================================================ */

USE NeptunoDB;
GO

/* ============================================================
   CATEGORIAS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoriaID, NombreCategoria, Descripcion
    FROM dbo.Categorias
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
    WHERE CategoriaID = @CategoriaID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Crear
    @NombreCategoria NVARCHAR(30),
    @Descripcion     NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.Categorias (NombreCategoria, Descripcion)
        VALUES (@NombreCategoria, @Descripcion);

        SELECT SCOPE_IDENTITY() AS CategoriaID;
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
        WHERE CategoriaID = @CategoriaID;

        IF @@ROWCOUNT = 0
            THROW 50101, 'La categoria no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Eliminar
    @CategoriaID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.Productos WHERE CategoriaID = @CategoriaID)
            THROW 50102, 'No se puede eliminar: la categoria tiene productos asociados.', 1;

        DELETE FROM dbo.Categorias WHERE CategoriaID = @CategoriaID;

        IF @@ROWCOUNT = 0
            THROW 50103, 'La categoria no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   PROVEEDORES
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProveedorID, CompaniaNombre, NombreContacto, CargoContacto, Direccion,
           Ciudad, CodigoPostal, Pais, Telefono, Fax
    FROM dbo.Proveedores
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
    WHERE ProveedorID = @ProveedorID;
END
GO

/* Listado de proveedores buscando por nombreContacto y ciudad.
   Los dos filtros son opcionales: si llegan nulos o vacios no restringen. */
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
    WHERE (@NombreContacto IS NULL OR NombreContacto LIKE '%' + @NombreContacto + '%')
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
    @Fax            NVARCHAR(24) = NULL
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

        SELECT SCOPE_IDENTITY() AS ProveedorID;
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
        WHERE ProveedorID = @ProveedorID;

        IF @@ROWCOUNT = 0
            THROW 50201, 'El proveedor no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Eliminar
    @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.Productos WHERE ProveedorID = @ProveedorID)
            THROW 50202, 'No se puede eliminar: el proveedor tiene productos asociados.', 1;

        DELETE FROM dbo.Proveedores WHERE ProveedorID = @ProveedorID;

        IF @@ROWCOUNT = 0
            THROW 50203, 'El proveedor no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   PRODUCTOS
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
    WHERE p.ProductoID = @ProductoID;
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
    @Descontinuado        BIT = 0
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

        SELECT SCOPE_IDENTITY() AS ProductoID;
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
        WHERE ProductoID = @ProductoID;

        IF @@ROWCOUNT = 0
            THROW 50303, 'El producto no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.DetallePedidos WHERE ProductoID = @ProductoID)
            THROW 50304, 'No se puede eliminar: el producto figura en pedidos registrados.', 1;

        DELETE FROM dbo.Productos WHERE ProductoID = @ProductoID;

        IF @@ROWCOUNT = 0
            THROW 50305, 'El producto no existe.', 1;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO
