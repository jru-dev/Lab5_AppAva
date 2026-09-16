using System.Data;
using Microsoft.Data.SqlClient;
using NeptunoApp.Models;

namespace NeptunoApp.Data;

public class ProductoRepository : RepositoryBase, IProductoRepository
{
    public ProductoRepository(string cadenaConexion) : base(cadenaConexion)
    {
    }

    public Task<List<Producto>> ListarAsync()
        => ListarAsync("dbo.usp_Producto_Listar", Mapear);

    public Task<Producto?> ObtenerPorIdAsync(int productoId)
        => ObtenerAsync("dbo.usp_Producto_ObtenerPorId", Mapear, p =>
            p.Add("@ProductoID", SqlDbType.Int).Value = productoId);

    public Task<int> CrearAsync(Producto producto)
        => InsertarAsync("dbo.usp_Producto_Crear", p => AgregarDatos(p, producto));

    public Task ActualizarAsync(Producto producto)
        => EjecutarAsync("dbo.usp_Producto_Actualizar", p =>
        {
            p.Add("@ProductoID", SqlDbType.Int).Value = producto.ProductoID;
            AgregarDatos(p, producto);
        });

    public Task EliminarAsync(int productoId)
        => EjecutarAsync("dbo.usp_Producto_Eliminar", p =>
            p.Add("@ProductoID", SqlDbType.Int).Value = productoId);

    private static void AgregarDatos(SqlParameterCollection p, Producto producto)
    {
        p.Add("@NombreProducto", SqlDbType.NVarChar, 60).Value = producto.NombreProducto;
        p.Add("@ProveedorID", SqlDbType.Int).Value = Valor(producto.ProveedorID);
        p.Add("@CategoriaID", SqlDbType.Int).Value = Valor(producto.CategoriaID);
        p.Add("@CantidadPorUnidad", SqlDbType.NVarChar, 30).Value = Valor(producto.CantidadPorUnidad);
        p.Add("@PrecioUnidad", SqlDbType.Decimal).Value = producto.PrecioUnidad;
        p.Add("@UnidadesEnExistencia", SqlDbType.SmallInt).Value = producto.UnidadesEnExistencia;
        p.Add("@UnidadesEnPedido", SqlDbType.SmallInt).Value = producto.UnidadesEnPedido;
        p.Add("@NivelDeReorden", SqlDbType.SmallInt).Value = producto.NivelDeReorden;
        p.Add("@Descontinuado", SqlDbType.Bit).Value = producto.Descontinuado;
    }

    private static Producto Mapear(SqlDataReader lector) => new()
    {
        ProductoID = lector.Entero("ProductoID"),
        NombreProducto = lector.Texto("NombreProducto"),
        ProveedorID = lector.EnteroNulo("ProveedorID"),
        CategoriaID = lector.EnteroNulo("CategoriaID"),
        CantidadPorUnidad = lector.TextoNulo("CantidadPorUnidad"),
        PrecioUnidad = lector.Decimal("PrecioUnidad"),
        UnidadesEnExistencia = lector.Corto("UnidadesEnExistencia"),
        UnidadesEnPedido = lector.Corto("UnidadesEnPedido"),
        NivelDeReorden = lector.Corto("NivelDeReorden"),
        Descontinuado = lector.Booleano("Descontinuado"),
        NombreCategoria = lector.TextoNulo("NombreCategoria"),
        NombreProveedor = lector.TextoNulo("NombreProveedor")
    };
}
