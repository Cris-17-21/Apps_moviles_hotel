import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/mantenimiento_service.dart';
import '../../../core/utils/confirmacion.dart';

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
          final nombres = (p['nombres'] ?? '').toString().toLowerCase();
          return nombres.contains(query);
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

    final confirmado = await confirmarCreacion(
      context,
      tipoRegistro: 'personal',
      detalle: result['nombres']?.toString() ?? '',
    );
    if (confirmado != true) return;

    try {
      result['sucursal'] = {'id': 1};
      await MantenimientoService.crearPersonalLimpieza(result);
      if (mounted) {
        mostrarExito(context, 'Personal creado correctamente');
        _cargarPersonal();
      }
    } catch (e) {
      if (mounted) {
        mostrarErrorException(context, e);
      }
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> persona) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _PersonalDialog(titulo: 'Editar Personal', datosExistentes: persona),
    );
    if (result == null) return;

    final confirmado = await confirmarEdicion(
      context,
      tipoRegistro: 'personal',
      nombre: persona['nombres']?.toString() ?? '',
    );
    if (confirmado != true) return;

    try {
      result['sucursal'] = {'id': 1};
      await MantenimientoService.actualizarPersonalLimpieza(persona['id_personal_limpieza'] as int, result);
      if (mounted) {
        mostrarExito(context, 'Personal actualizado correctamente');
        _cargarPersonal();
      }
    } catch (e) {
      if (mounted) {
        mostrarErrorException(context, e);
      }
    }
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> persona) async {
    final confirm = await confirmarEliminacion(
      context,
      tipoRegistro: 'personal',
      nombre: persona['nombres']?.toString() ?? '',
    );
    if (confirm != true) return;

    try {
      await MantenimientoService.eliminarPersonalLimpieza(persona['id_personal_limpieza'] as int);
      if (mounted) {
        mostrarExito(context, 'Personal eliminado correctamente');
        _cargarPersonal();
      }
    } catch (e) {
      if (mounted) {
        mostrarErrorException(context, e);
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
                        DataColumn(label: Text('Nombres', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Sucursal', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Acciones', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                      ],
                      rows: _personalFiltrados.map((p) => DataRow(cells: [
                        DataCell(Text('${p['id_personal_limpieza'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['nombres'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${p['sucursal'] is Map ? p['sucursal']['nombre'] ?? '' : ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
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
  late TextEditingController _nombresCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.datosExistentes ?? {};
    _nombresCtrl = TextEditingController(text: d['nombres']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, dynamic>{
      'nombres': _nombresCtrl.text.trim(),
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
              _campo('Nombres completos', _nombresCtrl, required: true),
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
