import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/habitacion_service.dart';

class PaginaHabitaciones extends StatefulWidget {
  const PaginaHabitaciones({super.key});

  @override
  State<PaginaHabitaciones> createState() => _PaginaHabitacionesState();
}

class _PaginaHabitacionesState extends State<PaginaHabitaciones> {
  List<Map<String, dynamic>> _habitaciones = [];
  List<Map<String, dynamic>> _pisos = [];
  List<Map<String, dynamic>> _tiposHabitacion = [];
  List<Map<String, dynamic>> _sucursales = [];
  bool _cargando = true;

  String pisoSeleccionado = 'Todos los pisos';
  String estadoSeleccionado = 'Todos los estados';
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
      final data = await HabitacionService.obtenerHabitaciones();
      final pisosData = await HabitacionService.obtenerPisos();
      final tiposData = await HabitacionService.obtenerTiposHabitacion();
      final sucursalesData = await HabitacionService.obtenerSucursales();
      setState(() {
        _habitaciones = data;
        _pisos = pisosData;
        _tiposHabitacion = tiposData;
        _sucursales = sucursalesData;
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

  List<Map<String, dynamic>> get _habitacionesFiltradas {
    return _habitaciones.where((h) {
      // Filtrar por búsqueda
      final numero = h['numero']?.toString() ?? '';
      final tipo = h['tipo_habitacion']?['nombre']?.toString().toLowerCase() ?? '';
      if (_filtroBusqueda.isNotEmpty &&
          !numero.contains(_filtroBusqueda) &&
          !tipo.contains(_filtroBusqueda.toLowerCase())) {
        return false;
      }
      // Filtrar por piso
      if (pisoSeleccionado != 'Todos los pisos') {
        final pisoRoom = h['piso']?['numero']?.toString() ?? '';
        if (!pisoSeleccionado.contains(pisoRoom)) {
          return false;
        }
      }
      // Filtrar por estado
      if (estadoSeleccionado != 'Todos los estados') {
        final estadoRoom = h['estado_habitacion']?.toString() ?? '';
        if (estadoRoom.toLowerCase() != estadoSeleccionado.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<String> get _opcionesPisos {
    final list = ['Todos los pisos'];
    for (var p in _pisos) {
      final numPiso = p['numero']?.toString();
      if (numPiso != null && !list.contains('Piso $numPiso')) {
        list.add('Piso $numPiso');
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Recepción / Habitaciones',
      rutaActual: NombresRutas.habitaciones,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera
            Row(
              children: [
                const Icon(
                  Icons.domain,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Habitaciones', style: HotelPMSTextStyles.tituloDashboard),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: HotelPMSColors.naranjaAcento),
                  onPressed: _cargarDatos,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra el estado y disponibilidad',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // 2. Botón "+ Nueva"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _mostrarModalHabitacion(),
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
                  'Nueva',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Filtros y Búsqueda
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
                  hintText: 'Buscar habitación...',
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
            const SizedBox(height: 12),

            // Dropdowns de Filtros
            _construirDropdown(
              valorActual: pisoSeleccionado,
              opciones: _opcionesPisos,
              alCambiar: (nuevoValor) =>
                  setState(() => pisoSeleccionado = nuevoValor!),
            ),
            const SizedBox(height: 12),
            _construirDropdown(
              valorActual: estadoSeleccionado,
              opciones: [
                'Todos los estados',
                'Disponible',
                'Reservada',
                'Limpieza',
                'Ocupada',
              ],
              alCambiar: (nuevoValor) =>
                  setState(() => estadoSeleccionado = nuevoValor!),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.filter_alt_outlined,
                  color: HotelPMSColors.textoSecundario,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mostrando ${_habitacionesFiltradas.length} de ${_habitaciones.length}',
                  style: HotelPMSTextStyles.subtituloGris,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Cuadrícula de Habitaciones o Indicador de Carga
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: HotelPMSColors.naranjaAcento,
                      ),
                    )
                  : _habitacionesFiltradas.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron habitaciones',
                            style: TextStyle(color: HotelPMSColors.textoPrincipal),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: _habitacionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final h = _habitacionesFiltradas[index];
                            final numero = h['numero']?.toString() ?? '';
                            final tipo = h['tipo_habitacion']?['nombre']?.toString() ?? '';
                            final numPiso = h['piso']?['numero']?.toString() ?? '';
                            final estado = h['estado_habitacion']?.toString() ?? 'Disponible';
                            final precioVal = h['tipo_habitacion']?['precio']?.toString() ?? '0';
                            final esOcupada = estado == 'Ocupada';
                            final id = h['id_habitacion'] as int;

                            return _construirTarjetaHabitacion(
                              id: id,
                              numero: numero,
                              tipo: tipo,
                              piso: 'Piso $numPiso',
                              estado: estado,
                              precio: 'S/ $precioVal/noche',
                              esOcupada: esOcupada,
                              roomMap: h,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirDropdown({
    required String valorActual,
    required List<String> opciones,
    required void Function(String?) alCambiar,
  }) {
    // Asegurar que valorActual esté en opciones
    final String checkedValue = opciones.contains(valorActual) ? valorActual : opciones.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: checkedValue,
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
          onChanged: alCambiar,
          items: opciones.map((String valor) {
            return DropdownMenuItem<String>(value: valor, child: Text(valor));
          }).toList(),
        ),
      ),
    );
  }

  Widget _construirTarjetaHabitacion({
    required int id,
    required String numero,
    required String tipo,
    required String piso,
    required String estado,
    required String precio,
    required bool esOcupada,
    required Map<String, dynamic> roomMap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esOcupada ? HotelPMSColors.azulAcento : Colors.white10,
          width: esOcupada ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: HotelPMSColors.textoSecundario,
                  size: 18,
                ),
                onPressed: () => _mostrarModalHabitacion(habitacion: roomMap),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  color: HotelPMSColors.textoEliminar,
                  size: 18,
                ),
                onPressed: () => _confirmarEliminarHabitacion(id, numero),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: esOcupada
                  ? HotelPMSColors.azulAcento.withAlpha((0.2 * 255).round())
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.domain,
              color: esOcupada
                  ? HotelPMSColors.azulAcento
                  : HotelPMSColors.textoPrincipal,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(numero, style: HotelPMSTextStyles.valorGrande),
          Text(
            tipo,
            style: HotelPMSTextStyles.subtituloGris.copyWith(fontSize: 12),
          ),
          Text(
            piso,
            style: HotelPMSTextStyles.subtituloGris.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: esOcupada
                  ? HotelPMSColors.azulAcento.withAlpha((0.2 * 255).round())
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              estado,
              style: TextStyle(
                color: esOcupada
                    ? HotelPMSColors.azulAcento
                    : HotelPMSColors.textoPrincipal,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(precio, style: HotelPMSTextStyles.precioDestacado),
        ],
      ),
    );
  }

  void _confirmarEliminarHabitacion(int id, String numero) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text(
          'Confirmar Eliminación',
          style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Está seguro de que desea eliminar la habitación $numero?',
          style: const TextStyle(color: HotelPMSColors.textoPrincipal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoPrincipal)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarHabitacion(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.textoEliminar),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarHabitacion(int id) async {
    try {
      await HabitacionService.eliminarHabitacion(id);
      _cargarDatos();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: HotelPMSColors.fondoTarjeta,
          title: const Text(
            'Error de Eliminación',
            style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'No se puede eliminar la habitación. Existen registros históricos de reservas o limpiezas asociados a esta habitación.',
            style: TextStyle(color: HotelPMSColors.textoPrincipal),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(color: HotelPMSColors.naranjaAcento)),
            ),
          ],
        ),
      );
    }
  }

  void _mostrarModalHabitacion({Map<String, dynamic>? habitacion}) {
    final isEdit = habitacion != null;
    final txtNumero = TextEditingController(text: habitacion?['numero']?.toString() ?? '');

    Map<String, dynamic>? sucursalSel;
    if (isEdit && habitacion['sucursal'] != null) {
      sucursalSel = _sucursales.firstWhere(
        (s) => s['id'] == habitacion['sucursal']['id'],
        orElse: () => _sucursales.first,
      );
    } else {
      sucursalSel = _sucursales.isNotEmpty ? _sucursales.first : null;
    }

    Map<String, dynamic>? pisoSel;
    if (isEdit && habitacion['piso'] != null) {
      pisoSel = _pisos.firstWhere(
        (p) => p['id_piso'] == habitacion['piso']['id_piso'],
        orElse: () => _pisos.first,
      );
    } else {
      pisoSel = _pisos.isNotEmpty ? _pisos.first : null;
    }

    Map<String, dynamic>? tipoSel;
    if (isEdit && habitacion['tipo_habitacion'] != null) {
      tipoSel = _tiposHabitacion.firstWhere(
        (t) => t['id_tipo_habitacion'] == habitacion['tipo_habitacion']['id_tipo_habitacion'],
        orElse: () => _tiposHabitacion.first,
      );
    } else {
      tipoSel = _tiposHabitacion.isNotEmpty ? _tiposHabitacion.first : null;
    }

    String estadoHabitacion = habitacion?['estado_habitacion'] ?? 'Disponible';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: HotelPMSColors.fondoTarjeta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                isEdit ? 'Editar Habitación' : 'Nueva Habitación',
                style: const TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número
                    const Text(
                      'Número',
                      style: TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: HotelPMSColors.fondoInput,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: txtNumero,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                        decoration: const InputDecoration(
                          hintText: 'Ej: 101',
                          hintStyle: HotelPMSTextStyles.subtituloGris,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sucursal Dropdown
                    const Text(
                      'Sucursal',
                      style: TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                            });
                          },
                          items: _sucursales.map((s) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: s,
                              child: Text(s['ciudad']?.toString() ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Piso Dropdown
                    const Text(
                      'Piso',
                      style: TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: HotelPMSColors.fondoInput,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: pisoSel,
                          isExpanded: true,
                          dropdownColor: HotelPMSColors.fondoInput,
                          icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoPrincipal),
                          style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                          onChanged: (val) {
                            setModalState(() {
                              pisoSel = val;
                            });
                          },
                          items: _pisos.map((p) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: p,
                              child: Text('Piso ${p['numero']}'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tipo Dropdown
                    const Text(
                      'Tipo de Habitación',
                      style: TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: HotelPMSColors.fondoInput,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Map<String, dynamic>>(
                          value: tipoSel,
                          isExpanded: true,
                          dropdownColor: HotelPMSColors.fondoInput,
                          icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoPrincipal),
                          style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                          onChanged: (val) {
                            setModalState(() {
                              tipoSel = val;
                            });
                          },
                          items: _tiposHabitacion.map((t) {
                            final precio = t['precio']?.toString() ?? '0';
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: t,
                              child: Text('${t['nombre']} (S/ $precio)'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Estado Dropdown (if editing)
                    if (isEdit) ...[
                      const Text(
                        'Estado de Habitación',
                        style: TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: HotelPMSColors.fondoInput,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: estadoHabitacion,
                            isExpanded: true,
                            dropdownColor: HotelPMSColors.fondoInput,
                            icon: const Icon(Icons.keyboard_arrow_down, color: HotelPMSColors.textoPrincipal),
                            style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  estadoHabitacion = val;
                                });
                              }
                            },
                            items: ['Disponible', 'Reservada', 'Limpieza', 'Ocupada'].map((e) {
                              return DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: HotelPMSColors.textoPrincipal),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final numVal = int.tryParse(txtNumero.text);
                    if (numVal == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingrese un número válido')),
                      );
                      return;
                    }
                    if (sucursalSel == null || pisoSel == null || tipoSel == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, complete todos los campos de selección')),
                      );
                      return;
                    }

                    final body = <String, dynamic>{
                      'numero': numVal,
                      'estado_habitacion': estadoHabitacion,
                      'estado': 1,
                      'sucursal': sucursalSel,
                      'piso': pisoSel,
                      'tipo_habitacion': tipoSel,
                    };

                    if (isEdit) {
                      body['id_habitacion'] = habitacion['id_habitacion'];
                    }

                    try {
                      if (isEdit) {
                        await HabitacionService.actualizarHabitacion(habitacion['id_habitacion'], body);
                      } else {
                        await HabitacionService.guardarHabitacion(body);
                      }
                      Navigator.of(context).pop();
                      _cargarDatos();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al guardar: $e')),
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
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
