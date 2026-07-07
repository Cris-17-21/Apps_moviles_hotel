import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/confirmacion.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/permiso_service.dart';
import '../servicios/rol_service.dart';

class PaginaPermisos extends StatefulWidget {
  const PaginaPermisos({super.key});

  @override
  State<PaginaPermisos> createState() => _PaginaPermisosState();
}

class _PaginaPermisosState extends State<PaginaPermisos> {
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _modulos = [];
  Map<int, Set<int>> _permisosPorModulo = {}; // idModulo -> set of idPermiso
  Map<int, Set<int>> _permisosSeleccionados = {}; // idModulo -> set of idPermiso
  int? _rolSeleccionadoId;
  bool _isLoadingRoles = true;
  bool _isLoadingPermisos = false;

  @override
  void initState() {
    super.initState();
    _cargarRoles();
    _cargarModulos();
  }

  Future<void> _cargarRoles() async {
    setState(() {
      _isLoadingRoles = true;
    });
    try {
      final data = await RolService.obtenerRoles();
      setState(() {
        _roles = data;
        _isLoadingRoles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoles = false;
      });
      if (mounted) {
        mostrarError(context, 'No se pudieron cargar los roles.');
      }
    }
  }

  Future<void> _cargarModulos() async {
    try {
      final modulos = await PermisoService.obtenerModulos();
      final Map<int, Set<int>> permisosMap = {};
      for (final modulo in modulos) {
        final idModulo = modulo['idModulo'] as int;
        final permisos = (modulo['permisos'] as List<dynamic>?)
                ?.map((p) => p as Map<String, dynamic>)
                .toList() ??
            [];
        permisosMap[idModulo] = permisos.map((p) => p['id'] as int).toSet();
      }
      setState(() {
        _modulos = modulos;
        _permisosPorModulo = permisosMap;
        // Inicializar selección vacía
        _permisosSeleccionados = {
          for (final id in permisosMap.keys) id: <int>{},
        };
      });
    } catch (e) {
      if (mounted) {
        mostrarError(context, 'Error al cargar módulos: ${e.toString()}');
      }
    }
  }

