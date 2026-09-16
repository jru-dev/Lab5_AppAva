using Microsoft.Data.SqlClient;

namespace NeptunoApp.Data;

/// <summary>
/// Lecturas por nombre de columna para no repetir GetOrdinal / IsDBNull en cada mapeo.
/// </summary>
internal static class LectorExtensiones
{
    public static int Entero(this SqlDataReader lector, string columna)
        => lector.GetInt32(lector.GetOrdinal(columna));

    public static int? EnteroNulo(this SqlDataReader lector, string columna)
    {
        var indice = lector.GetOrdinal(columna);
        return lector.IsDBNull(indice) ? null : lector.GetInt32(indice);
    }

    public static short Corto(this SqlDataReader lector, string columna)
        => lector.GetInt16(lector.GetOrdinal(columna));

    public static decimal Decimal(this SqlDataReader lector, string columna)
        => lector.GetDecimal(lector.GetOrdinal(columna));

    public static bool Booleano(this SqlDataReader lector, string columna)
        => lector.GetBoolean(lector.GetOrdinal(columna));

    public static string Texto(this SqlDataReader lector, string columna)
        => lector.GetString(lector.GetOrdinal(columna));

    public static string? TextoNulo(this SqlDataReader lector, string columna)
    {
        var indice = lector.GetOrdinal(columna);
        return lector.IsDBNull(indice) ? null : lector.GetString(indice);
    }

    public static DateTime Fecha(this SqlDataReader lector, string columna)
        => lector.GetDateTime(lector.GetOrdinal(columna));

    public static DateTime? FechaNula(this SqlDataReader lector, string columna)
    {
        var indice = lector.GetOrdinal(columna);
        return lector.IsDBNull(indice) ? null : lector.GetDateTime(indice);
    }
}
