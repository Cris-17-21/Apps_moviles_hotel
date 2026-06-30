import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/usuario_service.dart';

class PaginaUsuarios extends StatefulWidget {
  const PaginaUsuarios({super.key});

  @override
  State<PaginaUsuarios> createState() => _PaginaUsuariosState();
}

class _PaginaUsuariosState extends State<PaginaUsuarios> {
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _usuariosFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _searchController.addListener(_filtrarUsuarios);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await UsuarioService.obtenerUsuarios();
      setState(() {
        _usuarios = data;
        _usuariosFiltrados = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los usuarios. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _usuariosFiltrados = _usuarios;
      } else {
        _usuariosFiltrados = _usuarios.where((u) {
          final nombreCompleto = '${u['nombre'] ?? ''} ${u['apellidos'] ?? ''}'.toLowerCase();
          final username = (u['username'] ?? '').toString().toLowerCase();
          final email = (u['email'] ?? '').toString().toLowerCase();
          final rolStr = u['rol'] != null
              ? (u['rol']['descripcion'] ?? u['rol']['nombreRol'] ?? '').toString().toLowerCase()
              : '';
          return nombreCompleto.contains(query) ||
              username.contains(query) ||
              email.contains(query) ||
              rolStr.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Seguridad / Usuarios',
      rutaActual: NombresRutas.usuarios,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con Icono, Título y Subtítulo
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Usuarios', style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra los usuarios del sistema',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // Botón "+ Nuevo"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {}, // Aún no hace nada
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
                  hintText: 'Buscar usuarios...',
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

            // Cuerpo dinámico: Loading / Error / Lista
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
              onPressed: _cargarUsuarios,
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

    if (_usuariosFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron usuarios.',
          style: TextStyle(color: HotelPMSColors.textoSecundario),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarUsuarios,
      color: HotelPMSColors.naranjaAcento,
      child: ListView.builder(
        itemCount: _usuariosFiltrados.length,
        itemBuilder: (context, index) {
          final u = _usuariosFiltrados[index];
          final id = u['idUsuario'] ?? u['id'] ?? index + 1;
          final nombre = '${u['nombre'] ?? ''} ${u['apellidos'] ?? ''}'.trim();
          final email = u['email'] ?? '';
          final rolObj = u['rol'];
          final rolName = rolObj != null
              ? (rolObj['descripcion'] ?? rolObj['nombreRol'] ?? 'Usuario')
              : 'Usuario';
          final activo = u['enable'] ?? u['activo'] ?? true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _construirTarjetaUsuario(
              numero: '#$id',
              nombre: nombre.isEmpty ? (u['username'] ?? 'Usuario') : nombre,
              correo: email,
              rol: rolName,
              activo: activo,
            ),
          );
        },
      ),
    );
  }

  Widget _construirTarjetaUsuario({
    required String numero,
    required String nombre,
    required String correo,
    required String rol,
    required bool activo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(numero, style: HotelPMSTextStyles.subtituloGris),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (activo ? HotelPMSColors.habitacionDisponible : HotelPMSColors.textoEliminar).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  activo ? 'Activo' : 'Inactivo',
                  style: HotelPMSTextStyles.estadoBadge.copyWith(
                    color: activo ? HotelPMSColors.habitacionDisponible : HotelPMSColors.textoEliminar,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(nombre, style: HotelPMSTextStyles.tituloTarjeta),
          const SizedBox(height: 2),
          Text(correo, style: HotelPMSTextStyles.subtituloGris),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rol, style: HotelPMSTextStyles.textoRolNaranja),
              Row(
                children: [
                  _botonAccion(
                    Icons.edit_outlined,
                    HotelPMSColors.textoSecundario,
                  ),
                  const SizedBox(width: 8),
                  _botonAccion(
                    Icons.delete_outline,
                    HotelPMSColors.textoEliminar,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonAccion(IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icono, color: color, size: 20),
    );
  }
}
