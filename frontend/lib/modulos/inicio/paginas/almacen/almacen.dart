import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../general/tema/estilos_texto.dart';
import '../../../../rutas/nombres_rutas.dart';
import '../../../../general/widgets/pagination_widget.dart';
import '../../../../core/utils/confirmacion.dart';
import 'servicios/almacen_service.dart';

class AlmacenPage extends StatefulWidget {
  const AlmacenPage({super.key});

  @override
  State<AlmacenPage> createState() => _AlmacenPageState();
}

class _AlmacenPageState extends State<AlmacenPage> {
  List<Map<String, dynamic>> _movimientos = [];
  List<Map<String, dynamic>> _movimientosFiltrados = [];
  List<Map<String, dynamic>> _productos = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _tipoMovimientoSeleccionado = 'todos';
  String _filtroBusquedaMov = '';

  // Paginación server-side
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _cargarMovimientos();
    _searchController.addListener(_filtrarMovimientos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarMovimientos({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AlmacenService.obtenerMovimientos(page: page);
      if (!mounted) return;
      final items = (result['items'] as List<dynamic>)
          .map((m) => m as Map<String, dynamic>)
          .toList();
      setState(() {
        _movimientos = items;
        _currentPage = page;
        _totalPages = result['totalPages'] as int;
        _totalItems = result['totalElements'] as int;
        _isLoading = false;
      });
      _aplicarFiltroLocal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'No se pudieron cargar los movimientos. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarMovimientos() {
    _filtroBusquedaMov = _searchController.text.toLowerCase();
    _aplicarFiltroLocal();
  }

  void _aplicarFiltroLocal() {
    setState(() {
      _movimientosFiltrados = _movimientos.where((m) {
        // Filter by search query (producto name)
        final producto =
            (m['producto'] ?? '').toString().toLowerCase();
        if (_filtroBusquedaMov.isNotEmpty && !producto.contains(_filtroBusquedaMov)) {
          return false;
        }

        // Filter by tipo
        if (_tipoMovimientoSeleccionado != 'todos') {
          final tipo = (m['tipoMovimiento'] ?? '').toString().toLowerCase();
          if (tipo != _tipoMovimientoSeleccionado) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _cargarProductos() async {
    try {
      final data = await AlmacenService.obtenerProductos();
      if (!mounted) return;
      setState(() {
        _productos = data;
      });
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, 'Error al cargar productos');
    }
  }

  Future<void> _mostrarDialogoCrear() async {
    // Load products first for the picker
    await _cargarProductos();
    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _MovimientoDialog(
        titulo: 'Nuevo Movimiento',
        productos: _productos,
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    final confirmado = await confirmarCreacion(
      context,
      tipoRegistro: 'movimiento',
      detalle: result['tipo_movimiento'],
    );
    if (!confirmado) return;

    try {
      final cantidad = int.tryParse(result['cantidad'] ?? '0') ?? 0;

      await AlmacenService.crearMovimiento({
        'fecha': result['fecha'],
        'cantidad': cantidad,
        'tipo_movimiento': result['tipo_movimiento'],
        'estado': 1,
        'sucursal': {'id': 1},
        'producto': {'id_producto': result['id_producto']},
      });
      if (!mounted) return;
      mostrarExito(context, 'Movimiento creado exitosamente');
      _cargarMovimientos();
    } catch (e) {
      if (!mounted) return;
      mostrarErrorException(context, e);
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> movimiento) async {
    // Load products for the picker
    await _cargarProductos();
    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _MovimientoDialog(
        titulo: 'Editar Movimiento',
        productos: _productos,
        movimientoInicial: movimiento,
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    final confirmado = await confirmarEdicion(
      context,
      tipoRegistro: 'movimiento',
      nombre: movimiento['producto'],
    );
    if (!confirmado) return;

    try {
      final cantidad = int.tryParse(result['cantidad'] ?? '0') ?? 0;

      // The backend expects id_movimiento_inventario for PUT
      final id = movimiento['idMovimiento'];
      await AlmacenService.actualizarMovimiento({
        'id_movimiento_inventario': id,
        'fecha': result['fecha'],
        'cantidad': cantidad,
        'tipo_movimiento': result['tipo_movimiento'],
        'estado': 1,
        'sucursal': {'id': 1},
        'producto': {'id_producto': result['id_producto']},
      });
      if (!mounted) return;
      mostrarExito(context, 'Movimiento actualizado exitosamente');
      _cargarMovimientos();
    } catch (e) {
      if (!mounted) return;
      mostrarErrorException(context, e);
    }
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> movimiento) async {
    final confirm = await confirmarEliminacion(
      context,
      tipoRegistro: 'movimiento',
      nombre: movimiento['producto'],
    );
    if (!confirm) return;

    try {
      await AlmacenService.eliminarMovimiento(movimiento['idMovimiento']);
      if (!mounted) return;
      mostrarExito(context, 'Movimiento eliminado exitosamente');
      _cargarMovimientos();
    } catch (e) {
      if (!mounted) return;
      mostrarErrorException(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      rutaActual: NombresRutas.almacen,
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
                Text('Almacén',
                    style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Movimientos de inventario',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // Botón "+ Nuevo Movimiento"
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
                  'Nuevo Movimiento',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Buscador
            Container(
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
                  hintStyle: HotelPMSTextStyles.subtituloGris,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: HotelPMSColors.textoSecundario,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filtro de Tipo
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _tipoMovimientoSeleccionado,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: HotelPMSColors.fondoTarjeta,
                style: const TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontSize: 14,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _tipoMovimientoSeleccionado = newValue;
                    });
                    _aplicarFiltroLocal();
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'todos',
                    child: Text('Todos los movimientos'),
                  ),
                  DropdownMenuItem(
                      value: 'entrada', child: Text('Entrada')),
                  DropdownMenuItem(
                      value: 'salida', child: Text('Salida')),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cuerpo dinámico: Loading / Error / Tabla
            Expanded(
              child: _buildCuerpo(),
            ),
            // Paginación server-side
            if (_totalPages > 1)
              Container(
                color: HotelPMSColors.fondoTarjeta,
                child: PaginationWidget(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  totalItems: _totalItems,
                  onPageChanged: (page) => _cargarMovimientos(page: page),
                ),
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
              style:
                  const TextStyle(color: HotelPMSColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarMovimientos,
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

    if (_movimientosFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron movimientos.',
          style: TextStyle(color: HotelPMSColors.textoSecundario),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarMovimientos,
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
                'PRODUCTO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'TIPO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'CANTIDAD',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'FECHA',
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
          rows: _movimientosFiltrados.map((movimiento) {
            final id = movimiento['idMovimiento'] ?? '';
            final producto = movimiento['producto'] ?? '';
            final tipoMovimiento =
                (movimiento['tipoMovimiento'] ?? '').toString();
            final cantidad = int.tryParse(
                    (movimiento['cantidad'] ?? '0').toString()) ??
                0;
            final fecha = movimiento['fecha'] ?? '';

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
                    producto,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tipoMovimiento == 'Entrada'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tipoMovimiento,
                      style: TextStyle(
                        color: tipoMovimiento == 'Entrada'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    cantidad.toString(),
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    fecha,
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
                        onPressed: () =>
                            _mostrarDialogoEditar(movimiento),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outlined,
                          color: HotelPMSColors.textoEliminar,
                          size: 18,
                        ),
                        onPressed: () =>
                            _confirmarEliminacion(movimiento),
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

/// Dialog for creating or editing an inventory movement.
class _MovimientoDialog extends StatefulWidget {
  final String titulo;
  final List<Map<String, dynamic>> productos;
  final Map<String, dynamic>? movimientoInicial;

  const _MovimientoDialog({
    required this.titulo,
    required this.productos,
    this.movimientoInicial,
  });

  @override
  State<_MovimientoDialog> createState() => _MovimientoDialogState();
}

class _MovimientoDialogState extends State<_MovimientoDialog> {
  late final TextEditingController _cantidadController;
  late final TextEditingController _fechaController;
  final _formKey = GlobalKey<FormState>();
  int? _productoSeleccionadoId;
  String _tipoSeleccionado = 'Entrada';

  @override
  void initState() {
    super.initState();
    final inicial = widget.movimientoInicial;
    _cantidadController = TextEditingController(
      text: inicial != null
          ? int.tryParse(
                  (inicial['cantidad'] ?? '0').toString())
              ?.toString() ?? '0'
          : '',
    );
    _fechaController = TextEditingController(
      text: inicial?['fecha'] ?? '',
    );

    // Pre-fill product if editing
    if (inicial != null && widget.productos.isNotEmpty) {
      // Find product by matching name (the DTO returns name, we need id)
      final productoNombre = (inicial['producto'] ?? '').toString();
      final match = widget.productos.cast<Map<String, dynamic>?>().firstWhere(
            (p) =>
                (p?['nombre'] ?? '').toString() == productoNombre,
            orElse: () => null,
          );
      if (match != null) {
        _productoSeleccionadoId = match['id_producto'];
      }
    }

    // Pre-fill tipo if editing
    if (inicial != null) {
      final tipo = (inicial['tipoMovimiento'] ?? '').toString();
      if (tipo == 'Entrada' || tipo == 'Salida') {
        _tipoSeleccionado = tipo;
      }
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaController.text.isNotEmpty
          ? DateTime.tryParse(_fechaController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: HotelPMSColors.naranjaAcento,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _fechaController.text = formatted;
    }
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
              // Producto dropdown
              DropdownButtonFormField<int>(
                value: _productoSeleccionadoId,
                decoration: InputDecoration(
                  labelText: 'Producto',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: HotelPMSColors.fondoTarjeta,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal),
                isExpanded: true,
                hint: const Text(
                  'Seleccione un producto',
                  style: TextStyle(color: HotelPMSColors.textoSecundario),
                ),
                items: widget.productos.map((p) {
                  final id = p['id_producto'];
                  final nombre = p['nombre'] ?? '';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _productoSeleccionadoId = value;
                  });
                },
                validator: (v) =>
                    v == null ? 'Debe seleccionar un producto' : null,
              ),
              const SizedBox(height: 16),

              // Tipo dropdown
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo de movimiento',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: HotelPMSColors.fondoTarjeta,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                      value: 'Entrada', child: Text('Entrada')),
                  DropdownMenuItem(
                      value: 'Salida', child: Text('Salida')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoSeleccionado = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Cantidad
              TextFormField(
                controller: _cantidadController,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
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
                    return 'La cantidad es obligatoria';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Ingrese un número entero válido';
                  }
                  final n = int.parse(v);
                  if (n <= 0) {
                    return 'La cantidad debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha
              TextFormField(
                controller: _fechaController,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.calendar_today,
                      color: HotelPMSColors.textoSecundario,
                    ),
                    onPressed: _seleccionarFecha,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'La fecha es obligatoria';
                  }
                  if (DateTime.tryParse(v) == null) {
                    return 'Fecha inválida';
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
                'id_producto': _productoSeleccionadoId,
                'tipo_movimiento': _tipoSeleccionado,
                'cantidad': _cantidadController.text.trim(),
                'fecha': _fechaController.text.trim(),
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
