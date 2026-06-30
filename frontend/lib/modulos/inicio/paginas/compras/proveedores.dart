import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../general/tema/estilos_texto.dart';
import '../../../../rutas/nombres_rutas.dart';
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

  Future<void> _cargarProveedores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ProveedoresService.obtenerProveedores();
      setState(() {
        _proveedores = data;
        _proveedoresFiltrados = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'No se pudieron cargar los proveedores. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarProveedores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _proveedoresFiltrados = _proveedores;
      } else {
        _proveedoresFiltrados = _proveedores.where((p) {
          final nombre =
              (p['nombre_proveedor'] ?? '').toString().toLowerCase();
          final ruc = (p['ruc_proveedor'] ?? '').toString().toLowerCase();
          final razonSocial =
              (p['razon_social'] ?? '').toString().toLowerCase();
          return nombre.contains(query) ||
              ruc.contains(query) ||
              razonSocial.contains(query);
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

    try {
      await ProveedoresService.crearProveedor({
        'ruc_proveedor': result['ruc'],
        'nombre_proveedor': result['nombre'],
        'razon_social': result['razonSocial'],
        'direccion_proveedor': result['direccion'],
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proveedor creado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarProveedores();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear proveedor: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> proveedor) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _ProveedorDialog(
        titulo: 'Editar Proveedor',
        rucInicial: proveedor['ruc_proveedor'] ?? '',
        nombreInicial: proveedor['nombre_proveedor'] ?? '',
        razonSocialInicial: proveedor['razon_social'] ?? '',
        direccionInicial: proveedor['direccion_proveedor'] ?? '',
      ),
    );

    if (result == null) return;

    try {
      await ProveedoresService.actualizarProveedor({
        'ruc_proveedor': result['ruc'],
        'nombre_proveedor': result['nombre'],
        'razon_social': result['razonSocial'],
        'direccion_proveedor': result['direccion'],
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proveedor actualizado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarProveedores();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar proveedor: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> proveedor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: HotelPMSColors.textoPrincipal),
        ),
        content: Text(
          '¿Está seguro de eliminar al proveedor "${proveedor['nombre_proveedor']}"?',
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
      await ProveedoresService.eliminarProveedor(
          proveedor['ruc_proveedor'] ?? '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proveedor eliminado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarProveedores();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar proveedor: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            final nombre = proveedor['nombre_proveedor'] ?? '';
            final razonSocial = proveedor['razon_social'] ?? '';
            final direccion = proveedor['direccion_proveedor'] ?? '';

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
                    nombre,
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
  final String? nombreInicial;
  final String? razonSocialInicial;
  final String? direccionInicial;

  const _ProveedorDialog({
    required this.titulo,
    this.rucInicial,
    this.nombreInicial,
    this.razonSocialInicial,
    this.direccionInicial,
  });

  @override
  State<_ProveedorDialog> createState() => _ProveedorDialogState();
}

class _ProveedorDialogState extends State<_ProveedorDialog> {
  late final TextEditingController _rucController;
  late final TextEditingController _nombreController;
  late final TextEditingController _razonSocialController;
  late final TextEditingController _direccionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rucController = TextEditingController(text: widget.rucInicial ?? '');
    _nombreController = TextEditingController(text: widget.nombreInicial ?? '');
    _razonSocialController =
        TextEditingController(text: widget.razonSocialInicial ?? '');
    _direccionController =
        TextEditingController(text: widget.direccionInicial ?? '');
  }

  @override
  void dispose() {
    _rucController.dispose();
    _nombreController.dispose();
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
                controller: _nombreController,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  labelText: 'Nombre del proveedor',
                  labelStyle: HotelPMSTextStyles.subtituloGris,
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
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
                'nombre': _nombreController.text.trim(),
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
