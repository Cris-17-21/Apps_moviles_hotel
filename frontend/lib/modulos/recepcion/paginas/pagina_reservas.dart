import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/reserva_service.dart';
import '../servicios/habitacion_service.dart';

class PaginaReservas extends StatefulWidget {
  const PaginaReservas({super.key});

  @override
  State<PaginaReservas> createState() => _PaginaReservasState();
}

class _PaginaReservasState extends State<PaginaReservas> {
  List<Map<String, dynamic>> _reservas = [];
  List<Map<String, dynamic>> _sucursales = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _habitaciones = [];
  bool _cargando = true;
  String _filtroBusqueda = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });
    try {
      final resData = await ReservaService.obtenerReservas();
      final clientsData = await ReservaService.obtenerClientes();
      final sucursalesData = await HabitacionService.obtenerSucursales();
      final habsData = await HabitacionService.obtenerHabitaciones();
      setState(() {
        _reservas = resData;
        _clientes = clientsData;
        _sucursales = sucursalesData;
        _habitaciones = habsData;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get _reservasFiltradas {
    return _reservas.where((r) {
      final query = _filtroBusqueda.toLowerCase();
      if (query.isEmpty) return true;

      final nombreCliente = r['cliente']?['nombre']?.toString().toLowerCase() ?? '';
      final dniCliente = r['cliente']?['dniRuc']?.toString().toLowerCase() ?? '';
      final habsList = r['habitacionesXReserva'] as List<dynamic>? ?? [];
      final numerosHab = habsList.map((hr) => hr['habitacion']?['numero']?.toString() ?? '').join(' ');

      return nombreCliente.contains(query) ||
          dniCliente.contains(query) ||
          numerosHab.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Recepción / Reservas',
      rutaActual: NombresRutas.reservas,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Reservas', style: HotelPMSTextStyles.tituloDashboard),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: HotelPMSColors.naranjaAcento),
                  onPressed: _cargarDatos,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra reservas de habitaciones',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // 2. Botón "+ Nueva Reserva"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ModalNuevaReserva(
                      clientes: _clientes,
                      sucursales: _sucursales,
                      habitaciones: _habitaciones,
                      onSave: _cargarDatos,
                    ),
                  );
                },
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
                  'Nueva Reserva',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Buscador
            Container(
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _filtroBusqueda = val;
                  });
                },
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: const InputDecoration(
                  hintText: 'Buscar por cliente o habitación...',
                  hintStyle: HotelPMSTextStyles.subtituloGris,
                  prefixIcon: Icon(
                    Icons.search,
                    color: HotelPMSColors.textoSecundario,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Lista de Reservas
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: HotelPMSColors.naranjaAcento,
                      ),
                    )
                  : _reservasFiltradas.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron reservas',
                            style: TextStyle(color: HotelPMSColors.textoPrincipal),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _reservasFiltradas.length,
                          itemBuilder: (context, index) {
                            final r = _reservasFiltradas[index];
                            final idReserva = r['id_reserva'] as int;
                            final nombre = r['cliente']?['nombre']?.toString() ?? 'Sin Nombre';
                            final estado = r['estado_reserva']?.toString() ?? 'Pendiente';
                            final checkIn = r['fecha_inicio']?.toString().split('T')[0] ?? '';
                            final checkOut = r['fecha_fin']?.toString().split('T')[0] ?? '';

                            final List<dynamic> habsXReserva = r['habitacionesXReserva'] as List<dynamic>? ?? [];
                            final habs = habsXReserva
                                .map((hr) => hr['habitacion']?['numero']?.toString() ?? '')
                                .where((num) => num.isNotEmpty)
                                .join(', ');

                            final nroPersona = r['nro_persona']?.toString() ?? '0';

                            double totalAcumulado = 0.0;
                            for (var hr in habsXReserva) {
                              totalAcumulado += (hr['precio_reserva'] as num?)?.toDouble() ?? 0.0;
                            }
                            final total = 'S/ ${totalAcumulado.toStringAsFixed(2)}';

                            Color colorEstado = HotelPMSColors.textoPrincipal;
                            if (estado.toLowerCase() == 'check-in') {
                              colorEstado = HotelPMSColors.naranjaAcento;
                            } else if (estado.toLowerCase() == 'pagada') {
                              colorEstado = HotelPMSColors.azulAcento;
                            } else if (estado.toLowerCase() == 'cancelada') {
                              colorEstado = HotelPMSColors.textoEliminar;
                            } else {
                              colorEstado = HotelPMSColors.textoSecundario;
                            }

                            return Column(
                              children: [
                                _construirTarjetaReserva(
                                  idReserva: idReserva,
                                  idStr: '#$idReserva',
                                  nombre: nombre,
                                  estado: estado,
                                  checkIn: checkIn,
                                  checkOut: checkOut,
                                  habs: habs,
                                  huespedes: nroPersona,
                                  total: total,
                                  colorEstado: colorEstado,
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaReserva({
    required int idReserva,
    required String idStr,
    required String nombre,
    required String estado,
    required String checkIn,
    required String checkOut,
    required String habs,
    required String huespedes,
    required String total,
    required Color colorEstado,
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
              Text(idStr, style: HotelPMSTextStyles.subtituloGris),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorEstado == HotelPMSColors.textoPrincipal
                      ? Colors.transparent
                      : colorEstado.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: colorEstado,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(nombre, style: HotelPMSTextStyles.tituloTarjeta),
          const SizedBox(height: 16),
          _filaDetalle('Check-in:', checkIn),
          const SizedBox(height: 8),
          _filaDetalle('Check-out:', checkOut),
          const SizedBox(height: 8),
          _filaDetalle('Habitaciones:', habs),
          const SizedBox(height: 8),
          _filaDetalle('Huéspedes:', huespedes),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: HotelPMSTextStyles.subtituloGris),
              Text(
                total,
                style: HotelPMSTextStyles.precioDestacado.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (estado.toLowerCase() == 'pendiente') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmarCancelarReserva(idReserva),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HotelPMSColors.naranjaAcento,
                      foregroundColor: HotelPMSColors.textoPrincipal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmarEliminarReserva(idReserva),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HotelPMSColors.textoEliminar,
                    foregroundColor: HotelPMSColors.textoPrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filaDetalle(String etiqueta, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: HotelPMSTextStyles.subtituloGris),
        Text(
          valor,
          style: const TextStyle(
            color: HotelPMSColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _confirmarCancelarReserva(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text('Cancelar Reserva', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold)),
        content: const Text('¿Está seguro de que desea cancelar esta reserva?', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ReservaService.cancelarReserva(id);
                _cargarDatos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cancelar reserva: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarReserva(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text('Eliminar Reserva', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold)),
        content: const Text('¿Está seguro de que desea eliminar esta reserva de forma permanente?', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ReservaService.eliminarReserva(id);
                _cargarDatos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar reserva: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.textoEliminar),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class ModalNuevaReserva extends StatefulWidget {
  final List<Map<String, dynamic>> clientes;
  final List<Map<String, dynamic>> sucursales;
  final List<Map<String, dynamic>> habitaciones;
  final VoidCallback onSave;

  const ModalNuevaReserva({
    super.key,
    required this.clientes,
    required this.sucursales,
    required this.habitaciones,
    required this.onSave,
  });

  @override
  State<ModalNuevaReserva> createState() => _ModalNuevaReservaState();
}

class _ModalNuevaReservaState extends State<ModalNuevaReserva> {
  int pasoActual = 0; // 0: Cliente/Sucursal, 1: Fechas, 2: Habitaciones

  Map<String, dynamic>? sucursalSel;
  Map<String, dynamic>? clienteSel;
  int nroPersonas = 1;
  final txtComentarios = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFin;

  List<Map<String, dynamic>> habitacionesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    if (widget.sucursales.isNotEmpty) {
      sucursalSel = widget.sucursales.first;
    }
    if (widget.clientes.isNotEmpty) {
      clienteSel = widget.clientes.first;
    }
  }

  @override
  void dispose() {
    txtComentarios.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${year}-${month}-${day}T12:00:00Z';
  }

  Future<void> _seleccionarFechaInicio(BuildContext context, StateSetter setModalState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setModalState(() {
        fechaInicio = picked;
        // Reset check-out date if check-in is after it
        if (fechaFin != null && fechaFin!.isBefore(picked)) {
          fechaFin = null;
        }
      });
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context, StateSetter setModalState) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: fechaInicio ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setModalState(() {
        fechaFin = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nueva Reserva',
                  style: TextStyle(
                    color: HotelPMSColors.textoPrincipal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Barra de progreso de pasos
                Row(
                  children: [
                    _indicadorPaso('Cliente', 0),
                    const SizedBox(width: 8),
                    _indicadorPaso('Fechas', 1),
                    const SizedBox(width: 8),
                    _indicadorPaso('Habitaciones', 2),
                  ],
                ),
                const SizedBox(height: 24),

                // Contenido dinámico según el paso
                Expanded(
                  child: SingleChildScrollView(
                    child: _construirPasoActual(setModalState),
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de navegación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (pasoActual > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => pasoActual--),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HotelPMSColors.fondoInput,
                            foregroundColor: HotelPMSColors.textoPrincipal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Anterior'),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 12),

                    if (pasoActual < 2)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (pasoActual == 0) {
                              if (clienteSel == null || sucursalSel == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Por favor, seleccione un cliente y una sucursal')),
                                );
                                return;
                              }
                            } else if (pasoActual == 1) {
                              if (fechaInicio == null || fechaFin == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Por favor, seleccione fechas válidas de entrada y salida')),
                                );
                                return;
                              }
                            }
                            setState(() => pasoActual++);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HotelPMSColors.naranjaAcento,
                            foregroundColor: HotelPMSColors.textoPrincipal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Siguiente'),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (habitacionesSeleccionadas.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Debe seleccionar al menos una habitación')),
                              );
                              return;
                            }

                            final mappedHabs = habitacionesSeleccionadas.map((room) {
                              return {
                                'precio_reserva': (room['tipo_habitacion']?['precio'] as num?)?.toDouble() ?? 0.0,
                                'habitacion': {
                                  'id_habitacion': room['id_habitacion'],
                                },
                              };
                            }).toList();

                            final payload = <String, dynamic>{
                              'fecha_inicio': _formatearFecha(fechaInicio!),
                              'fecha_fin': _formatearFecha(fechaFin!),
                              'estado_reserva': 'Pendiente',
                              'comentarios': txtComentarios.text,
                              'nro_persona': nroPersonas,
                              'estado': 1,
                              'tipo': 'habitacion',
                              'sucursal': sucursalSel,
                              'cliente': clienteSel,
                              'habitacionesXReserva': mappedHabs,
                            };

                            try {
                              await ReservaService.crearReserva(payload);
                              widget.onSave();
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al crear reserva: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HotelPMSColors.naranjaAcento,
                            foregroundColor: HotelPMSColors.textoPrincipal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Confirmar'),
                        ),
                      ),

                    if (pasoActual == 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: HotelPMSColors.textoEliminar),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _indicadorPaso(String titulo, int indice) {
    bool activo = pasoActual >= indice;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: activo
                  ? HotelPMSColors.naranjaAcento
                  : HotelPMSColors.fondoInput,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              color: activo
                  ? HotelPMSColors.textoPrincipal
                  : HotelPMSColors.textoSecundario,
              fontSize: 10,
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPasoActual(StateSetter setModalState) {
    if (pasoActual == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sucursal dropdown
          const Text(
            'Sucursal',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: HotelPMSColors.fondoInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: sucursalSel,
                isExpanded: true,
                dropdownColor: HotelPMSColors.fondoInput,
                icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoPrincipal),
                style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                onChanged: (val) {
                  setModalState(() {
                    sucursalSel = val;
                    // Reset rooms selection if sucursal changes
                    habitacionesSeleccionadas.clear();
                  });
                },
                items: widget.sucursales.map((s) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: s,
                    child: Text(s['ciudad']?.toString() ?? ''),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cliente dropdown
          const Text(
            'Cliente',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: HotelPMSColors.fondoInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: clienteSel,
                isExpanded: true,
                dropdownColor: HotelPMSColors.fondoInput,
                icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoPrincipal),
                style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                onChanged: (val) {
                  setModalState(() {
                    clienteSel = val;
                  });
                },
                items: widget.clientes.map((c) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: c,
                    child: Text('${c['dniRuc']} - ${c['nombre']}'),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nro personas input
          const Text(
            'Número de Huéspedes',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: HotelPMSColors.fondoInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: HotelPMSColors.textoPrincipal),
                  onPressed: nroPersonas > 1
                      ? () {
                          setModalState(() {
                            nroPersonas--;
                          });
                        }
                      : null,
                ),
                Text(
                  '$nroPersonas',
                  style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: HotelPMSColors.naranjaAcento),
                  onPressed: () {
                    setModalState(() {
                      nroPersonas++;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Comentarios field
          const Text(
            'Comentarios',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: HotelPMSColors.fondoInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: txtComentarios,
              maxLines: 3,
              style: const TextStyle(color: HotelPMSColors.textoPrincipal),
              decoration: const InputDecoration(
                hintText: 'Observaciones adicionales...',
                hintStyle: HotelPMSTextStyles.subtituloGris,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      );
    } else if (pasoActual == 1) {
      final inicioStr = fechaInicio != null
          ? '${fechaInicio!.year}-${fechaInicio!.month.toString().padLeft(2, '0')}-${fechaInicio!.day.toString().padLeft(2, '0')}'
          : 'dd/mm/aaaa';
      final finStr = fechaFin != null
          ? '${fechaFin!.year}-${fechaFin!.month.toString().padLeft(2, '0')}-${fechaFin!.day.toString().padLeft(2, '0')}'
          : 'dd/mm/aaaa';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha de Check-in',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _seleccionarFechaInicio(context, setModalState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    inicioStr,
                    style: TextStyle(
                      color: fechaInicio != null ? HotelPMSColors.textoPrincipal : HotelPMSColors.textoSecundario,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: HotelPMSColors.textoSecundario, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Fecha de Check-out',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _seleccionarFechaFin(context, setModalState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    finStr,
                    style: TextStyle(
                      color: fechaFin != null ? HotelPMSColors.textoPrincipal : HotelPMSColors.textoSecundario,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: HotelPMSColors.textoSecundario, size: 18),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      final branchRooms = widget.habitaciones.where((h) {
        return h['sucursal']?['id'] == sucursalSel?['id'];
      }).toList();

      double totalEstimado = 0.0;
      for (var hr in habitacionesSeleccionadas) {
        totalEstimado += (hr['tipo_habitacion']?['precio'] as num?)?.toDouble() ?? 0.0;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccione Habitaciones',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (branchRooms.isEmpty)
            const Text(
              'No hay habitaciones registradas en esta sucursal',
              style: TextStyle(color: HotelPMSColors.textoSecundario),
            )
          else
            ...branchRooms.map((room) {
              final isSelected = habitacionesSeleccionadas.any((h) => h['id_habitacion'] == room['id_habitacion']);
              final numHab = room['numero']?.toString() ?? '';
              final tipoHab = room['tipo_habitacion']?['nombre']?.toString() ?? '';
              final precioHab = room['tipo_habitacion']?['precio']?.toString() ?? '0';
              final estadoHab = room['estado_habitacion']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  activeColor: HotelPMSColors.naranjaAcento,
                  checkColor: HotelPMSColors.fondoTarjeta,
                  title: Text(
                    'Habitación $numHab - $tipoHab',
                    style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Precio: S/ $precioHab • $estadoHab',
                    style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 12),
                  ),
                  value: isSelected,
                  onChanged: (val) {
                    setModalState(() {
                      if (val == true) {
                        habitacionesSeleccionadas.add(room);
                      } else {
                        habitacionesSeleccionadas.removeWhere((h) => h['id_habitacion'] == room['id_habitacion']);
                      }
                    });
                  },
                ),
              );
            }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: HotelPMSColors.naranjaAcento),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimado:',
                  style: TextStyle(
                    color: HotelPMSColors.textoPrincipal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'S/ ${totalEstimado.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: HotelPMSColors.naranjaAcento,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
