import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/mantenimiento_service.dart';

class PaginaPersonalLimpieza extends StatefulWidget {
  const PaginaPersonalLimpieza({super.key});

  @override
  State<PaginaPersonalLimpieza> createState() => _PaginaPersonalLimpiezaState();
}

class _PaginaPersonalLimpiezaState extends State<PaginaPersonalLimpieza> {
  List<Map<String, dynamic>> _personal = [];
  List<Map<String, dynamic>> _personalFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
    _searchController.addListener(_filtrarPersonal);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPersonal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await MantenimientoService.obtenerPersonalLimpieza();
      setState(() {
        _personal = data;
        _personalFiltrados = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo cargar el personal de limpieza. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarPersonal() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _personalFiltrados = _personal;
      } else {
        _personalFiltrados = _personal.where((p) {
          final nombre = (p['nombre'] ?? '').toString().toLowerCase();
          final apellido = (p['apellido'] ?? '').toString().toLowerCase();
          final dni = (p['dni'] ?? '').toString().toLowerCase();
          return nombre.contains(query) || apellido.contains(query) || dni.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoCrear() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _PersonalDialog(titulo: 'Nuevo Personal'),
    );
    if (result == null) return;

    try {
      result['sucursal'] = {'id': 1};
      await MantenimientoService.crearPersonalLimpieza(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal creado correctamente'), backgroundColor: Colors.green),
        );
        _cargarPersonal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear personal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> persona) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _PersonalDialog(titulo: 'Editar Personal', datosExistentes: persona),
    );
    if (result == null) return;

    try {
      result['sucursal'] = {'id': 1};
      await MantenimientoService.actualizarPersonalLimpieza(persona['id'] as int, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal actualizado correctamente'), backgroundColor: Colors.green),
        );
        _cargarPersonal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar personal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> persona) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text('Confirmar eliminación', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
        content: Text(
          '¿Eliminar a "${persona['nombre']} ${persona['apellido']}"?',
          style: const TextStyle(color: HotelPMSColors.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoSecundario)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: HotelPMSColors.textoEliminar)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await MantenimientoService.eliminarPersonalLimpieza(persona['id'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal eliminado correctamente'), backgroundColor: Colors.green),
        );
        _cargarPersonal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar personal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HotelPMSColors.fondoOscuro,
      body: LayoutPrincipal(
        rutaActual: NombresRutas.personalLimpieza,
        tituloBarra: 'HotelPMS',
        cuerpo: _buildCuerpo(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrear,
        backgroundColor: HotelPMSColors.naranjaAcento,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCuerpo() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: HotelPMSColors.naranjaAcento));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, color: HotelPMSColors.textoEliminar, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: HotelPMSColors.textoSecundario)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPersonal,
              style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento, foregroundColor: Colors.white),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.cleaning_services_outlined, color: HotelPMSColors.naranjaAcento, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Personal de Limpieza',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: HotelPMSColors.textoPrincipal),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, apellido o DNI...',
              hintStyle: const TextStyle(color: HotelPMSColors.textoSecundario),
              prefixIcon: const Icon(Icons.search, color: HotelPMSColors.textoSecundario),
              filled: true,
              fillColor: HotelPMSColors.fondoInput,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _personalFiltrados.isEmpty
              ? const Center(child: Text('No se encontró personal', style: TextStyle(color: HotelPMSColors.textoSecundario)))
              : RefreshIndicator(
                  onRefresh: _cargarPersonal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(HotelPMSColors.fondoInput),
                      dataRowColor: WidgetStateProperty.all(HotelPMSColors.fondoTarjeta),
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Nombre', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Apellido', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('DNI', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Teléfono', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Turno', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Acciones', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                      ],
                      rows: _personalFiltrados.map((p) => DataRow(cells: [
                        DataCell(Text('${p['id'] ?? p['id_personal'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['nombre'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['apellido'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['dni'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['telefono'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['turno'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: HotelPMSColors.naranjaAcento, size: 20),
                              onPressed: () => _mostrarDialogoEditar(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: HotelPMSColors.textoEliminar, size: 20),
                              onPressed: () => _confirmarEliminar(p),
                            ),
                          ],
                        )),
                      ])).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PersonalDialog extends StatefulWidget {
  final String titulo;
  final Map<String, dynamic>? datosExistentes;

  const _PersonalDialog({required this.titulo, this.datosExistentes});

  @override
  State<_PersonalDialog> createState() => _PersonalDialogState();
}

class _PersonalDialogState extends State<_PersonalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _dniCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _turnoCtrll;

  @override
  void initState() {
    super.initState();
    final d = widget.datosExistentes ?? {};
    _nombreCtrl = TextEditingController(text: d['nombre']?.toString() ?? '');
    _apellidoCtrl = TextEditingController(text: d['apellido']?.toString() ?? '');
    _dniCtrl = TextEditingController(text: d['dni']?.toString() ?? '');
    _telefonoCtrl = TextEditingController(text: d['telefono']?.toString() ?? '');
    _turnoCtrll = TextEditingController(text: d['turno']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _turnoCtrll.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'dni': _dniCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'turno': _turnoCtrll.text.trim(),
    };
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      title: Text(widget.titulo, style: const TextStyle(color: HotelPMSColors.textoPrincipal)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo('Nombre', _nombreCtrl, required: true),
              _campo('Apellido', _apellidoCtrl, required: true),
              _campo('DNI', _dniCtrl, required: true),
              _campo('Teléfono', _telefonoCtrl),
              _campo('Turno', _turnoCtrll),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoSecundario)),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento, foregroundColor: Colors.white),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _campo(String label, TextEditingController ctrl, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: HotelPMSColors.textoPrincipal),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: HotelPMSColors.textoSecundario),
          filled: true,
          fillColor: HotelPMSColors.fondoOscuro,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null : null,
      ),
    );
  }
}
