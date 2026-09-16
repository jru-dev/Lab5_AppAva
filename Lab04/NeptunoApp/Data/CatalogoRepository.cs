using Microsoft.Data.SqlClient;
using NeptunoApp.Models;

namespace NeptunoApp.Data;

public class CatalogoRepository : RepositoryBase, ICatalogoRepository
{
    public CatalogoRepository(string cadenaConexion) : base(cadenaConexion)
    {
    }

    public Task<List<Cliente>> ListarClientesAsync()
        => ListarAsync("dbo.usp_Cliente_Listar", lector => new Cliente
        {
            ClienteID = lector.Entero("ClienteID"),
            Empresa = lector.Texto("Empresa"),
            NombreContacto = lector.TextoNulo("NombreContacto"),
            Ciudad = lector.TextoNulo("Ciudad"),
            Pais = lector.TextoNulo("Pais"),
            Telefono = lector.TextoNulo("Telefono")
        });

    public Task<List<Empleado>> ListarEmpleadosAsync()
        => ListarAsync("dbo.usp_Empleado_Listar", lector => new Empleado
        {
            EmpleadoID = lector.Entero("EmpleadoID"),
            Nombre = lector.Texto("Nombre"),
            Apellidos = lector.Texto("Apellidos"),
            Cargo = lector.TextoNulo("Cargo"),
            Ciudad = lector.TextoNulo("Ciudad"),
            Pais = lector.TextoNulo("Pais"),
            NombreCompleto = lector.Texto("NombreCompleto")
        });

    public Task<List<Transportista>> ListarTransportistasAsync()
        => ListarAsync("dbo.usp_Transportista_Listar", lector => new Transportista
        {
            TransportistaID = lector.Entero("TransportistaID"),
            CompaniaNombre = lector.Texto("CompaniaNombre"),
            Telefono = lector.TextoNulo("Telefono")
        });
}
