namespace WPF_SP.Data;

public static class DbConfig
{
    // Instancia local detectada: .\SQLEXPRESS. Ajustar si tu SQL Server local usa otro nombre de instancia.
    public const string ConnectionString =
        @"Server=.\SQLEXPRESS;Database=TodoListDB;Trusted_Connection=True;TrustServerCertificate=True;";
}
