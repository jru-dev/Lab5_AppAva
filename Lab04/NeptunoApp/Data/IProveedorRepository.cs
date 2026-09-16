using NeptunoApp.Models;

namespace NeptunoApp.Data;

public interface IProveedorRepository
{
    Task<List<Proveedor>> ListarAsync();
    /// <summary>Listado de proveedores filtrado por nombre de contacto y ciudad; ambos filtros son opcionales.</summary>
    Task<List<Proveedor>> BuscarAsync(string? nombreContacto, string? ciudad);
    Task<Proveedor?> ObtenerPorIdAsync(int proveedorId);
    Task<int> CrearAsync(Proveedor proveedor);
    Task ActualizarAsync(Proveedor proveedor);
    Task EliminarAsync(int proveedorId);
}
