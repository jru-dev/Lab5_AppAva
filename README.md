# Laboratorio 05 - ExecuteNonQuery y eliminación lógica sobre NeptunoDB

Aplicación de escritorio WPF (.NET 10, C#, patrón MVVM) que consume SQL Server
exclusivamente a través de procedimientos almacenados con ADO .NET. Todas las
operaciones de escritura (alta, actualización y baja) se ejecutan con
`ExecuteNonQuery`, y la baja es lógica (campo `Activo`), nunca un `DELETE`
físico.

## Cómo ejecutarlo

1. Ejecutar los scripts en este orden, desde `Scripts/`:

   | Orden | Script | Qué hace |
   |-------|--------|----------|
   | 1 | `00_NeptunoDB.sql` | Crea la base de datos, las 8 tablas y los datos de prueba |
   | 2 | `01_NeptunoDB_Procedimientos.sql` | Procedimientos de categorías, proveedores y productos |
   | 3 | `02_NeptunoDB_Pedidos_Reportes.sql` | Pedidos, detalle de pedidos, catálogos y el reporte por fechas |
   | 4 | `03_NeptunoDB_CorregirAcentos.sql` | Opcional: repara las tildes de los datos de ejemplo |
   | 5 | `04_NeptunoDB_EliminacionLogica.sql` | Agrega el campo `Activo` a Productos, Categorías, Proveedores y Pedidos; convierte los `usp_*_Eliminar` en baja lógica (`UPDATE Activo = 0`); filtra `Activo = 1` en listados, búsquedas y el reporte; y cambia los `usp_*_Crear` para devolver el ID por parámetro `OUTPUT` en vez de `SELECT SCOPE_IDENTITY()` |

   Desde la línea de comandos:

   ```
   sqlcmd -S .\SQLEXPRESS -E -C -i 01_NeptunoDB_Procedimientos.sql
   ```

   El paso 4 es opcional: el `NeptunoDB.sql` entregado trae las tildes
   reemplazadas por el carácter U+FFFD, así que "Lácteos" se guarda como
   "L?cteos" en cualquier herramienta. El script las corrige.

   El paso 5 requiere que el 00, 01 y 02 ya se hayan ejecutado. Se puede
   volver a correr sin problema (usa `CREATE OR ALTER` y verifica si la
   columna `Activo` ya existe antes de agregarla).

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
| Campo `Activo` en Productos, Categorías, Proveedores y Pedidos | `04_NeptunoDB_EliminacionLogica.sql` |
| Eliminación lógica (`UPDATE Activo = 0`, nunca `DELETE`) | `usp_Producto_Eliminar`, `usp_Categoria_Eliminar`, `usp_Proveedor_Eliminar`, `usp_Pedido_Eliminar` |
| Listados y búsquedas que excluyen `Activo = 0` | Todos los `usp_*_Listar`, `usp_*_ObtenerPorId`, `usp_Proveedor_Buscar` y `usp_DetallePedido_ListarPorRangoFechas` |
| Alta, actualización y baja con `ExecuteNonQuery` | `RepositoryBase.InsertarAsync` / `EjecutarAsync`, invocados desde cada repositorio y desde el botón "Eliminar" de cada vista |

## Notas de implementación

- `DetallePedidos` tiene clave primaria compuesta `(PedidoID, ProductoID)` y no
  tiene columna identidad, por eso su alta no devuelve un ID nuevo y su
  edición no permite cambiar el producto de una línea existente. No lleva
  columna `Activo`: el enunciado solo la pide para Productos, Categorías,
  Proveedores y Pedidos.
- Las columnas de fecha son `DATE`, se enlazan como `SqlDbType.Date`.
- El descuento se guarda como fracción (0.05 = 5 %) y se captura en porcentaje.
- **Eliminación lógica:** las 4 entidades tienen `Activo BIT NOT NULL DEFAULT 1`.
  Los `usp_*_Eliminar` ya no hacen `DELETE`, hacen
  `UPDATE ... SET Activo = 0 WHERE Id = @Id AND Activo = 1`. Si la fila no
  existe o ya estaba dada de baja, `@@ROWCOUNT = 0` y se lanza un `THROW`.
  Como ya no se elimina físicamente ninguna fila, se quitaron las
  validaciones de "no se puede eliminar porque tiene productos/pedidos
  asociados" (existían para evitar violar una llave foránea con `DELETE`
  físico, y ya no aplican).
- `usp_Pedido_Eliminar` ya no necesita transacción ni borrar
  `DetallePedidos`: solo marca `Pedidos.Activo = 0`.
- Todos los `usp_*_Listar`, `usp_*_ObtenerPorId`, `usp_Proveedor_Buscar` y
  `usp_DetallePedido_ListarPorRangoFechas` filtran `Activo = 1`, así que un
  registro dado de baja desaparece de listados, búsquedas y reportes aunque
  siga físicamente en la tabla.
- **Alta con `ExecuteNonQuery`:** los `usp_*_Crear` ya no hacen
  `SELECT SCOPE_IDENTITY()`; declaran un parámetro `@NuevoID INT OUTPUT` y
  hacen `SET @NuevoID = CAST(SCOPE_IDENTITY() AS INT)`. `RepositoryBase.InsertarAsync`
  agrega ese parámetro de salida y llama a `ExecuteNonQueryAsync` (antes usaba
  `ExecuteScalarAsync`), así las tres operaciones de escritura (alta,
  actualización y baja) usan `ExecuteNonQuery` en todos los módulos.
