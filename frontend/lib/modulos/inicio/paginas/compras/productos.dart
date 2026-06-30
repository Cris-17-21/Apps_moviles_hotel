import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../general/tema/estilos_texto.dart';
import '../../../../rutas/nombres_rutas.dart';
import 'servicios/productos_service.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _productosFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _searchController.addListener(_filtrarProductos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ProductosService.obtenerProductos();
      setState(() {
        _productos = data;
        _productosFiltrados = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'No se pudieron cargar los productos. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _productosFiltrados = _productos;
      } else {
        _productosFiltrados = _productos.where((p) {
          final nombre =
              (p['nombre_producto'] ?? '').toString().toLowerCase();
          final descripcion =
              (p['descripcion_producto'] ?? '').toString().toLowerCase();
          return nombre.contains(query) || descripcion.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoCrear() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _ProductoDialog(titulo: 'Nuevo Producto'),
    );

    if (result == null) return;

    try {
      final precio = double.tryParse(result['precio'] ?? '0') ?? 0;
      final stock = int.tryParse(result['stock'] ?? '0') ?? 0;

      await ProductosService.crearProducto({
        'nombre_producto': result['nombre'],
        'descripcion_producto': result['descripcion'],
        'precio': precio,
        'stock': stock,
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto creado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear producto: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> producto) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _ProductoDialog(
        titulo: 'Editar Producto',
        nombreInicial: producto['nombre_producto'] ?? '',
        descripcionInicial: producto['descripcion_producto'] ?? '',
        precioInicial: (producto['precio'] ?? 0).toString(),
        stockInicial: (producto['stock'] ?? 0).toString(),
      ),
    );

    if (result == null) return;

    try {
      final precio = double.tryParse(result['precio'] ?? '0') ?? 0;
      final stock = int.tryParse(result['stock'] ?? '0') ?? 0;

      await ProductosService.actualizarProducto({
        'id_producto': producto['id_producto'],
        'nombre_producto': result['nombre'],
        'descripcion_producto': result['descripcion'],
        'precio': precio,
        'stock': stock,
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar producto: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: HotelPMSColors.textoPrincipal),
        ),
        content: Text(
          '¿Está seguro de eliminar el producto "${producto['nombre_producto']}"?',
          style: const TextStyle(color: HotelPMSColors.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: HotelPMSColors.textoSecundario),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: HotelPMSColors.textoEliminar),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ProductosService.eliminarProducto(producto['id_producto']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar producto: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Compras / Productos',
      rutaActual: NombresRutas.productos,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Productos',
                    style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra el catálogo de productos',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // Botón "+ Nuevo"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _mostrarDialogoCrear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HotelPMSColors.naranjaAcento,
                  foregroundColor: HotelPMSColors.textoPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Nuevo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Barra de Búsqueda
            Container(
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  hintText: 'Buscar productos por nombre o descripción...',
                  hintStyle: HotelPMSTextStyles.subtituloGris,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: HotelPMSColors.textoSecundario,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cuerpo dinámico: Loading / Error / Tabla
            Expanded(
              child: _buildCuerpo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuerpo() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: HotelPMSColors.naranjaAcento,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: HotelPMSColors.textoEliminar,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HotelPMSColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarProductos,
              style: ElevatedButton.styleFrom(
                backgroundColor: HotelPMSColors.naranjaAcento,
                foregroundColor: HotelPMSColors.textoPrincipal,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_productosFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron productos.',
          style: TextStyle(color: HotelPMSColors.textoSecundario),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarProductos,
      color: HotelPMSColors.naranjaAcento,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(HotelPMSColors.fondoOscuro),
          headingRowHeight: 48,
          dataRowHeight: 60,
          columns: const [
            DataColumn(
              label: Text(
                'ID',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'NOMBRE',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'DESCRIPCIÓN',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'PRECIO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'STOCK',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ACCIONES',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          rows: _productosFiltrados.map((producto) {
            final id = producto['id_producto'] ?? '';
            final nombre = producto['nombre_producto'] ?? '';
            final descripcion = producto['descripcion_producto'] ?? '';
            final precio = producto['precio'] ?? 0;
            final stock = producto['stock'] ?? 0;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    id.toString(),
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    'S/. ${(precio is num ? precio : 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: HotelPMSColors.naranjaAcento,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    stock.toString(),
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: HotelPMSColors.textoSecundario,
                          size: 18,
                        ),
                        onPressed: () => _mostrarDialogoEditar(producto),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outlined,
                          color: HotelPMSColors.textoEliminar,
                          size: 18,
                        ),
                        onPressed: () => _confirmarEliminacion(producto),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Dialog for creating or editing a product.
class _ProductoDialog extends StatefulWidget {
  final String titulo;
  final String? nombreInicial;
  final String? descripcionInicial;
  final String? precioInicial;
  final String? stockInicial;

  const _ProductoDialog({
    required this.titulo,
    this.nombreInicial,
    this.descripcionInicial,
    this.precioInicial,
    this.stockInicial,
  });

  @override
  State<_ProductoDialog> createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<_ProductoDialog> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _stockController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial ?? '');
    _descripcionController =
        TextEditingController(text: widget.descripcionInicial ?? '');
    _precioController = TextEditingController(text: widget.precioInicial ?? '');
    _stockController = TextEditingController(text: widget.stockInicial ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      title: Text(
        widget.titulo,
        style: const TextStyle(color: HotelPMSColors.textoPrincipal),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Precio',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  if (double.tryParse(v) == null) {
                    return 'Ingrese un valor numérico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stock',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El stock es obligatorio';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Ingrese un número entero válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: HotelPMSColors.textoSecundario),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nombre': _nombreController.text.trim(),
                'descripcion': _descripcionController.text.trim(),
                'precio': _precioController.text.trim(),
                'stock': _stockController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: HotelPMSColors.naranjaAcento,
            foregroundColor: HotelPMSColors.textoPrincipal,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
