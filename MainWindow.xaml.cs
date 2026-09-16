using System.Windows;
using WPF_SP.Data;
using WPF_SP.ViewModels;
using WPF_SP.Views;

namespace WPF_SP
{
    public partial class MainWindow : Window
    {
        private readonly MainViewModel _viewModel;

        public MainWindow()
        {
            InitializeComponent();

            ITareaRepository repository = new TareaRepository(DbConfig.ConnectionString);
            _viewModel = new MainViewModel(repository);
            _viewModel.EditarSolicitado += OnEditarSolicitado;
            DataContext = _viewModel;

            Loaded += async (_, _) => await _viewModel.CargarCommand.ExecuteAsync(null);
        }

        private async void OnEditarSolicitado(TareaEditViewModel edicion)
        {
            var dialog = new TareaEditWindow(edicion) { Owner = this };
            if (dialog.ShowDialog() == true)
            {
                await _viewModel.GuardarEdicionCommand.ExecuteAsync(edicion);
            }
        }
    }
}
