using NeptunoApp.Models;

namespace NeptunoApp.Data;

public interface IProductoRepository
{
    Task<List<Producto>> ListarAsync();
    Task<Producto?> ObtenerPorIdAsync(int productoId);
    Task<int> CrearAsync(Producto producto);
    Task ActualizarAsync(Producto producto);
    Task EliminarAsync(int productoId);
}
