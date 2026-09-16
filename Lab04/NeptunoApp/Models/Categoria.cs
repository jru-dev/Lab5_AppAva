using CommunityToolkit.Mvvm.ComponentModel;

namespace NeptunoApp.Models;

public partial class Categoria : ObservableObject
{
    [ObservableProperty]
    private int categoriaID;

    [ObservableProperty]
    private string nombreCategoria = string.Empty;

    [ObservableProperty]
    private string? descripcion;
}
