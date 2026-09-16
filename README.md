# Laboratorio 04 - ADO .NET sobre NeptunoDB

Aplicación de escritorio WPF (.NET 10, C#, patrón MVVM) que consume SQL Server
exclusivamente a través de procedimientos almacenados con ADO .NET.

**Curso:** Desarrollo de Aplicaciones Empresariales Avanzado — 6 · C24 · Sección C - D
**Docente:** Arévalo Sermeño, Edwin William

**Integrantes:**

- Aguirre Saavedra, Juan Alexis
- Azañero Pillaca, Vidal Hotaru

## Cómo ejecutarlo

1. Ejecutar los scripts en este orden, desde `Scripts/`:

   | Orden | Script | Qué hace |
   |-------|--------|----------|
   | 1 | `00_NeptunoDB.sql` | Crea la base de datos, las 8 tablas y los datos de prueba |
   | 2 | `01_NeptunoDB_Procedimientos.sql` | Procedimientos de categorías, proveedores y productos |
   | 3 | `02_NeptunoDB_Pedidos_Reportes.sql` | Pedidos, detalle de pedidos, catálogos y el reporte por fechas |
   | 4 | `03_NeptunoDB_CorregirAcentos.sql` | Opcional: repara las tildes de los datos de ejemplo |

   Desde la línea de comandos:

   ```
   sqlcmd -S .\SQLEXPRESS -E -C -i 01_NeptunoDB_Procedimientos.sql
   ```

   El paso 4 es opcional: el `NeptunoDB.sql` entregado trae las tildes
   reemplazadas por el carácter U+FFFD, así que "Lácteos" se guarda como
   "L?cteos" en cualquier herramienta. El script las corrige.

2. Abrir `Neptuno.slnx` en Visual Studio y ejecutar (F5).

La cadena de conexión está en `NeptunoApp/Data/DbConfig.cs` y apunta a
`.\SQLEXPRESS`. Si la instancia local tiene otro nombre, se cambia ahí.

## Estructura

```
NeptunoApp/
  Data/        Repositorios ADO .NET (un procedimiento almacenado por operación)
  Models/      Entidades del dominio
  ViewModels/  Lógica de cada módulo y de cada formulario
  Views/       Pantallas de mantenimiento y ventanas de edición
  Themes/      Estilos y paleta de colores
  Converters/  Convertidores de enlace de datos
```

`RepositoryBase` centraliza la conexión y la ejecución de procedimientos;
cada repositorio solo declara el nombre del procedimiento, sus parámetros y
cómo mapear el resultado. `ViewModelBase` concentra el indicador de ocupado,
el mensaje de error y el try/catch que atrapa los errores que lanzan los
procedimientos con `THROW`.

## Puntos del laboratorio

| Requisito | Dónde está |
|-----------|-----------|
| CRUD de productos | `usp_Producto_*` · módulo Productos |
| CRUD de categorías | `usp_Categoria_*` · módulo Categorías |
| CRUD de proveedores | `usp_Proveedor_*` · módulo Proveedores |
| CRUD de pedidos | `usp_Pedido_*` y `usp_DetallePedido_*` · módulo Pedidos |
| Listado de proveedores por nombreContacto y ciudad | `usp_Proveedor_Buscar` · filtros del módulo Proveedores |
| Detalles de pedidos con inner join a pedidos, por intervalo de fechas | `usp_DetallePedido_ListarPorRangoFechas` · módulo Reportes |
| Mantenimiento de productos | Módulo Productos |
| Mantenimiento de categorías | Módulo Categorías |
| Mantenimiento de proveedores + búsqueda con filtros | Módulo Proveedores |
| Mantenimiento de pedidos + reportes con filtros de fecha | Módulos Pedidos y Reportes |

## Notas de implementación

- `DetallePedidos` tiene clave primaria compuesta `(PedidoID, ProductoID)` y no
  tiene columna identidad, por eso su alta no devuelve `SCOPE_IDENTITY()` y su
  edición no permite cambiar el producto de una línea existente.
- Las columnas de fecha son `DATE`, se enlazan como `SqlDbType.Date`.
- El descuento se guarda como fracción (0.05 = 5 %) y se captura en porcentaje.
- `usp_Pedido_Eliminar` borra las líneas y la cabecera dentro de una
  transacción, porque `DetallePedidos` referencia a `Pedidos`.
- Antes de eliminar una categoría o un proveedor se verifica que no tengan
  productos asociados, para devolver un mensaje entendible en vez del error
  crudo de la llave foránea.
