namespace NeptunoApp.Data;

public static class DbConfig
{
    // Instancia local: .\SQLEXPRESS. Ajustar si el SQL Server local usa otro nombre de instancia.
    public const string ConnectionString =
        @"Server=.\SQLEXPRESS;Database=NeptunoDB;Trusted_Connection=True;TrustServerCertificate=True;";
}
