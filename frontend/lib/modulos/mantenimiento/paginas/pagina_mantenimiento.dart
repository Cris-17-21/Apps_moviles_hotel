import 'package:flutter/material.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../general/tema/colores_tema.dart';
import '../servicios/mantenimiento_service.dart';
import '../../recepcion/servicios/habitacion_service.dart';

class PaginaMantenimiento extends StatefulWidget {
  const PaginaMantenimiento({super.key});

  @override
  State<PaginaMantenimiento> createState() => _PaginaMantenimientoState();
}

class _PaginaMantenimientoState extends State<PaginaMantenimiento> {
  List<Map<String, dynamic>> _limpiezas = [];
  List<Map<String, dynamic>> _personalLimpieza = [];
  List<Map<String, dynamic>> _incidencias = [];
  List<Map<String, dynamic>> _habitaciones = [];
  List<Map<String, dynamic>> _tiposIncidencia = [];
  List<Map<String, dynamic>> _areasHotel = [];

  bool _cargandoLimpiezas = true;
  bool _cargandoIncidencias = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargandoLimpiezas = true;
      _cargandoIncidencias = true;
    });
    try {
      final limpiezasData = await MantenimientoService.obtenerLimpiezas();
      final personalData = await MantenimientoService.obtenerPersonalLimpieza();
      final incidenciasData = await MantenimientoService.obtenerIncidencias();
      final habsData = await HabitacionService.obtenerHabitaciones();
      final tiposIncData = await MantenimientoService.obtenerTiposIncidencia();
      final areasData = await MantenimientoService.obtenerAreasHotel();

      setState(() {
        _limpiezas = limpiezasData;
        _personalLimpieza = personalData;
        _incidencias = incidenciasData;
        _habitaciones = habsData;
        _tiposIncidencia = tiposIncData;
        _areasHotel = areasData;
        _cargandoLimpiezas = false;
        _cargandoIncidencias = false;
      });
    } catch (e) {
      setState(() {
        _cargandoLimpiezas = false;
        _cargandoIncidencias = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: LayoutPrincipal(
        rutaActual: '/mantenimiento',
        tituloBarra: 'HotelPMS',
        cuerpo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.construction,
                    color: HotelPMSColors.naranjaAcento,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mantenimiento',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HotelPMSColors.textoPrincipal,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: HotelPMSColors.naranjaAcento),
                    onPressed: _cargarDatos,
                  ),
                ],
              ),
            ),
            Container(
              color: HotelPMSColors.fondoTarjeta,
              child: const TabBar(
                labelColor: HotelPMSColors.naranjaAcento,
                unselectedLabelColor: HotelPMSColors.textoSecundario,
                indicatorColor: HotelPMSColors.naranjaAcento,
                tabs: [
                  Tab(text: 'Limpiezas', icon: Icon(Icons.cleaning_services_outlined)),
                  Tab(text: 'Incidencias', icon: Icon(Icons.warning_amber_rounded)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _construirTabLimpiezas(),
                  _construirTabIncidencias(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTabLimpiezas() {
    if (_cargandoLimpiezas) {
      return const Center(child: CircularProgressIndicator(color: HotelPMSColors.naranjaAcento));
    }
    if (_limpiezas.isEmpty) {
      return const Center(
        child: Text('No hay tareas de limpieza registradas', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _limpiezas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final l = _limpiezas[index];
        final id = l['id_limpieza'] as int;
        final roomNum = l['habitacion']?['numero']?.toString();
        final salonName = l['salon']?['nombre']?.toString();
        final targetStr = roomNum != null ? 'Habitación $roomNum' : (salonName ?? 'Área General');
        final fecha = l['fecha_registro']?.toString().split('T')[0] ?? '';
        final staffName = l['personalLimpieza']?['nombre']?.toString() ?? 'Sin asignar';
        final estado = l['estado_limpieza']?.toString() ?? 'Pendiente';

        return _buildTarjetaLimpieza(
          id: id,
          target: targetStr,
          fecha: fecha,
          staff: staffName,
          estado: estado,
          cleaningMap: l,
        );
      },
    );
  }

  Widget _buildTarjetaLimpieza({
    required int id,
    required String target,
    required String fecha,
    required String staff,
    required String estado,
    required Map<String, dynamic> cleaningMap,
  }) {
    Color estadoFondo = const Color(0xFF27272A);
    Color estadoTexto = const Color(0xFFD4D4D8);
    if (estado == 'En Proceso') {
      estadoFondo = Colors.blue.withAlpha((0.15 * 255).round());
      estadoTexto = Colors.blueAccent;
    } else if (estado == 'Completado') {
      estadoFondo = Colors.green.withAlpha((0.15 * 255).round());
      estadoTexto = Colors.greenAccent;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HotelPMSColors.fondoInput.withAlpha((0.5 * 255).round()), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoFondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: estadoTexto,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HotelPMSColors.naranjaAcento,
                    foregroundColor: HotelPMSColors.textoPrincipal,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  onPressed: () => _mostrarDialogoActualizarLimpieza(id, cleaningMap),
                  child: const Text(
                    'Actualizar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            target,
            style: const TextStyle(
              color: HotelPMSColors.textoPrincipal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Asignado:',
                      style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staff,
                      style: const TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Fecha:',
                    style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fecha,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoActualizarLimpieza(int id, Map<String, dynamic> cleaningMap) {
    String estadoTemporal = cleaningMap['estado_limpieza'] ?? 'Pendiente';
    Map<String, dynamic>? staffTemporal;
    
    if (cleaningMap['personalLimpieza'] != null) {
      staffTemporal = _personalLimpieza.firstWhere(
        (p) => p['id_personal_limpieza'] == cleaningMap['personalLimpieza']['id_personal_limpieza'],
        orElse: () => _personalLimpieza.first,
      );
    } else {
      staffTemporal = _personalLimpieza.isNotEmpty ? _personalLimpieza.first : null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: HotelPMSColors.fondoTarjeta,
              title: const Text(
                'Actualizar Limpieza',
                style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado de la tarea:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...['Pendiente', 'En Proceso', 'Completado'].map((est) {
                      return RadioListTile<String>(
                        title: Text(est, style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14)),
                        value: est,
                        groupValue: estadoTemporal,
                        activeColor: HotelPMSColors.naranjaAcento,
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => estadoTemporal = val);
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text('Asignar Personal:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: HotelPMSColors.fondoInput,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: staffTemporal,
                          isExpanded: true,
                          dropdownColor: HotelPMSColors.fondoInput,
                          icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoSecundario),
                          style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                          onChanged: (val) {
                            setDialogState(() {
                              staffTemporal = val;
                            });
                          },
                          items: _personalLimpieza.map((p) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: p,
                              child: Text(p['nombre']?.toString() ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoSecundario)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento),
                  onPressed: () async {
                    Navigator.pop(context);
                    final payload = Map<String, dynamic>.from(cleaningMap);
                    payload['estado_limpieza'] = estadoTemporal;
                    payload['personalLimpieza'] = staffTemporal;

                    try {
                      await MantenimientoService.actualizarLimpieza(id, payload);
                      _cargarDatos();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar: $e')),
                      );
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _construirTabIncidencias() {
    if (_cargandoIncidencias) {
      return const Center(child: CircularProgressIndicator(color: HotelPMSColors.naranjaAcento));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarModalRegistrarIncidencia(),
              style: ElevatedButton.styleFrom(
                backgroundColor: HotelPMSColors.naranjaAcento,
                foregroundColor: HotelPMSColors.textoPrincipal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Registrar Incidencia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Expanded(
          child: _incidencias.isEmpty
              ? const Center(child: Text('No hay incidencias registradas', style: TextStyle(color: HotelPMSColors.textoPrincipal)))
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: _incidencias.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final inc = _incidencias[index];
                    final id = inc['id_incidencia'] as int;
                    final tipo = inc['tipoIncidencia']?['nombre']?.toString() ?? 'Otro';
                    final desc = inc['descripcion']?.toString() ?? '';
                    final gravedad = inc['gravedad']?.toString() ?? 'media';
                    final estado = inc['estado_incidencia']?.toString() ?? 'pendiente';
                    final resolucion = inc['comentario_resolucion']?.toString() ?? '';

                    final roomNum = inc['habitacion']?['numero']?.toString();
                    final areaName = inc['areasHotel']?['nombre']?.toString();
                    final ubicacion = roomNum != null ? 'Habitación $roomNum' : (areaName ?? 'Área Común');

                    return _buildTarjetaIncidencia(
                      id: id,
                      tipo: tipo,
                      descripcion: desc,
                      gravedad: gravedad,
                      estado: estado,
                      resolucion: resolucion,
                      ubicacion: ubicacion,
                      incidentMap: inc,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTarjetaIncidencia({
    required int id,
    required String tipo,
    required String descripcion,
    required String gravedad,
    required String estado,
    required String resolucion,
    required String ubicacion,
    required Map<String, dynamic> incidentMap,
  }) {
    Color gravedadColor = Colors.grey;
    if (gravedad.toLowerCase() == 'alta') {
      gravedadColor = HotelPMSColors.textoEliminar;
    } else if (gravedad.toLowerCase() == 'media') {
      gravedadColor = HotelPMSColors.naranjaAcento;
    } else if (gravedad.toLowerCase() == 'baja') {
      gravedadColor = HotelPMSColors.textoSecundario;
    }

    Color estadoFondo = const Color(0xFF27272A);
    Color estadoTexto = const Color(0xFFD4D4D8);
    if (estado.toLowerCase() == 'en proceso') {
      estadoFondo = Colors.blue.withAlpha((0.15 * 255).round());
      estadoTexto = Colors.blueAccent;
    } else if (estado.toLowerCase() == 'resuelta') {
      estadoFondo = Colors.green.withAlpha((0.15 * 255).round());
      estadoTexto = Colors.greenAccent;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HotelPMSColors.fondoInput.withAlpha((0.5 * 255).round()), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: gravedadColor.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Gravedad: $gravedad',
                      style: TextStyle(
                        color: gravedadColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoFondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        color: estadoTexto,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HotelPMSColors.naranjaAcento,
                    foregroundColor: HotelPMSColors.textoPrincipal,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  onPressed: () => _mostrarDialogoActualizarIncidencia(id, incidentMap),
                  child: const Text(
                    'Actualizar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tipo,
            style: const TextStyle(
              color: HotelPMSColors.textoPrincipal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ubicación: $ubicacion',
            style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 13),
          ),
          if (resolucion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoOscuro,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resolución:', style: TextStyle(color: HotelPMSColors.naranjaAcento, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(resolucion, style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarDialogoActualizarIncidencia(int id, Map<String, dynamic> incidentMap) {
    String estadoTemporal = incidentMap['estado_incidencia'] ?? 'pendiente';
    final txtResolucion = TextEditingController(text: incidentMap['comentario_resolucion'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: HotelPMSColors.fondoTarjeta,
              title: const Text(
                'Actualizar Incidencia',
                style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado de la incidencia:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                    const SizedBox(height: 8),
                    ...['pendiente', 'en proceso', 'resuelta'].map((est) {
                      return RadioListTile<String>(
                        title: Text(est, style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14)),
                        value: est,
                        groupValue: estadoTemporal,
                        activeColor: HotelPMSColors.naranjaAcento,
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => estadoTemporal = val);
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text('Comentario de resolución:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: HotelPMSColors.fondoInput,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: txtResolucion,
                        maxLines: 2,
                        style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                        decoration: const InputDecoration(
                          hintText: 'Detalles sobre la solución...',
                          hintStyle: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoSecundario)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento),
                  onPressed: () async {
                    Navigator.pop(context);
                    final payload = Map<String, dynamic>.from(incidentMap);
                    payload['estado_incidencia'] = estadoTemporal;
                    payload['comentario_resolucion'] = txtResolucion.text;

                    try {
                      await MantenimientoService.actualizarIncidencia(id, payload);
                      _cargarDatos();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar: $e')),
                      );
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarModalRegistrarIncidencia() {
    final txtDescripcion = TextEditingController();
    Map<String, dynamic>? habitacionSel = _habitaciones.isNotEmpty ? _habitaciones.first : null;
    Map<String, dynamic>? tipoSel = _tiposIncidencia.isNotEmpty ? _tiposIncidencia.first : null;
    Map<String, dynamic>? areaSel = _areasHotel.isNotEmpty ? _areasHotel.first : null;
    String gravedadSel = 'media';
    bool registrarEnHabitacion = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: HotelPMSColors.fondoTarjeta,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Registrar Incidencia',
                style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '¿Es en una Habitación?',
                          style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 13),
                        ),
                        Switch(
                          value: registrarEnHabitacion,
                          activeColor: HotelPMSColors.naranjaAcento,
                          onChanged: (val) {
                            setModalState(() {
                              registrarEnHabitacion = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (registrarEnHabitacion) ...[
                      const Text('Habitación', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: HotelPMSColors.fondoInput, borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: habitacionSel,
                            isExpanded: true,
                            dropdownColor: HotelPMSColors.fondoInput,
                            icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoSecundario),
                            style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                            onChanged: (val) => setModalState(() => habitacionSel = val),
                            items: _habitaciones.map((h) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: h,
                                child: Text('Habitación ${h['numero']}'),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text('Área del Hotel', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: HotelPMSColors.fondoInput, borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            value: areaSel,
                            isExpanded: true,
                            dropdownColor: HotelPMSColors.fondoInput,
                            icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoSecundario),
                            style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                            onChanged: (val) => setModalState(() => areaSel = val),
                            items: _areasHotel.map((a) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: a,
                                child: Text(a['nombre']?.toString() ?? ''),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    const Text('Tipo de Incidencia', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: HotelPMSColors.fondoInput, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: tipoSel,
                          isExpanded: true,
                          dropdownColor: HotelPMSColors.fondoInput,
                          icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoSecundario),
                          style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                          onChanged: (val) => setModalState(() => tipoSel = val),
                          items: _tiposIncidencia.map((t) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: t,
                              child: Text(t['nombre']?.toString() ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Gravedad', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: HotelPMSColors.fondoInput, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: gravedadSel,
                          isExpanded: true,
                          dropdownColor: HotelPMSColors.fondoInput,
                          icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoSecundario),
                          style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                          onChanged: (val) {
                            if (val != null) setModalState(() => gravedadSel = val);
                          },
                          items: ['baja', 'media', 'alta'].map((g) {
                            return DropdownMenuItem<String>(
                              value: g,
                              child: Text(g),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Descripción', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(color: HotelPMSColors.fondoInput, borderRadius: BorderRadius.circular(8)),
                      child: TextField(
                        controller: txtDescripcion,
                        maxLines: 3,
                        style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                        decoration: const InputDecoration(
                          hintText: 'Detalles sobre la incidencia...',
                          hintStyle: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoSecundario)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento),
                  onPressed: () async {
                    if (txtDescripcion.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor ingrese una descripción')),
                      );
                      return;
                    }

                    final payload = <String, dynamic>{
                      'descripcion': txtDescripcion.text,
                      'gravedad': gravedadSel,
                      'estado_incidencia': 'pendiente',
                      'comentario_resolucion': '',
                      'estado': 1,
                      'tipoIncidencia': tipoSel,
                      'habitacion': registrarEnHabitacion ? habitacionSel : null,
                      'areasHotel': registrarEnHabitacion ? null : areaSel,
                    };

                    try {
                      await MantenimientoService.registrarIncidencia(payload);
                      Navigator.pop(context);
                      _cargarDatos();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al registrar incidencia: $e')),
                      );
                    }
                  },
                  child: const Text('Registrar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
