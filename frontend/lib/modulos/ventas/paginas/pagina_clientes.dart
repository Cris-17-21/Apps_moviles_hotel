import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../../../general/widgets/pagination_widget.dart';
import '../servicios/clientes_service.dart';
import '../../../core/utils/confirmacion.dart';

class PaginaClientes extends StatefulWidget {
  const PaginaClientes({super.key});

  @override
  State<PaginaClientes> createState() => _PaginaClientesState();
}

class _PaginaClientesState extends State<PaginaClientes> {
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _clientesFiltrados = [];
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
    _cargarClientes();
    _searchController.addListener(_filtrarClientes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ClientesService.obtenerClientes(page: page);
      if (!mounted) return;
      final items = (result['items'] as List<dynamic>).map((c) => c as Map<String, dynamic>).toList();
      setState(() {
        _clientes = items;
        _currentPage = page;
        _totalPages = result['totalPages'] as int;
        _totalItems = result['totalElements'] as int;
        _isLoading = false;
      });
      _aplicarFiltroLocal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudieron cargar los clientes. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarClientes() {
    _filtroBusqueda = _searchController.text.toLowerCase();
    _aplicarFiltroLocal();
  }

  void _aplicarFiltroLocal() {
    setState(() {
      if (_filtroBusqueda.isEmpty) {
        _clientesFiltrados = List.from(_clientes);
      } else {
        _clientesFiltrados = _clientes.where((c) {
          final nombre = (c['nombre'] ?? '').toString().toLowerCase();
          final dni = (c['dniRuc'] ?? '').toString().toLowerCase();
          final telefono = (c['telefono'] ?? '').toString().toLowerCase();
          return nombre.contains(_filtroBusqueda) || dni.contains(_filtroBusqueda) || telefono.contains(_filtroBusqueda);
        }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoCrear() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _ClienteDialog(titulo: 'Nuevo Cliente'),
    );
    if (result == null) return;

    final confirmado = await confirmarCreacion(
      context,
      tipoRegistro: 'cliente',
      detalle: result['nombre']?.toString() ?? '',
    );
    if (confirmado != true) return;

    try {
      await ClientesService.crearCliente(result);
      if (mounted) {
        mostrarExito(context, 'Cliente creado correctamente');
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        mostrarErrorException(context, e);
      }
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> cliente) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _ClienteDialog(titulo: 'Editar Cliente', datosExistentes: cliente),
    );
    if (result == null) return;

    final confirmado = await confirmarEdicion(
      context,
      tipoRegistro: 'cliente',
      nombre: cliente['nombre']?.toString() ?? '',
    );
    if (confirmado != true) return;

    try {
      await ClientesService.actualizarCliente(result);
      if (mounted) {
        mostrarExito(context, 'Cliente actualizado correctamente');
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        mostrarErrorException(context, e);
      }
    }
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> cliente) async {
    final confirm = await confirmarEliminacion(
      context,
      tipoRegistro: 'cliente',
      nombre: cliente['nombre']?.toString() ?? '',
    );
    if (confirm != true) return;

    try {
      await ClientesService.eliminarCliente(cliente['idCliente'] as int);
      if (mounted) {
        mostrarExito(context, 'Cliente eliminado correctamente');
        _cargarClientes();
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
        rutaActual: NombresRutas.clientes,
        tituloBarra: 'HotelPMS',
        cuerpo: _buildCuerpo(),
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
              onPressed: _cargarClientes,
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
              const Icon(Icons.people_outline, color: HotelPMSColors.naranjaAcento, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Clientes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal),
              ),
            ],
          ),
        ),
        // Botón Nuevo Cliente
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mostrarDialogoCrear,
              style: ElevatedButton.styleFrom(
                backgroundColor: HotelPMSColors.naranjaAcento,
                foregroundColor: HotelPMSColors.textoPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: HotelPMSColors.textoPrincipal),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, documento o teléfono...',
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
          child: _clientesFiltrados.isEmpty
              ? const Center(child: Text('No se encontraron clientes', style: TextStyle(color: HotelPMSColors.textoSecundario)))
              : RefreshIndicator(
                  onRefresh: _cargarClientes,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                          child: DataTable(
                          headingRowColor: WidgetStateProperty.all(HotelPMSColors.fondoInput),
                          dataRowColor: WidgetStateProperty.all(HotelPMSColors.fondoTarjeta),
                          columns: const [
                            DataColumn(label: Text('ID', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Nombre', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Documento', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Teléfono', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Correo', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Acciones', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                          ],
                          rows: _clientesFiltrados.map((c) => DataRow(cells: [
                            DataCell(Text('${c['idCliente']}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                            DataCell(Text('${c['nombre'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                            DataCell(Text('${c['dniRuc'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                            DataCell(Text('${c['telefono'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                            DataCell(Text('${c['correo'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: HotelPMSColors.naranjaAcento, size: 20),
                                  onPressed: () => _mostrarDialogoEditar(c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: HotelPMSColors.textoEliminar, size: 20),
                                  onPressed: () => _confirmarEliminar(c),
                                ),
                              ],
                            )),
                          ])).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        // Paginación server-side
        if (_totalPages > 1)
          Container(
            color: HotelPMSColors.fondoTarjeta,
            child: PaginationWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              totalItems: _totalItems,
              onPageChanged: (page) => _cargarClientes(page: page),
            ),
          ),
      ],
    );
  }
}

class _ClienteDialog extends StatefulWidget {
  final String titulo;
  final Map<String, dynamic>? datosExistentes;

  const _ClienteDialog({required this.titulo, this.datosExistentes});

  @override
  State<_ClienteDialog> createState() => _ClienteDialogState();
}

class _ClienteDialogState extends State<_ClienteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _dniCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.datosExistentes ?? {};
    _nombreCtrl = TextEditingController(text: d['nombre']?.toString() ?? '');
    _dniCtrl = TextEditingController(text: d['dniRuc']?.toString() ?? '');
    _telefonoCtrl = TextEditingController(text: d['telefono']?.toString() ?? '');
    _emailCtrl = TextEditingController(text: d['correo']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'dniRuc': _dniCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'correo': _emailCtrl.text.trim(),
    };
    final existentes = widget.datosExistentes;
    if (existentes != null && existentes.containsKey('idCliente')) {
      data['idCliente'] = existentes['idCliente'];
    }
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
              _campo('DNI/RUC', _dniCtrl),
              _campo('Teléfono', _telefonoCtrl),
              _campo('Correo', _emailCtrl),
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
