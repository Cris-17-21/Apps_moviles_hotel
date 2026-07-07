import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../general/tema/estilos_texto.dart';
import '../../../../general/widgets/pagination_widget.dart';
import '../../../../rutas/nombres_rutas.dart';
import '../../../../core/utils/confirmacion.dart';
import 'servicios/proveedores_service.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({super.key});

  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  List<Map<String, dynamic>> _proveedores = [];
  List<Map<String, dynamic>> _proveedoresFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _filtroBusqueda = '';

  // Paginación server-side
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
    _searchController.addListener(_filtrarProveedores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarProveedores({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await ProveedoresService.obtenerProveedoresPaginados(page: page);
      if (!mounted) return;
      final items = (result['items'] as List<dynamic>)
          .map((p) => p as Map<String, dynamic>)
          .toList();
      setState(() {
        _proveedores = items;
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
            'No se pudieron cargar los proveedores. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarProveedores() {
    _filtroBusqueda = _searchController.text.toLowerCase();
    _aplicarFiltroLocal();
  }

  void _aplicarFiltroLocal() {
    setState(() {
      if (_filtroBusqueda.isEmpty) {
        _proveedoresFiltrados = List.from(_proveedores);
      } else {
        _proveedoresFiltrados = _proveedores.where((p) {
          final razonSocial =
              (p['razon_social'] ?? '').toString().toLowerCase();
          final ruc =
              (p['ruc_proveedor'] ?? '').toString().toLowerCase();
          return razonSocial.contains(_filtroBusqueda) ||
              ruc.contains(_filtroBusqueda);
        }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoCrear() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _ProveedorDialog(titulo: 'Nuevo Proveedor'),
    );

    if (result == null) return;

    final confirmado = await confirmarCreacion(
      context,
      tipoRegistro: 'proveedor',
      detalle: '${result['razonSocial']} — RUC: ${result['ruc']}',
    );
    if (!confirmado) return;

    try {
      await ProveedoresService.crearProveedor({
        'ruc_proveedor': result['ruc'],
        'razon_social': result['razonSocial'],
        'direccion': result['direccion'],
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      mostrarExito(context, 'Proveedor creado exitosamente');
      _cargarProveedores();
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, 'Error al crear proveedor: ${e.toString()}');
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> proveedor) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _ProveedorDialog(
        titulo: 'Editar Proveedor',
        rucInicial: proveedor['ruc_proveedor'] ?? '',
        razonSocialInicial: proveedor['razon_social'] ?? '',
        direccionInicial: proveedor['direccion'] ?? '',
      ),
    );

    if (result == null) return;

    final confirmado = await confirmarEdicion(
      context,
      tipoRegistro: 'proveedor',
      nombre: result['razonSocial'],
    );
    if (!confirmado) return;

    try {
      await ProveedoresService.actualizarProveedor({
        'ruc_proveedor': result['ruc'],
        'razon_social': result['razonSocial'],
        'direccion': result['direccion'],
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      mostrarExito(context, 'Proveedor actualizado exitosamente');
      _cargarProveedores();
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, 'Error al actualizar proveedor: ${e.toString()}');
    }
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> proveedor) async {
    final confirm = await confirmarEliminacion(
      context,
      tipoRegistro: 'proveedor',
      nombre: proveedor['razon_social'],
    );
    if (!confirm) return;

    try {
      await ProveedoresService.eliminarProveedor(
          proveedor['ruc_proveedor'] ?? '');
      if (!mounted) return;
      mostrarExito(context, 'Proveedor eliminado exitosamente');
      _cargarProveedores();
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, 'Error al eliminar proveedor: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Compras / Proveedores',
      rutaActual: NombresRutas.proveedores,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Proveedores',
                    style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra tus proveedores',
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
                  hintText: 'Buscar por RUC, nombre o razón social...',
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

            // Paginación server-side
            if (_totalPages > 1)
              Container(
                color: HotelPMSColors.fondoTarjeta,
                child: PaginationWidget(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  totalItems: _totalItems,
                  onPageChanged: (page) => _cargarProveedores(page: page),
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
              style: const TextStyle(color: HotelPMSColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarProveedores,
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

    if (_proveedoresFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron proveedores.',
          style: TextStyle(color: HotelPMSColors.textoSecundario),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarProveedores,
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
                'RUC',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'RAZÓN SOCIAL',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'DIRECCIÓN',
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
          rows: _proveedoresFiltrados.map((proveedor) {
            final ruc = proveedor['ruc_proveedor'] ?? '';
            final razonSocial = proveedor['razon_social'] ?? '';
            final direccion = proveedor['direccion'] ?? '';

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    ruc.toString(),
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    razonSocial,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    direccion,
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
                        onPressed: () => _mostrarDialogoEditar(proveedor),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outlined,
                          color: HotelPMSColors.textoEliminar,
                          size: 18,
                        ),
                        onPressed: () => _confirmarEliminacion(proveedor),
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

/// Dialog for creating or editing a supplier.
class _ProveedorDialog extends StatefulWidget {
  final String titulo;
  final String? rucInicial;
  final String? razonSocialInicial;
  final String? direccionInicial;

  const _ProveedorDialog({
    required this.titulo,
    this.rucInicial,
    this.razonSocialInicial,
    this.direccionInicial,
  });

  @override
  State<_ProveedorDialog> createState() => _ProveedorDialogState();
}

class _ProveedorDialogState extends State<_ProveedorDialog> {
  late final TextEditingController _rucController;
  late final TextEditingController _razonSocialController;
  late final TextEditingController _direccionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rucController = TextEditingController(text: widget.rucInicial ?? '');
    _razonSocialController =
        TextEditingController(text: widget.razonSocialInicial ?? '');
    _direccionController =
        TextEditingController(text: widget.direccionInicial ?? '');
  }

  @override
  void dispose() {
    _rucController.dispose();
    _razonSocialController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.rucInicial != null &&
        widget.rucInicial!.isNotEmpty;

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
                controller: _rucController,
                enabled: !isEditing,
                style: TextStyle(
                  color: isEditing
                      ? HotelPMSColors.textoSecundario
                      : HotelPMSColors.textoPrincipal,
                ),
                decoration: InputDecoration(
                  labelText: 'RUC',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El RUC es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _razonSocialController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  labelText: 'Razón social',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
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
                'ruc': _rucController.text.trim(),
                'razonSocial': _razonSocialController.text.trim(),
                'direccion': _direccionController.text.trim(),
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
