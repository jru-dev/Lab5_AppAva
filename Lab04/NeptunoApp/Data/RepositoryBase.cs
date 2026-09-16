using System.Data;
using Microsoft.Data.SqlClient;

namespace NeptunoApp.Data;

/// <summary>
/// Clase base de los repositorios. Centraliza la apertura de la conexion y la
/// ejecucion de procedimientos almacenados; las clases derivadas solo declaran
/// el nombre del procedimiento, sus parametros y como mapear el resultado.
/// </summary>
public abstract class RepositoryBase
{
    private readonly string _cadenaConexion;

    protected RepositoryBase(string cadenaConexion)
    {
        _cadenaConexion = cadenaConexion;
    }

    /// <summary>Convierte un valor nulo de .NET al DBNull que espera ADO .NET.</summary>
    protected static object Valor(object? valor) => valor ?? DBNull.Value;

    protected async Task<List<T>> ListarAsync<T>(
        string procedimiento,
        Func<SqlDataReader, T> mapear,
        Action<SqlParameterCollection>? parametros = null)
    {
        await using var conexion = new SqlConnection(_cadenaConexion);
        await using var comando = CrearComando(conexion, procedimiento, parametros);

        await conexion.OpenAsync();
        await using var lector = await comando.ExecuteReaderAsync();

        var resultado = new List<T>();
        while (await lector.ReadAsync())
        {
            resultado.Add(mapear(lector));
        }
        return resultado;
    }

    protected async Task<T?> ObtenerAsync<T>(
        string procedimiento,
        Func<SqlDataReader, T> mapear,
        Action<SqlParameterCollection> parametros) where T : class
    {
        await using var conexion = new SqlConnection(_cadenaConexion);
        await using var comando = CrearComando(conexion, procedimiento, parametros);

        await conexion.OpenAsync();
        await using var lector = await comando.ExecuteReaderAsync();

        return await lector.ReadAsync() ? mapear(lector) : null;
    }

    /// <summary>Ejecuta un procedimiento de alta que devuelve el identificador generado.</summary>
    protected async Task<int> InsertarAsync(string procedimiento, Action<SqlParameterCollection> parametros)
    {
        await using var conexion = new SqlConnection(_cadenaConexion);
        await using var comando = CrearComando(conexion, procedimiento, parametros);

        await conexion.OpenAsync();
        var generado = await comando.ExecuteScalarAsync();
        return Convert.ToInt32(generado);
    }

    /// <summary>Ejecuta un procedimiento que no devuelve filas (actualizar / eliminar).</summary>
    protected async Task EjecutarAsync(string procedimiento, Action<SqlParameterCollection> parametros)
    {
        await using var conexion = new SqlConnection(_cadenaConexion);
        await using var comando = CrearComando(conexion, procedimiento, parametros);

        await conexion.OpenAsync();
        await comando.ExecuteNonQueryAsync();
    }

    private static SqlCommand CrearComando(
        SqlConnection conexion,
        string procedimiento,
        Action<SqlParameterCollection>? parametros)
    {
        var comando = new SqlCommand(procedimiento, conexion)
        {
            CommandType = CommandType.StoredProcedure
        };
        parametros?.Invoke(comando.Parameters);
        return comando;
    }
}
