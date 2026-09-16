using CommunityToolkit.Mvvm.ComponentModel;

namespace NeptunoApp.Models;

public partial class Producto : ObservableObject
{
    [ObservableProperty]
    private int productoID;

    [ObservableProperty]
    private string nombreProducto = string.Empty;

    [ObservableProperty]
    private int? proveedorID;

    [ObservableProperty]
    private int? categoriaID;

    [ObservableProperty]
    private string? cantidadPorUnidad;

    [ObservableProperty]
    private decimal precioUnidad;

    [ObservableProperty]
    private short unidadesEnExistencia;

    [ObservableProperty]
    private short unidadesEnPedido;

    [ObservableProperty]
    private short nivelDeReorden;

    [ObservableProperty]
    private bool descontinuado;

    // Columnas que llegan desde el LEFT JOIN del procedimiento, solo para mostrar en la grilla.
    [ObservableProperty]
    private string? nombreCategoria;

    [ObservableProperty]
    private string? nombreProveedor;

    /// <summary>El stock esta por debajo del nivel de reorden configurado.</summary>
    public bool NecesitaReposicion => NivelDeReorden > 0 && UnidadesEnExistencia <= NivelDeReorden;
}
