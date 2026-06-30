import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../general/tema/estilos_texto.dart';
import '../../../../rutas/nombres_rutas.dart';
import 'servicios/compras_service.dart';
import 'servicios/productos_service.dart';
import 'servicios/proveedores_service.dart';

String _formatFecha(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Represents a line item in the purchase detail.
class _DetalleItem {
  final int idProducto;
  final String nombreProducto;
  double cantidad;
  double precio;

  _DetalleItem({
    required this.idProducto,
    required this.nombreProducto,
    this.cantidad = 1,
    this.precio = 0,
  });

  double get subtotal => cantidad * precio;
}

class NuevaCompraPage extends StatefulWidget {
  const NuevaCompraPage({super.key});

  @override
  State<NuevaCompraPage> createState() => _NuevaCompraPageState();
}

class _NuevaCompraPageState extends State<NuevaCompraPage> {
  final _formKey = GlobalKey<FormState>();
  final _numComprobanteController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');

  // Loading state
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  // Proveedores
  List<Map<String, dynamic>> _proveedores = [];
  Map<String, dynamic>? _selectedProveedor;

  // Productos disponibles (para el dropdown de agregar)
  List<Map<String, dynamic>> _productosDisponibles = [];
  Map<String, dynamic>? _selectedProducto;

  // Detalle de compra (productos agregados)
  final List<_DetalleItem> _detalleItems = [];

  // Correlativo
  String _correlativo = '';

  // Fecha
  DateTime _fechaCompra = DateTime.now();

  // Total calculado
  double get _totalCompra =>
      _detalleItems.fold(0.0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _numComprobanteController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoadingData = true);

    try {
      final results = await Future.wait([
        ProveedoresService.obtenerProveedores(),
        ProductosService.obtenerProductos(),
        ComprasService.getCorrelativo(),
      ]);

      final proveedores = results[0] as List<Map<String, dynamic>>;
      final productos = results[1] as List<Map<String, dynamic>>;
      final correlativoData = results[2] as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _proveedores = proveedores;
        _productosDisponibles = productos;
        // Try to extract correlativo string; could be 'correlativo' key or 'serie' + number
        _correlativo = (correlativoData['correlativo'] ??
                correlativoData['numero'] ??
                correlativoData['serie'] ??
                '')
            .toString();
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaCompra,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: HotelPMSColors.naranjaAcento,
              onPrimary: HotelPMSColors.textoPrincipal,
              surface: HotelPMSColors.fondoTarjeta,
              onSurface: HotelPMSColors.textoPrincipal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _fechaCompra = picked);
    }
  }

  void _agregarProductoAlDetalle() {
    if (_selectedProducto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un producto'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cantidad = double.tryParse(_cantidadController.text) ?? 1;
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad debe ser mayor a 0'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final idProducto = _selectedProducto!['id_producto'] ?? 0;
    final nombreProducto =
        _selectedProducto!['nombre_producto'] ?? 'Producto';
    // precio from API response; might be 'precio' or 'precio_venta'
    final precio =
        (_selectedProducto!['precio'] ?? _selectedProducto!['precio_venta'] ?? 0)
            .toDouble();

    // Check if product already added — if so, update quantity
    final existingIndex =
        _detalleItems.indexWhere((item) => item.idProducto == idProducto);
    if (existingIndex >= 0) {
      _detalleItems[existingIndex].cantidad += cantidad;
    } else {
      _detalleItems.add(_DetalleItem(
        idProducto: idProducto,
        nombreProducto: nombreProducto.toString(),
        cantidad: cantidad,
        precio: precio,
      ));
    }

    setState(() {
      _selectedProducto = null;
      _cantidadController.text = '1';
    });
  }

  void _eliminarDetalle(int index) {
    setState(() => _detalleItems.removeAt(index));
  }

  Future<void> _guardarCompra() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProveedor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un proveedor'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_detalleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agregue al menos un producto a la compra'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'num_comprobante': _numComprobanteController.text.trim(),
        'fecha_compra': _formatFecha(_fechaCompra),
        'total_compra': _totalCompra,
        'sucursal': {'id': 1},
        'proveedor': {
          'ruc_proveedor': _selectedProveedor!['ruc_proveedor'] ?? '',
        },
        'detalleCompra': _detalleItems.map((item) {
          return {
            'producto': {'id_producto': item.idProducto},
            'cantidad': item.cantidad,
            'precio': item.precio,
          };
        }).toList(),
      };

      await ComprasService.crearCompra(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra registrada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        NombresRutas.comprasLista,
        (route) => route.settings.name == NombresRutas.comprasLista,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar compra: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Compras / Nueva Compra',
      rutaActual: NombresRutas.comprasNueva,
      cuerpo: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: HotelPMSColors.naranjaAcento,
              ),
            )
          : _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Nueva Compra',
                    style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Registra una nueva orden de compra',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 24),

            // === SECCIÓN: DATOS GENERALES ===
            _buildSeccionLabel('DATOS GENERALES'),
            const SizedBox(height: 12),

            // Proveedor dropdown
            _buildDropdownField(
              label: 'Proveedor *',
              value: _selectedProveedor,
              items: _proveedores.map((p) {
                final ruc = p['ruc_proveedor'] ?? '';
                final nombre = p['nombre_proveedor'] ?? '';
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: p,
                  child: Text(
                    '$ruc — $nombre',
                    style: const TextStyle(
                        color: HotelPMSColors.textoPrincipal),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) =>
                  setState(() => _selectedProveedor = val),
            ),
            const SizedBox(height: 16),

            // N° Comprobante
            TextFormField(
              controller: _numComprobanteController,
              style:
                  const TextStyle(color: HotelPMSColors.textoPrincipal),
              decoration: _inputDecoration(
                label: 'N° Documento',
                hint: 'F001-000001',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El número de documento es obligatorio'
                  : null,
            ),
            const SizedBox(height: 16),

            // Fecha + Correlativo row
            Row(
              children: [
                // Fecha
                Expanded(
                  child: InkWell(
                    onTap: _seleccionarFecha,
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        label: 'Fecha',
                        hint: _formatFecha(_fechaCompra),
                        suffixIcon: Icons.calendar_today,
                      ),
                      child: Text(
                        _formatFecha(_fechaCompra),
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Correlativo (read-only)
                Expanded(
                  child: TextFormField(
                    initialValue: _correlativo,
                    readOnly: true,
                    style: const TextStyle(
                      color: HotelPMSColors.textoSecundario,
                    ),
                    decoration: _inputDecoration(
                      label: 'Correlativo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // === SECCIÓN: PRODUCTOS ===
            _buildSeccionLabel('PRODUCTOS'),
            const SizedBox(height: 12),

            // Agregar producto: dropdown + cantidad + botón
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Producto dropdown
                  _buildDropdownField(
                    label: 'Producto',
                    value: _selectedProducto,
                    items: _productosDisponibles.map((p) {
                      final id = p['id_producto'] ?? '';
                      final nombre = p['nombre_producto'] ?? '';
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: p,
                        child: Text(
                          '$id — $nombre',
                          style: const TextStyle(
                              color: HotelPMSColors.textoPrincipal),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedProducto = val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Cantidad
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadController,
                          style: const TextStyle(
                              color: HotelPMSColors.textoPrincipal),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          decoration: _inputDecoration(
                            label: 'Cantidad',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Agregar
                      ElevatedButton.icon(
                        onPressed: _agregarProductoAlDetalle,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HotelPMSColors.naranjaAcento,
                          foregroundColor:
                              HotelPMSColors.textoPrincipal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabla de detalle de productos
            if (_detalleItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No hay productos agregados',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HotelPMSColors.textoSecundario,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoTarjeta,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                        HotelPMSColors.fondoOscuro),
                    headingRowHeight: 42,
                    dataRowHeight: 48,
                    columns: [
                      DataColumn(label: Text('PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal))),
                      DataColumn(label: Text('CANTIDAD', style: TextStyle(fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal))),
                      DataColumn(label: Text('PRECIO', style: TextStyle(fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal))),
                      DataColumn(label: Text('SUBTOTAL', style: TextStyle(fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal))),
                      DataColumn(label: Text('')),
                    ],
                    rows: List.generate(_detalleItems.length, (i) {
                      final item = _detalleItems[i];
                      return DataRow(cells: [
                        DataCell(Text(
                          item.nombreProducto,
                          style: const TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                          ),
                        )),
                        DataCell(Text(
                          item.cantidad.toStringAsFixed(
                              item.cantidad == item.cantidad.roundToDouble()
                                  ? 0
                                  : 2),
                          style: const TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                          ),
                        )),
                        DataCell(Text(
                          'S/. ${item.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: HotelPMSColors.naranjaAcento,
                          ),
                        )),
                        DataCell(Text(
                          'S/. ${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        DataCell(IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: HotelPMSColors.textoEliminar,
                            size: 18,
                          ),
                          onPressed: () => _eliminarDetalle(i),
                        )),
                      ]);
                    }),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoOscuro,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'S/. ${_totalCompra.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: HotelPMSColors.naranjaAcento,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HotelPMSColors.textoSecundario,
                      side: const BorderSide(
                        color: HotelPMSColors.textoSecundario,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSubmitting ? null : _guardarCompra,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: HotelPMSColors.textoPrincipal,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                        _isSubmitting ? 'Guardando...' : 'Guardar Compra'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HotelPMSColors.naranjaAcento,
                      foregroundColor: HotelPMSColors.textoPrincipal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: HotelPMSColors.naranjaAcento,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoInput,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: HotelPMSColors.fondoTarjeta,
        style: const TextStyle(color: HotelPMSColors.textoPrincipal),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: HotelPMSTextStyles.subtituloGris,
          border: InputBorder.none,
        ),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: HotelPMSTextStyles.subtituloGris,
      labelStyle: HotelPMSTextStyles.subtituloGris,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: HotelPMSColors.naranjaAcento, size: 20)
          : null,
      filled: true,
      fillColor: HotelPMSColors.fondoInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

}
