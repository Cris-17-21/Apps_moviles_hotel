import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/rol_service.dart';

class PaginaRoles extends StatefulWidget {
  const PaginaRoles({super.key});

  @override
  State<PaginaRoles> createState() => _PaginaRolesState();
}

class _PaginaRolesState extends State<PaginaRoles> {
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _rolesFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarRoles();
    _searchController.addListener(_filtrarRoles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarRoles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await RolService.obtenerRoles();
      setState(() {
        _roles = data;
        _rolesFiltrados = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los roles. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarRoles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _rolesFiltrados = _roles;
      } else {
        _rolesFiltrados = _roles.where((r) {
          final nombre = (r['nombreRol'] ?? '').toString().toLowerCase();
          final descripcion = (r['descripcion'] ?? '').toString().toLowerCase();
          return nombre.contains(query) || descripcion.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoCrear() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _RolDialog(titulo: 'Nuevo Rol'),
    );

    if (result == null) return;

    try {
      await RolService.crearRol({
        'nombreRol': result['nombre'],
        'descripcion': result['descripcion'],
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rol creado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarRoles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear rol: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _mostrarDialogoEditar(Map<String, dynamic> rol) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _RolDialog(
        titulo: 'Editar Rol',
        nombreInicial: rol['nombreRol'] ?? '',
        descripcionInicial: rol['descripcion'] ?? '',
      ),
    );

    if (result == null) return;

    try {
      await RolService.actualizarRol({
        'id': rol['id'],
        'nombreRol': result['nombre'],
        'descripcion': result['descripcion'],
        'sucursal': {'id': 1},
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rol actualizado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarRoles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar rol: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> rol) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: HotelPMSColors.textoPrincipal),
        ),
        content: Text(
          '¿Está seguro de eliminar el rol "${rol['nombreRol']}"?',
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
      await RolService.eliminarRol(rol['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rol eliminado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarRoles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar rol: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Seguridad / Roles',
      rutaActual: NombresRutas.roles,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Roles', style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra roles y permisos',
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
                  hintText: 'Buscar roles...',
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
              onPressed: _cargarRoles,
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

    if (_rolesFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron roles.',
          style: TextStyle(color: HotelPMSColors.textoSecundario),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarRoles,
      color: HotelPMSColors.naranjaAcento,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(HotelPMSColors.fondoOscuro),
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
                'ACCIONES',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          rows: _rolesFiltrados.map((rol) {
            final id = rol['id'] ?? '';
            final nombre = rol['nombreRol'] ?? '';
            final descripcion = rol['descripcion'] ?? '';

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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: HotelPMSColors.textoSecundario,
                          size: 18,
                        ),
                        onPressed: () => _mostrarDialogoEditar(rol),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outlined,
                          color: HotelPMSColors.textoEliminar,
                          size: 18,
                        ),
                        onPressed: () => _confirmarEliminacion(rol),
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

/// Dialog for creating or editing a role.
class _RolDialog extends StatefulWidget {
  final String titulo;
  final String? nombreInicial;
  final String? descripcionInicial;

  const _RolDialog({
    required this.titulo,
    this.nombreInicial,
    this.descripcionInicial,
  });

  @override
  State<_RolDialog> createState() => _RolDialogState();
}

class _RolDialogState extends State<_RolDialog> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial ?? '');
    _descripcionController = TextEditingController(text: widget.descripcionInicial ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
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
                  labelText: 'Nombre del rol',
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
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'La descripción es obligatoria' : null,
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
