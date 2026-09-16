using System.Data;
using Microsoft.Data.SqlClient;
using NeptunoApp.Models;

namespace NeptunoApp.Data;

public class PedidoRepository : RepositoryBase, IPedidoRepository
{
    public PedidoRepository(string cadenaConexion) : base(cadenaConexion)
    {
    }

    public Task<List<Pedido>> ListarAsync()
        => ListarAsync("dbo.usp_Pedido_Listar", Mapear);

    public Task<Pedido?> ObtenerPorIdAsync(int pedidoId)
        => ObtenerAsync("dbo.usp_Pedido_ObtenerPorId", Mapear, p =>
            p.Add("@PedidoID", SqlDbType.Int).Value = pedidoId);

    public Task<int> CrearAsync(Pedido pedido)
        => InsertarAsync("dbo.usp_Pedido_Crear", p => AgregarDatos(p, pedido));

    public Task ActualizarAsync(Pedido pedido)
        => EjecutarAsync("dbo.usp_Pedido_Actualizar", p =>
        {
            p.Add("@PedidoID", SqlDbType.Int).Value = pedido.PedidoID;
            AgregarDatos(p, pedido);
        });

    public Task EliminarAsync(int pedidoId)
        => EjecutarAsync("dbo.usp_Pedido_Eliminar", p =>
            p.Add("@PedidoID", SqlDbType.Int).Value = pedidoId);

    public Task<List<DetallePedido>> ListarDetalleAsync(int pedidoId)
        => ListarAsync("dbo.usp_DetallePedido_ListarPorPedido", MapearDetalle, p =>
            p.Add("@PedidoID", SqlDbType.Int).Value = pedidoId);

    public Task AgregarDetalleAsync(DetallePedido detalle)
        => EjecutarAsync("dbo.usp_DetallePedido_Agregar", p => AgregarDatosDetalle(p, detalle));

    public Task ActualizarDetalleAsync(DetallePedido detalle)
        => EjecutarAsync("dbo.usp_DetallePedido_Actualizar", p => AgregarDatosDetalle(p, detalle));

    public Task EliminarDetalleAsync(int pedidoId, int productoId)
        => EjecutarAsync("dbo.usp_DetallePedido_Eliminar", p =>
        {
            p.Add("@PedidoID", SqlDbType.Int).Value = pedidoId;
            p.Add("@ProductoID", SqlDbType.Int).Value = productoId;
        });

    public Task<List<LineaReporte>> ListarPorRangoFechasAsync(DateTime fechaInicio, DateTime fechaFin)
        => ListarAsync("dbo.usp_DetallePedido_ListarPorRangoFechas", MapearLinea, p =>
        {
            p.Add("@FechaInicio", SqlDbType.Date).Value = fechaInicio.Date;
            p.Add("@FechaFin", SqlDbType.Date).Value = fechaFin.Date;
        });

    private static void AgregarDatos(SqlParameterCollection p, Pedido pedido)
    {
        p.Add("@ClienteID", SqlDbType.Int).Value = Valor(pedido.ClienteID);
        p.Add("@EmpleadoID", SqlDbType.Int).Value = Valor(pedido.EmpleadoID);
        p.Add("@FechaPedido", SqlDbType.Date).Value = pedido.FechaPedido.Date;
        p.Add("@FechaRequerida", SqlDbType.Date).Value = Valor(pedido.FechaRequerida?.Date);
        p.Add("@FechaEnvio", SqlDbType.Date).Value = Valor(pedido.FechaEnvio?.Date);
        p.Add("@TransportistaID", SqlDbType.Int).Value = Valor(pedido.TransportistaID);
        p.Add("@Destinatario", SqlDbType.NVarChar, 60).Value = Valor(pedido.Destinatario);
        p.Add("@CiudadDestino", SqlDbType.NVarChar, 30).Value = Valor(pedido.CiudadDestino);
        p.Add("@PaisDestino", SqlDbType.NVarChar, 30).Value = Valor(pedido.PaisDestino);
    }

    private static void AgregarDatosDetalle(SqlParameterCollection p, DetallePedido detalle)
    {
        p.Add("@PedidoID", SqlDbType.Int).Value = detalle.PedidoID;
        p.Add("@ProductoID", SqlDbType.Int).Value = detalle.ProductoID;
        p.Add("@PrecioUnidad", SqlDbType.Decimal).Value = detalle.PrecioUnidad;
        p.Add("@Cantidad", SqlDbType.SmallInt).Value = detalle.Cantidad;
        p.Add("@Descuento", SqlDbType.Decimal).Value = detalle.Descuento;
    }

    private static Pedido Mapear(SqlDataReader lector) => new()
    {
        PedidoID = lector.Entero("PedidoID"),
        ClienteID = lector.EnteroNulo("ClienteID"),
        EmpleadoID = lector.EnteroNulo("EmpleadoID"),
        FechaPedido = lector.Fecha("FechaPedido"),
        FechaRequerida = lector.FechaNula("FechaRequerida"),
        FechaEnvio = lector.FechaNula("FechaEnvio"),
        TransportistaID = lector.EnteroNulo("TransportistaID"),
        Destinatario = lector.TextoNulo("Destinatario"),
        CiudadDestino = lector.TextoNulo("CiudadDestino"),
        PaisDestino = lector.TextoNulo("PaisDestino"),
        NombreCliente = lector.TextoNulo("NombreCliente"),
        NombreEmpleado = lector.TextoNulo("NombreEmpleado"),
        NombreTransportista = lector.TextoNulo("NombreTransportista"),
        Total = lector.Decimal("Total")
    };

    private static DetallePedido MapearDetalle(SqlDataReader lector) => new()
    {
        PedidoID = lector.Entero("PedidoID"),
        ProductoID = lector.Entero("ProductoID"),
        NombreProducto = lector.TextoNulo("NombreProducto"),
        PrecioUnidad = lector.Decimal("PrecioUnidad"),
        Cantidad = lector.Corto("Cantidad"),
        Descuento = lector.Decimal("Descuento"),
        Subtotal = lector.Decimal("Subtotal")
    };

    private static LineaReporte MapearLinea(SqlDataReader lector) => new()
    {
        PedidoID = lector.Entero("PedidoID"),
        FechaPedido = lector.Fecha("FechaPedido"),
        NombreCliente = lector.TextoNulo("NombreCliente"),
        ProductoID = lector.Entero("ProductoID"),
        NombreProducto = lector.Texto("NombreProducto"),
        PrecioUnidad = lector.Decimal("PrecioUnidad"),
        Cantidad = lector.Corto("Cantidad"),
        Descuento = lector.Decimal("Descuento"),
        Subtotal = lector.Decimal("Subtotal")
    };
}
