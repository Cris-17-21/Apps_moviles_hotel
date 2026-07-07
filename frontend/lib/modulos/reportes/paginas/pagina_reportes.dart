import 'package:flutter/material.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../general/tema/colores_tema.dart';
import '../servicios/reportes_service.dart';
import '../util/date_utils.dart';
import 'pagina_resultado_reporte.dart';

class PaginaReportes extends StatefulWidget {
  const PaginaReportes({super.key});

  @override
  State<PaginaReportes> createState() => _PaginaReportesState();
}

class _PaginaReportesState extends State<PaginaReportes> {
  final TextEditingController _fechaInicioController =
      TextEditingController(text: '01/04/2026');
  final TextEditingController _fechaFinController =
      TextEditingController(text: '02/05/2026');

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  /// Validates and converts dates. Shows error if invalid.
  bool _validarFechas() {
    final inicio = aFormatoISO(_fechaInicioController.text);
    final fin = aFormatoISO(_fechaFinController.text);

    if (inicio == null || fin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese fechas válidas en formato DD/MM/YYYY'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  /// Shows a dialog to select Caja tipos (INGRESO/EGRESO).
  Future<String> _mostrarDialogoTiposCaja() async {
    final seleccionados = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => _DialogoTiposCaja(),
    );
    return (seleccionados ?? ['INGRESO', 'EGRESO']).join(',');
  }

  void _abrirReporte(
    String titulo,
    Future<List<Map<String, dynamic>>> Function() fetchData,
    List<ColumnaReporte> columnas, {
    bool mostrarTotales = false,
    String? urlPDF,
    String? urlExcel,
  }) {
    if (!_validarFechas()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaginaResultadoReporte(
          titulo: titulo,
          fetchData: fetchData,
          columnas: columnas,
          mostrarTotales: mostrarTotales,
          urlPDF: urlPDF,
          urlExcel: urlExcel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      rutaActual: '/reportes',
      tituloBarra: 'HotelPMS',
      cuerpo: Scrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: HotelPMSColors.naranjaAcento,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Reportes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HotelPMSColors.textoPrincipal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Reportes detallados del negocio',
                style: TextStyle(
                  fontSize: 13,
                  color: HotelPMSColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 16),

              // Periodo de Análisis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoTarjeta,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          HotelPMSColors.fondoInput.withOpacity(0.5),
                      width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: HotelPMSColors.naranjaAcento,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Periodo de Análisis',
                          style: TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fecha Inicio',
                      style: TextStyle(
                        color: HotelPMSColors.textoSecundario,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(_fechaInicioController),
                    const SizedBox(height: 12),
                    const Text(
                      'Fecha Fin',
                      style: TextStyle(
                        color: HotelPMSColors.textoSecundario,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildInputField(_fechaFinController),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tarjetas de Reporte
              _buildTarjetaReporte(
                titulo: 'Reporte de Compras',
                descripcion: 'Análisis de adquisiciones por periodo',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Reporte de Compras',
                    () => ReportesService.obtenerReporteProductos(
                        desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'PRODUCTO', campo: 'productoNombre'),
                      const ColumnaReporte(
                          titulo: 'CANT. COMPRADA',
                          campo: 'cantidadComprada',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'totalGastado',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/productos/pdf?desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/productos/excel?desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Reporte de Proveedores',
                descripcion: 'Compras por proveedor y volumen',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Reporte de Proveedores',
                    () => ReportesService.obtenerReporteProveedores(
                        desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'PROVEEDOR',
                          campo: 'proveedorNombre'),
                      const ColumnaReporte(
                          titulo: 'FACTURAS',
                          campo: 'cantidadFacturas',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'totalGastado',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/proveedores/pdf?desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/proveedores/excel?desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Productos Más Vendidos',
                descripcion: 'Top de productos por ventas',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Productos Más Vendidos',
                    () => ReportesService.obtenerVentasProductos(
                        desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'PRODUCTO',
                          campo: 'productoNombre'),
                      const ColumnaReporte(
                          titulo: 'CANT. VENDIDA',
                          campo: 'cantidadVendida',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'totalVendido',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/ventas/productos/pdf?desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/ventas/productos/excel?desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Clientes Frecuentes',
                descripcion: 'Clientes con mayor cantidad de reservas',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Clientes Frecuentes',
                    () => ReportesService.obtenerClientesFrecuentes(
                        desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'CLIENTE',
                          campo: 'clienteNombre'),
                      const ColumnaReporte(
                          titulo: 'COMPRAS',
                          campo: 'cantidadCompras',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'totalGastado',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/ventas/clientes/pdf?desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/ventas/clientes/excel?desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Métodos de Pago',
                descripcion: 'Análisis de medios de pago utilizados',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Métodos de Pago',
                    () => ReportesService.obtenerMetodosPago(
                        desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'MÉTODO',
                          campo: 'metodoPago'),
                      const ColumnaReporte(
                          titulo: 'VECES USADO',
                          campo: 'vecesUsado',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'totalRecibido',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/ventas/metodos-pago/pdf?desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/ventas/metodos-pago/excel?desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Reporte de Caja',
                descripcion: 'Movimientos e ingresos de caja',
                onTap: () async {
                  if (!_validarFechas()) return;
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  final tipos = await _mostrarDialogoTiposCaja();
                  if (!mounted) return;
                  _abrirReporte(
                    'Reporte de Caja',
                    () => ReportesService.obtenerResumenCaja(
                        desde, hasta, tipos),
                    [
                      const ColumnaReporte(
                          titulo: 'TIPO', campo: 'tipo'),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'total',
                          esNumerico: true),
                    ],
                    urlPDF:
                        '/cerro-verde/reportes/caja/resumen/pdf?desde=$desde&hasta=$hasta&tipos=$tipos',
                    urlExcel:
                        '/cerro-verde/reportes/caja/resumen/excel?desde=$desde&hasta=$hasta&tipos=$tipos',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Reservas Mensuales (Habitaciones)',
                descripcion: 'Habitaciones reservadas por mes',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Reservas Mensuales (Habitaciones)',
                    () => ReportesService.obtenerReservasPorMes(
                        'habitaciones', desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'MES', campo: 'mes'),
                      const ColumnaReporte(
                          titulo: 'CANTIDAD',
                          campo: 'cantidad',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'total',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/ventas/reservas-por-mes/pdf?tipo=habitaciones&desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/ventas/reservas-por-mes/excel?tipo=habitaciones&desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildTarjetaReporte(
                titulo: 'Reservas Mensuales (Salones)',
                descripcion: 'Salones reservados por mes',
                onTap: () {
                  final desde = aFormatoISO(_fechaInicioController.text)!;
                  final hasta = aFormatoISO(_fechaFinController.text)!;
                  _abrirReporte(
                    'Reservas Mensuales (Salones)',
                    () => ReportesService.obtenerReservasPorMes(
                        'salones', desde, hasta),
                    [
                      const ColumnaReporte(
                          titulo: 'MES', campo: 'mes'),
                      const ColumnaReporte(
                          titulo: 'CANTIDAD',
                          campo: 'cantidad',
                          esNumerico: true),
                      const ColumnaReporte(
                          titulo: 'TOTAL S/.',
                          campo: 'total',
                          esNumerico: true),
                    ],
                    mostrarTotales: true,
                    urlPDF:
                        '/cerro-verde/reportes/ventas/reservas-por-mes/pdf?tipo=salones&desde=$desde&hasta=$hasta',
                    urlExcel:
                        '/cerro-verde/reportes/ventas/reservas-por-mes/excel?tipo=salones&desde=$desde&hasta=$hasta',
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de texto para fechas con selector de calendario
  Widget _buildInputField(TextEditingController controller) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoInput,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(
                color: HotelPMSColors.textoPrincipal,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () => _seleccionarFecha(controller),
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            color: HotelPMSColors.textoSecundario,
            size: 18,
          ),
        ],
      ),
    );
  }

  // Tarjeta de reporte individual
  Widget _buildTarjetaReporte({
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: HotelPMSColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: HotelPMSColors.fondoInput.withOpacity(0.5),
              width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1A0E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description,
                color: HotelPMSColors.naranjaAcento,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: HotelPMSColors.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Selector de fecha con DatePicker
  Future<void> _seleccionarFecha(
      TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: HotelPMSColors.naranjaAcento,
              onPrimary: Colors.white,
              surface: HotelPMSColors.fondoTarjeta,
              onSurface: HotelPMSColors.textoPrincipal,
            ),
            dialogBackgroundColor: HotelPMSColors.fondoOscuro,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String dia = picked.day.toString().padLeft(2, '0');
      final String mes = picked.month.toString().padLeft(2, '0');
      final String anio = picked.year.toString();
      setState(() {
        controller.text = '$dia/$mes/$anio';
      });
    }
  }
}

/// Dialog to select Caja tipos (INGRESO/EGRESO).
class _DialogoTiposCaja extends StatefulWidget {
  @override
  State<_DialogoTiposCaja> createState() => _DialogoTiposCajaState();
}

class _DialogoTiposCajaState extends State<_DialogoTiposCaja> {
  final Set<String> _seleccionados = {'INGRESO', 'EGRESO'};

  static const _opciones = ['INGRESO', 'EGRESO'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      title: const Text(
        'Tipos de movimiento',
        style: TextStyle(color: HotelPMSColors.textoPrincipal),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _opciones.map((tipo) {
          return CheckboxListTile(
            title: Text(tipo,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal)),
            value: _seleccionados.contains(tipo),
            activeColor: HotelPMSColors.naranjaAcento,
            checkColor: HotelPMSColors.textoPrincipal,
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _seleccionados.add(tipo);
                } else {
                  _seleccionados.remove(tipo);
                }
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: HotelPMSColors.textoSecundario)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_seleccionados.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Seleccione al menos un tipo de movimiento'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            Navigator.pop(context, _seleccionados.toList());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: HotelPMSColors.naranjaAcento,
            foregroundColor: HotelPMSColors.textoPrincipal,
          ),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
