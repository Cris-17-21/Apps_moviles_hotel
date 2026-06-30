import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/check_service.dart';
import '../servicios/reserva_service.dart';

class PaginaCheckInOut extends StatefulWidget {
  const PaginaCheckInOut({super.key});

  @override
  State<PaginaCheckInOut> createState() => _PaginaCheckInOutState();
}

class _PaginaCheckInOutState extends State<PaginaCheckInOut> {
  List<Map<String, dynamic>> _checks = [];
  List<Map<String, dynamic>> _reservasPendientes = [];
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
      final checksData = await CheckService.obtenerChecks();
      final allReservas = await ReservaService.obtenerReservas();
      setState(() {
        _checks = checksData;
        _reservasPendientes = allReservas.where((r) {
          final estado = r['estado_reserva']?.toString().toLowerCase() ?? '';
          return estado == 'pendiente';
        }).toList();
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

  List<Map<String, dynamic>> get _checksFiltrados {
    return _checks.where((c) {
      final query = _filtroBusqueda.toLowerCase();
      if (query.isEmpty) return true;

      final nombreCliente = c['reserva']?['cliente']?['nombre']?.toString().toLowerCase() ?? '';
      final dniCliente = c['reserva']?['cliente']?['dniRuc']?.toString().toLowerCase() ?? '';
      final idReserva = c['reserva']?['id_reserva']?.toString() ?? '';

      return nombreCliente.contains(query) ||
          dniCliente.contains(query) ||
          idReserva.contains(query);
    }).toList();
  }

  String _formatearFecha(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '${year}-${month}-${day}T${hour}:${minute}:${second}Z';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Recepción / Check-in & Out',
      rutaActual: NombresRutas.checkInOut,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera
            Row(
              children: [
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Check-in / Out',
                  style: HotelPMSTextStyles.tituloDashboard,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: HotelPMSColors.naranjaAcento),
                  onPressed: _cargarDatos,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Gestiona entradas y salidas',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // 2. Botón de Check-in
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ModalNuevoCheckIn(
                      reservasPendientes: _reservasPendientes,
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
                icon: const Icon(Icons.login),
                label: const Text(
                  'Check-in',
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
                  hintText: 'Buscar por cliente o reserva...',
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

            // 4. Lista de Movimientos
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: HotelPMSColors.naranjaAcento,
                      ),
                    )
                  : _checksFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron movimientos',
                            style: TextStyle(color: HotelPMSColors.textoPrincipal),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _checksFiltrados.length,
                          itemBuilder: (context, index) {
                            final c = _checksFiltrados[index];
                            final idCheck = c['id_check'] as int;
                            final idReserva = c['reserva']?['id_reserva']?.toString() ?? 'N/A';
                            final cliente = c['reserva']?['cliente']?['nombre']?.toString() ?? 'Desconocido';

                            final List<dynamic> habsList = c['reserva']?['habitacionesXReserva'] as List<dynamic>? ?? [];
                            final habitacion = habsList
                                .map((hr) => hr['habitacion']?['numero']?.toString() ?? '')
                                .where((num) => num.isNotEmpty)
                                .join(', ');

                            final checkIn = c['fecha_checkin']?.toString().split('T')[0] ?? '';
                            final checkOut = c['fecha_checkout'] != null
                                ? c['fecha_checkout']?.toString().split('T')[0] ?? ''
                                : '-';

                            final nroPersona = c['reserva']?['nro_persona']?.toString() ?? '0';
                            final requiereCheckOut = c['fecha_checkout'] == null;
                            final estado = requiereCheckOut ? 'Check-in' : 'Completado';

                            return Column(
                              children: [
                                _construirTarjetaMovimiento(
                                  idCheck: idCheck,
                                  checkMap: c,
                                  reserva: '#$idReserva',
                                  cliente: cliente,
                                  habitacion: habitacion,
                                  checkIn: checkIn,
                                  checkOut: checkOut,
                                  huespedes: nroPersona,
                                  estado: estado,
                                  requiereCheckOut: requiereCheckOut,
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

  Widget _construirTarjetaMovimiento({
    required int idCheck,
    required Map<String, dynamic> checkMap,
    required String reserva,
    required String cliente,
    required String habitacion,
    required String checkIn,
    required String checkOut,
    required String huespedes,
    required String estado,
    required bool requiereCheckOut,
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
              Text(
                'Reserva: $reserva',
                style: HotelPMSTextStyles.subtituloGris,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: requiereCheckOut
                      ? Colors.transparent
                      : HotelPMSColors.textoSecundario.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: requiereCheckOut
                        ? HotelPMSColors.naranjaAcento
                        : HotelPMSColors.textoSecundario,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(cliente, style: HotelPMSTextStyles.tituloTarjeta),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _columnaDato('Habitación', habitacion),
              _columnaDato('Huéspedes', huespedes),
            ],
          ),
          const SizedBox(height: 12),
          _filaDetalle('Check-in:', checkIn),
          const SizedBox(height: 4),
          _filaDetalle('Check-out:', checkOut),
          const SizedBox(height: 16),
          if (requiereCheckOut)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _realizarCheckOut(idCheck, checkMap),
                style: OutlinedButton.styleFrom(
                  foregroundColor: HotelPMSColors.textoEliminar,
                  side: const BorderSide(color: HotelPMSColors.textoEliminar),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Check-out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _columnaDato(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: HotelPMSTextStyles.subtituloGris.copyWith(fontSize: 11),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: HotelPMSColors.textoPrincipal,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _filaDetalle(String etiqueta, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: HotelPMSTextStyles.subtituloGris),
        Text(
          valor,
          style: TextStyle(
            color: valor == '-'
                ? HotelPMSColors.textoSecundario
                : HotelPMSColors.textoPrincipal,
          ),
        ),
      ],
    );
  }

  Future<void> _realizarCheckOut(int idCheck, Map<String, dynamic> checkMap) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text('Confirmar Check-out', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold)),
        content: const Text('¿Está seguro de que desea registrar la salida del huésped?', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final payload = Map<String, dynamic>.from(checkMap);
              payload['fecha_checkout'] = _formatearFecha(DateTime.now());

              try {
                await CheckService.realizarCheckOut(idCheck, payload);
                _cargarDatos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al realizar Check-out: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.textoEliminar),
            child: const Text('Registrar Salida'),
          ),
        ],
      ),
    );
  }
}

class ModalNuevoCheckIn extends StatefulWidget {
  final List<Map<String, dynamic>> reservasPendientes;
  final VoidCallback onSave;

  const ModalNuevoCheckIn({
    super.key,
    required this.reservasPendientes,
    required this.onSave,
  });

  @override
  State<ModalNuevoCheckIn> createState() => _ModalNuevoCheckInState();
}

class _ModalNuevoCheckInState extends State<ModalNuevoCheckIn> {
  Map<String, dynamic>? reservaSeleccionada;

  @override
  void initState() {
    super.initState();
    if (widget.reservasPendientes.isNotEmpty) {
      reservaSeleccionada = widget.reservasPendientes.first;
    }
  }

  String _formatearFecha(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '${year}-${month}-${day}T${hour}:${minute}:${second}Z';
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> habsList = reservaSeleccionada?['habitacionesXReserva'] as List<dynamic>? ?? [];
    final habitaciones = habsList
        .map((hr) => hr['habitacion']?['numero']?.toString() ?? '')
        .where((num) => num.isNotEmpty)
        .join(', ');

    final clienteDni = reservaSeleccionada?['cliente']?['dniRuc']?.toString() ?? '';
    final clienteNombre = reservaSeleccionada?['cliente']?['nombre']?.toString() ?? '';

    return Dialog(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nuevo Check-in',
              style: TextStyle(
                color: HotelPMSColors.textoPrincipal,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (widget.reservasPendientes.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No hay reservas pendientes de Check-in',
                    style: TextStyle(color: HotelPMSColors.textoSecundario),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HotelPMSColors.fondoInput,
                    foregroundColor: HotelPMSColors.textoPrincipal,
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ] else ...[
              // Selector de Reserva
              const Text(
                'Reserva',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
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
                    value: reservaSeleccionada,
                    isExpanded: true,
                    dropdownColor: HotelPMSColors.fondoInput,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: HotelPMSColors.textoPrincipal,
                    ),
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontSize: 14,
                    ),
                    onChanged: (Map<String, dynamic>? nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() => reservaSeleccionada = nuevoValor);
                      }
                    },
                    items: widget.reservasPendientes.map((Map<String, dynamic> r) {
                      final idRes = r['id_reserva']?.toString() ?? 'N/A';
                      final nom = r['cliente']?['nombre']?.toString() ?? '';
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: r,
                        child: Text('Reserva #$idRes - $nom'),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detalles de la reserva seleccionada
              const Text(
                'Habitaciones a Ocupar',
                style: TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                habitaciones.isNotEmpty ? habitaciones : 'Ninguna habitación asignada',
                style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Huéspedes
              Row(
                children: [
                  const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: HotelPMSColors.textoSecundario,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Huésped Titular',
                    style: TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoOscuro,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$clienteNombre (DNI/RUC: $clienteDni)',
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botones Finales
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HotelPMSColors.fondoInput,
                        foregroundColor: HotelPMSColors.textoPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (reservaSeleccionada == null) return;

                        final payload = <String, dynamic>{
                          'fecha_checkin': _formatearFecha(DateTime.now()),
                          'fecha_checkout': null,
                          'estado': 1,
                          'sucursal': reservaSeleccionada!['sucursal'],
                          'reserva': reservaSeleccionada,
                        };

                        try {
                          await CheckService.realizarCheckIn(payload);
                          widget.onSave();
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al realizar Check-in: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HotelPMSColors.naranjaAcento,
                        foregroundColor: HotelPMSColors.textoPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirmar Check-in',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