  Future<void> _onRolSeleccionado(int? idRol) async {
    if (idRol == null) return;

    setState(() {
      _rolSeleccionadoId = idRol;
      _isLoadingPermisos = true;
      // Resetear selección
      _permisosSeleccionados = {
        for (final id in _permisosPorModulo.keys) id: <int>{},
      };
    });

    try {
      final response = await ApiClient.get('/cerro-verde/roles/$idRol');
      if (response.statusCode == 200) {
        final Map<String, dynamic> rolData = jsonDecode(response.body);
        final rolesPermisos = rolData['rolesPermisos'] as List<dynamic>? ?? [];
        final Set<int> idsAsignados = rolesPermisos
            .map((rp) => rp['permisos']?['id'] as int?)
            .whereType<int>()
            .toSet();

        // Agrupar permisos asignados por módulo
        final Map<int, Set<int>> seleccionados = {
          for (final id in _permisosPorModulo.keys) id: <int>{},
        };
        for (final modulo in _modulos) {
          final idModulo = modulo['idModulo'] as int;
          final permisosModulo = _permisosPorModulo[idModulo] ?? {};
          seleccionados[idModulo] =
              permisosModulo.where((p) => idsAsignados.contains(p)).toSet();
        }

        setState(() {
          _permisosSeleccionados = seleccionados;
          _isLoadingPermisos = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingPermisos = false);
      if (mounted) {
        mostrarError(context, 'Error al cargar permisos del rol: ${e.toString()}');
      }
    }
  }

  void _togglePermiso(int idModulo, int idPermiso) {
    setState(() {
      final seleccionados = _permisosSeleccionados[idModulo] ?? {};
      if (seleccionados.contains(idPermiso)) {
        seleccionados.remove(idPermiso);
      } else {
        seleccionados.add(idPermiso);
      }
      _permisosSeleccionados[idModulo] = Set.from(seleccionados);
    });
  }

  void _toggleModulo(int idModulo, bool? seleccionar) {
    if (seleccionar == null) return;
    setState(() {
      _permisosSeleccionados[idModulo] = seleccionar
          ? Set.from(_permisosPorModulo[idModulo] ?? {})
          : <int>{};
    });
  }

  bool _moduloCompleto(int idModulo) {
    final total = _permisosPorModulo[idModulo] ?? {};
    final seleccionados = _permisosSeleccionados[idModulo] ?? {};
    return total.isNotEmpty && total.length == seleccionados.length;
  }

  Future<void> _guardarPermisos() async {
    if (_rolSeleccionadoId == null) return;

    final confirmado = await confirmarEdicion(
      context,
      tipoRegistro: 'permisos del rol',
    );
    if (!confirmado) return;

    // Recolectar todos los IDs de permisos seleccionados
    final List<int> todosLosIds = [];
    for (final entry in _permisosSeleccionados.entries) {
      todosLosIds.addAll(entry.value);
    }

    try {
      await RolService.asignarPermisos(_rolSeleccionadoId!, todosLosIds);
      if (!mounted) return;
      mostrarExito(context, 'Permisos asignados exitosamente');
      Navigator.pushReplacementNamed(context, NombresRutas.roles);
    } catch (e) {
      if (!mounted) return;
      mostrarError(context, 'Error al asignar permisos: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Seguridad / Permisos',
      rutaActual: NombresRutas.permisos,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Asignación de Permisos',
                    style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Selecciona un rol y asigna los permisos disponibles',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // Selector de rol
            _buildSelectorRol(),
            const SizedBox(height: 20),

            // Lista de permisos
            Expanded(
              child: _buildPermisosList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorRol() {
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
          Text('Seleccionar Rol',
              style: HotelPMSTextStyles.tituloTarjeta),
          const SizedBox(height: 12),
          _isLoadingRoles
              ? const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: HotelPMSColors.naranjaAcento,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : DropdownButtonFormField<int>(
                  value: _rolSeleccionadoId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: HotelPMSColors.fondoInput,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '-- Seleccione un rol --',
                    hintStyle: HotelPMSTextStyles.subtituloGris,
                  ),
                  dropdownColor: HotelPMSColors.fondoTarjeta,
                  style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                  items: _roles.map((rol) {
                    return DropdownMenuItem<int>(
                      value: rol['id'] as int,
                      child: Text(rol['nombreRol'] ?? 'Rol ${rol['id']}'),
                    );
                  }).toList(),
                  onChanged: _onRolSeleccionado,
                ),
        ],
      ),
    );
  }

  Widget _buildPermisosList() {
    if (_rolSeleccionadoId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app_outlined,
                size: 48, color: HotelPMSColors.textoSecundario),
            const SizedBox(height: 12),
            Text(
              'Selecciona un rol para\nasignar sus permisos',
              textAlign: TextAlign.center,
              style: HotelPMSTextStyles.subtituloGris,
            ),
          ],
        ),
      );
    }

    if (_isLoadingPermisos) {
      return const Center(
        child: CircularProgressIndicator(
          color: HotelPMSColors.naranjaAcento,
        ),
      );
    }

    if (_modulos.isEmpty) {
      return const Center(
        child: Text(
          'No hay módulos disponibles.',
          style: TextStyle(color: HotelPMSColors.textoSecundario),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _modulos.length,
            itemBuilder: (context, index) => _buildModuloCard(_modulos[index]),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _guardarPermisos,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Permisos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: HotelPMSColors.naranjaAcento,
              foregroundColor: HotelPMSColors.textoPrincipal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuloCard(Map<String, dynamic> modulo) {
    final idModulo = modulo['idModulo'] as int;
    final nombreModulo = modulo['nombre'] ?? 'Módulo';
    final permisos = (modulo['permisos'] as List<dynamic>?)
            ?.map((p) => p as Map<String, dynamic>)
            .toList() ??
        [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Módulo header con checkbox de selección completa
          Row(
            children: [
              Icon(
                _iconForModulo(nombreModulo),
                color: HotelPMSColors.naranjaAcento,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nombreModulo,
                  style: HotelPMSTextStyles.tituloTarjeta,
                ),
              ),
              Checkbox(
                value: _moduloCompleto(idModulo),
                tristate: true,
                onChanged: (value) => _toggleModulo(idModulo, value),
                activeColor: HotelPMSColors.naranjaAcento,
                checkColor: HotelPMSColors.textoPrincipal,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return HotelPMSColors.naranjaAcento;
                  }
                  return HotelPMSColors.fondoInput;
                }),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),

          // Lista de permisos del módulo
          ...permisos.map((permiso) {
            final idPermiso = permiso['id'] as int;
            final nombrePermiso = permiso['nombrePermiso'] ?? 'Permiso';
            final seleccionados = _permisosSeleccionados[idModulo] ?? {};
            final isSelected = seleccionados.contains(idPermiso);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: InkWell(
                onTap: () => _togglePermiso(idModulo, idPermiso),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => _togglePermiso(idModulo, idPermiso),
                        activeColor: HotelPMSColors.naranjaAcento,
                        checkColor: HotelPMSColors.textoPrincipal,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return HotelPMSColors.naranjaAcento;
                          }
                          return HotelPMSColors.fondoInput;
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nombrePermiso,
                        style: TextStyle(
                          color: isSelected
                              ? HotelPMSColors.textoPrincipal
                              : HotelPMSColors.textoSecundario,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _iconForModulo(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('seguridad')) return Icons.security;
    if (n.contains('recepción') || n.contains('recepcion')) return Icons.business;
    if (n.contains('venta')) return Icons.shopping_cart;
    if (n.contains('caja')) return Icons.payments;
    if (n.contains('compra')) return Icons.shopping_cart_outlined;
    if (n.contains('almacén') || n.contains('almacen') || n.contains('inventario')) return Icons.warehouse;
    if (n.contains('mantenimiento')) return Icons.build;
    if (n.contains('reporte')) return Icons.bar_chart;
    if (n.contains('inicio') || n.contains('dashboard')) return Icons.home;
    return Icons.folder_outlined;
  }
}
