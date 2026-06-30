import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/clientes_service.dart';

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

  Future<void> _cargarClientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ClientesService.obtenerClientes();
      setState(() {
        _clientes = data;
        _clientesFiltrados = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los clientes. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarClientes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _clientesFiltrados = _clientes;
      } else {
        _clientesFiltrados = _clientes.where((c) {
          final nombre = (c['nombre'] ?? '').toString().toLowerCase();
          final apellido = (c['apellido'] ?? '').toString().toLowerCase();
          final dni = (c['dni_ruc'] ?? '').toString().toLowerCase();
          return nombre.contains(query) || apellido.contains(query) || dni.contains(query);
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

    try {
      await ClientesService.crearCliente(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente creado correctamente'), backgroundColor: Colors.green),
        );
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear cliente: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> cliente) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _ClienteDialog(titulo: 'Editar Cliente', datosExistentes: cliente),
    );
    if (result == null) return;

    try {
      await ClientesService.actualizarCliente(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente actualizado correctamente'), backgroundColor: Colors.green),
        );
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar cliente: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> cliente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text('Confirmar eliminación', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
        content: Text(
          '¿Eliminar cliente "${cliente['nombre']} ${cliente['apellido']}"?',
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
      await ClientesService.eliminarCliente(cliente['id_cliente'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado correctamente'), backgroundColor: Colors.green),
        );
        _cargarClientes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar cliente: $e'), backgroundColor: Colors.red),
        );
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
          child: _clientesFiltrados.isEmpty
              ? const Center(child: Text('No se encontraron clientes', style: TextStyle(color: HotelPMSColors.textoSecundario)))
              : RefreshIndicator(
                  onRefresh: _cargarClientes,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(HotelPMSColors.fondoInput),
                      dataRowColor: WidgetStateProperty.all(HotelPMSColors.fondoTarjeta),
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Nombre', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Apellido', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('DNI/RUC', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Teléfono', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Acciones', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold))),
                      ],
                      rows: _clientesFiltrados.map((c) => DataRow(cells: [
                        DataCell(Text('${c['id_cliente']}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${c['nombre'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${c['apellido'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${c['dni_ruc'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
                        DataCell(Text('${c['telefono'] ?? ''}', style: const TextStyle(color: HotelPMSColors.textoPrincipal))),
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
  late TextEditingController _apellidoCtrl;
  late TextEditingController _dniCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.datosExistentes ?? {};
    _nombreCtrl = TextEditingController(text: d['nombre']?.toString() ?? '');
    _apellidoCtrl = TextEditingController(text: d['apellido']?.toString() ?? '');
    _dniCtrl = TextEditingController(text: d['dni_ruc']?.toString() ?? '');
    _telefonoCtrl = TextEditingController(text: d['telefono']?.toString() ?? '');
    _direccionCtrl = TextEditingController(text: d['direccion']?.toString() ?? '');
    _emailCtrl = TextEditingController(text: d['email']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'dni_ruc': _dniCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
    };
    final existentes = widget.datosExistentes;
    if (existentes != null && existentes.containsKey('id_cliente')) {
      data['id_cliente'] = existentes['id_cliente'];
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
              _campo('Apellido', _apellidoCtrl, required: true),
              _campo('DNI/RUC', _dniCtrl, required: true),
              _campo('Teléfono', _telefonoCtrl),
              _campo('Dirección', _direccionCtrl),
              _campo('Email', _emailCtrl),
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
