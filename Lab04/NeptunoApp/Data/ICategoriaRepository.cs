using NeptunoApp.Models;

namespace NeptunoApp.Data;

public interface ICategoriaRepository
{
    Task<List<Categoria>> ListarAsync();
    Task<Categoria?> ObtenerPorIdAsync(int categoriaId);
    Task<int> CrearAsync(Categoria categoria);
    Task ActualizarAsync(Categoria categoria);
    Task EliminarAsync(int categoriaId);
}
