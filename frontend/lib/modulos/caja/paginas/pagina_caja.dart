import 'package:flutter/material.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../rutas/nombres_rutas.dart';
import '../servicios/caja_service.dart';

class PaginaCaja extends StatefulWidget {
  const PaginaCaja({super.key});

  @override
  State<PaginaCaja> createState() => _PaginaCajaState();
}

class _PaginaCajaState extends State<PaginaCaja> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _estadoCaja;
  List<Map<String, dynamic>> _transacciones = [];

  // Estado del arqueo y cierre
  double _totalContadoArqueo = 0.0;
  bool _arqueoRealizado = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosCaja();
  }

  Future<void> _cargarDatosCaja() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final estado = await CajaService.obtenerEstadoCaja();
      setState(() {
        _estadoCaja = estado;
      });

      if (_isCajaAbierta) {
        final txs = await CajaService.obtenerTransacciones();
        setState(() {
          // Ordenamos transacciones por ID descendente para ver las más recientes primero
          txs.sort((a, b) {
            final idA = a['id'] ?? 0;
            final idB = b['id'] ?? 0;
            return idB.compareTo(idA);
          });
          _transacciones = txs;
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos de caja. Verifique la conexión con el servidor.';
        _isLoading = false;
      });
    }
  }

  bool get _isCajaAbierta =>
      _estadoCaja != null && _estadoCaja!['estadoCaja'] == 'abierta';

  double get _montoInicial =>
      double.tryParse(_estadoCaja?['montoApertura']?.toString() ?? '0') ?? 0.0;

  double get _totalIngresos {
    double sum = 0.0;
    for (var t in _transacciones) {
      final tipoObj = t['tipo'];
      final tipoStr = tipoObj != null ? tipoObj['nombre']?.toString().toUpperCase() : '';
      final monto = double.tryParse(t['montoTransaccion']?.toString() ?? '0') ?? 0.0;
      if (tipoStr == 'INGRESO' || t['tipo']?['id'] == 1) {
        sum += monto;
      }
    }
    return sum;
  }

  double get _totalEgresos {
    double sum = 0.0;
    for (var t in _transacciones) {
      final tipoObj = t['tipo'];
      final tipoStr = tipoObj != null ? tipoObj['nombre']?.toString().toUpperCase() : '';
      final monto = double.tryParse(t['montoTransaccion']?.toString() ?? '0') ?? 0.0;
      if (tipoStr == 'EGRESO' || t['tipo']?['id'] == 2) {
        sum += monto;
      }
    }
    return sum;
  }

  double get _saldoSistema => _montoInicial + _totalIngresos - _totalEgresos;

  Future<void> _abrirCaja(double montoApertura) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await CajaService.aperturarCaja(montoApertura);
      _arqueoRealizado = false;
      _totalContadoArqueo = 0.0;
      await _cargarDatosCaja();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caja aperturada exitosamente.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aperturar caja: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cerrarCaja(double montoCierre) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await CajaService.cerrarCaja(montoCierre);
      setState(() {
        _arqueoRealizado = false;
        _totalContadoArqueo = 0.0;
      });
      await _cargarDatosCaja();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caja cerrada con éxito. Turno finalizado.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar caja: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _registrarTransaccion(double monto, String motivo, int tipoId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final success = await CajaService.guardarTransaccion(
        montoTransaccion: monto,
        motivo: motivo,
        tipoId: tipoId,
      );
      if (success) {
        await _cargarDatosCaja();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transacción registrada exitosamente.'), backgroundColor: Colors.green),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al registrar transacción en el servidor.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HotelPMSColors.fondoOscuro,
      body: LayoutPrincipal(
        rutaActual: NombresRutas.caja,
        tituloBarra: 'HotelPMS',
        cuerpo: _buildCuerpo(),
      ),
      floatingActionButton: _isCajaAbierta && !_isLoading && _errorMessage == null
          ? FloatingActionButton(
              backgroundColor: HotelPMSColors.naranjaAcento,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 28),
              onPressed: () => _mostrarRegistrarMovimientoModal(context),
            )
          : null,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, color: HotelPMSColors.textoEliminar, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: HotelPMSColors.textoSecundario),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarDatosCaja,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HotelPMSColors.naranjaAcento,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCajaAbierta) {
      return _buildCajaCerradaVista();
    }

    return _buildCajaAbiertaVista();
  }

  Widget _buildCajaCerradaVista() {
    final TextEditingController montoAperturaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            color: HotelPMSColors.fondoTarjeta,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: HotelPMSColors.naranjaAcento,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Caja Cerrada',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: HotelPMSColors.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para registrar transacciones de ingresos o egresos, debe aperturar la caja del día.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: HotelPMSColors.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: montoAperturaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                      decoration: InputDecoration(
                        labelText: 'Monto de Apertura (S/)',
                        labelStyle: const TextStyle(color: HotelPMSColors.textoSecundario),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: HotelPMSColors.textoSecundario,
                        ),
                        filled: true,
                        fillColor: HotelPMSColors.fondoOscuro,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: HotelPMSColors.naranjaAcento, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el monto inicial';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val < 0) {
                          return 'Ingrese un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HotelPMSColors.naranjaAcento,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final val = double.parse(montoAperturaController.text);
                          _abrirCaja(val);
                        }
                      },
                      child: const Text(
                        'Aperturar Caja',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCajaAbiertaVista() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del Módulo
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: HotelPMSColors.naranjaAcento, size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Caja', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal)),
                  Text('Administra movimientos e ingresos', style: TextStyle(fontSize: 12, color: HotelPMSColors.textoSecundario)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botones de Procesos de Auditoría (Arqueo y Cierre)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Arqueo', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _mostrarArqueoModal(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _mostrarCerrarCajaModal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grid / Tarjetas de Resumen de Saldos
          _buildTarjetaMonto('Monto Inicial', 'S/ ${_montoInicial.toStringAsFixed(2)}', Colors.blue),
          const SizedBox(height: 12),
          _buildTarjetaMonto('Total Ingresos', 'S/ ${_totalIngresos.toStringAsFixed(2)}', Colors.green),
          const SizedBox(height: 12),
          _buildTarjetaMonto('Total Egresos', 'S/ ${_totalEgresos.toStringAsFixed(2)}', Colors.red),
          const SizedBox(height: 12),
          
          // Tarjeta Destacada: Saldo en Sistema
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HotelPMSColors.fondoTarjeta,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HotelPMSColors.naranjaAcento, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo Actual', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('S/ ${_saldoSistema.toStringAsFixed(2)}', style: const TextStyle(color: HotelPMSColors.naranjaAcento, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.wallet, color: HotelPMSColors.naranjaAcento, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección de Historial con Cabeceras de Tabla
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movimientos del Día (${_transacciones.length})', 
                style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cabeceras explícitas de la tabla
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text('TIPO', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
                Expanded(
                  flex: 4,
                  child: Text('DESCRIPCIÓN', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('MONTO', textAlign: TextAlign.end, style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),

          // Tabla Renderizada de Movimientos
          Container(
            decoration: BoxDecoration(
              color: HotelPMSColors.fondoTarjeta, 
              borderRadius: BorderRadius.circular(8),
            ),
            child: _transacciones.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No hay transacciones registradas hoy.',
                        style: TextStyle(color: HotelPMSColors.textoSecundario),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transacciones.length,
                    separatorBuilder: (context, index) => const Divider(color: HotelPMSColors.fondoOscuro, height: 1),
                    itemBuilder: (context, index) {
                      final t = _transacciones[index];
                      final tipoObj = t['tipo'];
                      final tipoStr = tipoObj != null ? (tipoObj['nombre']?.toString() ?? '') : '';
                      final isEgreso = tipoStr.toUpperCase() == 'EGRESO' || t['tipo']?['id'] == 2;
                      
                      final monto = double.tryParse(t['montoTransaccion']?.toString() ?? '0') ?? 0.0;
                      final motivo = t['motivo'] ?? '';
                      
                      String fechaHora = '';
                      if (t['fechaHoraTransaccion'] != null) {
                        try {
                          final dt = DateTime.parse(t['fechaHoraTransaccion']);
                          fechaHora = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        } catch (_) {
                          fechaHora = t['fechaHoraTransaccion'].toString();
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                tipoStr.toUpperCase(), 
                                style: TextStyle(
                                  color: isEgreso ? Colors.red.shade300 : HotelPMSColors.textoPrincipal, 
                                  fontWeight: FontWeight.w500, 
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(motivo, style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(fechaHora, style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${isEgreso ? "-" : "+"} S/ ${monto.abs().toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: isEgreso ? Colors.red.shade400 : HotelPMSColors.textoPrincipal, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTarjetaMonto(String titulo, String valor, Color colorIcono) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: HotelPMSColors.fondoTarjeta, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
              const SizedBox(height: 6),
              Text(valor, style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(Icons.attach_money, color: colorIcono, size: 22),
        ],
      ),
    );
  }

  void _mostrarRegistrarMovimientoModal(BuildContext context) {
    String tipoSeleccionado = 'Ingreso';
    final TextEditingController descController = TextEditingController();
    final TextEditingController montoController = TextEditingController();
    final modalFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HotelPMSColors.fondoTarjeta,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 16,
              ),
              child: Form(
                key: modalFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registrar Movimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal)),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Ingreso')),
                            selected: tipoSeleccionado == 'Ingreso',
                            selectedColor: const Color(0xFF1E3A8A), 
                            labelStyle: TextStyle(color: tipoSeleccionado == 'Ingreso' ? Colors.white : HotelPMSColors.textoSecundario),
                            onSelected: (bool selected) {
                              if (selected) setModalState(() => tipoSeleccionado = 'Ingreso');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Egreso')),
                            selected: tipoSeleccionado == 'Egreso',
                            selectedColor: const Color(0xFF7F1D1D), 
                            labelStyle: TextStyle(color: tipoSeleccionado == 'Egreso' ? Colors.white : HotelPMSColors.textoSecundario),
                            onSelected: (bool selected) {
                              if (selected) setModalState(() => tipoSeleccionado = 'Egreso');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                      decoration: InputDecoration(
                        labelText: 'Monto (S/)',
                        labelStyle: const TextStyle(color: HotelPMSColors.textoSecundario),
                        filled: true,
                        fillColor: HotelPMSColors.fondoOscuro,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el monto';
                        }
                        final val = double.tryParse(value);
                        if (val == null || val <= 0) {
                          return 'Ingrese un monto válido mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: descController,
                      style: const TextStyle(color: HotelPMSColors.textoPrincipal),
                      decoration: InputDecoration(
                        labelText: 'Descripción / Concepto',
                        labelStyle: const TextStyle(color: HotelPMSColors.textoSecundario),
                        filled: true,
                        fillColor: HotelPMSColors.fondoOscuro,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese la descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento),
                        onPressed: () {
                          if (modalFormKey.currentState!.validate()) {
                            double monto = double.parse(montoController.text);
                            int tipoId = tipoSeleccionado == 'Ingreso' ? 1 : 2;
                            
                            Navigator.pop(context);
                            _registrarTransaccion(monto, descController.text, tipoId);
                          }
                        },
                        child: const Text('Guardar Transacción', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarArqueoModal(BuildContext context) {
    final List<Map<String, dynamic>> denominaciones = [
      {'valor': 200.0, 'tipo': 'Billete'},
      {'valor': 100.0, 'tipo': 'Billete'},
      {'valor': 50.0, 'tipo': 'Billete'},
      {'valor': 20.0, 'tipo': 'Billete'},
      {'valor': 10.0, 'tipo': 'Billete'},
      {'valor': 5.0, 'tipo': 'Moneda'},
      {'valor': 2.0, 'tipo': 'Moneda'},
      {'valor': 1.0, 'tipo': 'Moneda'},
      {'valor': 0.50, 'tipo': 'Moneda'},
      {'valor': 0.20, 'tipo': 'Moneda'},
      {'valor': 0.10, 'tipo': 'Moneda'},
    ];

    Map<double, int> cantidades = {for (var d in denominaciones) d['valor']: 0};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HotelPMSColors.fondoTarjeta,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double totalContado = cantidades.entries.fold(0.0, (sum, entry) => sum + (entry.key * entry.value));
            double diferencia = totalContado - _saldoSistema;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Arqueo de Caja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal)),
                  const Text('Ingrese la cantidad de billetes y monedas', style: TextStyle(fontSize: 12, color: HotelPMSColors.textoSecundario)),
                  const Divider(color: HotelPMSColors.fondoOscuro, height: 20),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: denominaciones.length,
                      itemBuilder: (context, index) {
                        double val = denominaciones[index]['valor'];
                        String tipo = denominaciones[index]['tipo'];
                        int cant = cantidades[val] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('S/ ${val.toStringAsFixed(2)}', style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(tipo, style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 11)),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: HotelPMSColors.textoSecundario),
                                    onPressed: cant > 0 ? () => setModalState(() => cantidades[val] = cant - 1) : null,
                                  ),
                                  Container(
                                    width: 45,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(color: HotelPMSColors.fondoOscuro, borderRadius: BorderRadius.circular(4)),
                                    child: Text('$cant', style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: HotelPMSColors.naranjaAcento),
                                    onPressed: () => setModalState(() => cantidades[val] = cant + 1),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HotelPMSColors.fondoOscuro,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Contado:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                            Text('S/ ${totalContado.toStringAsFixed(2)}', style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saldo Sistema:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
                            Text('S/ ${_saldoSistema.toStringAsFixed(2)}', style: const TextStyle(color: HotelPMSColors.textoPrincipal)),
                          ],
                        ),
                        const Divider(color: HotelPMSColors.fondoTarjeta),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diferencia:', style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              'S/ ${diferencia.toStringAsFixed(2)}',
                              style: TextStyle(color: diferencia == 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: HotelPMSColors.fondoOscuro)),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: HotelPMSColors.textoSecundario)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: HotelPMSColors.naranjaAcento),
                          onPressed: () {
                            setState(() {
                              _totalContadoArqueo = totalContado;
                              _arqueoRealizado = true;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Guardar Arqueo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarCerrarCajaModal(BuildContext context) {
    if (!_arqueoRealizado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, realice el Arqueo de Caja antes de proceder al cierre.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    double diferencia = _totalContadoArqueo - _saldoSistema;
    final TextEditingController notaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HotelPMSColors.fondoTarjeta,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Confirmar Cierre de Caja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HotelPMSColors.textoPrincipal)),
                  IconButton(icon: const Icon(Icons.close, color: HotelPMSColors.textoPrincipal), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Text('Verifique los balances finales del turno actual.', style: TextStyle(fontSize: 12, color: HotelPMSColors.textoSecundario)),
              const Divider(color: HotelPMSColors.fondoOscuro, height: 20),

              _buildFilaResumenCierre('Saldo en Sistema:', 'S/ ${_saldoSistema.toStringAsFixed(2)}', HotelPMSColors.textoPrincipal),
              const SizedBox(height: 8),
              _buildFilaResumenCierre('Dinero Real Físico:', 'S/ ${_totalContadoArqueo.toStringAsFixed(2)}', HotelPMSColors.naranjaAcento),
              const SizedBox(height: 8),
              _buildFilaResumenCierre(
                'Desfase / Estado:',
                diferencia == 0 ? 'Caja Cuadrada' : 'S/ ${diferencia.toStringAsFixed(2)}',
                diferencia == 0 ? Colors.green : Colors.red,
                bold: true,
              ),
              const SizedBox(height: 16),

              const Text('Notas u Observaciones de Cierre:', style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: notaController,
                maxLines: 2,
                style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ej. Faltó cuadrar céntimos por redondeo...',
                  hintStyle: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 13),
                  filled: true,
                  fillColor: HotelPMSColors.fondoOscuro,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444), 
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _cerrarCaja(_totalContadoArqueo);
                  },
                  child: const Text('Confirmar y Cerrar Turno', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilaResumenCierre(String titulo, String valor, Color colorValor, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 14)),
        Text(valor, style: TextStyle(color: colorValor, fontSize: 15, fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}