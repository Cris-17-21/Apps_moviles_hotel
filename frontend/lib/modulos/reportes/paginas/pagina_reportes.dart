import 'package:flutter/material.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../general/tema/colores_tema.dart';

class PaginaReportes extends StatefulWidget {
  const PaginaReportes({super.key});

  @override
  State<PaginaReportes> createState() => _PaginaReportesState();
}

class _PaginaReportesState extends State<PaginaReportes> {
  final TextEditingController _fechaInicioController = TextEditingController(text: '01/04/2026');
  final TextEditingController _fechaFinController = TextEditingController(text: '02/05/2026');

  // Listado de los 8 reportes especificados
  final List<Map<String, String>> reportes = [
    {
      'titulo': 'Reporte de Compras',
      'descripcion': 'Análisis de adquisiciones por periodo',
    },
    {
      'titulo': 'Reporte de Proveedores',
      'descripcion': 'Compras por proveedor y volumen',
    },
    {
      'titulo': 'Productos Más Vendidos',
      'descripcion': 'Top de productos por ventas',
    },
    {
      'titulo': 'Clientes Frecuentes',
      'descripcion': 'Clientes con mayor cantidad de reservas',
    },
    {
      'titulo': 'Métodos de Pago',
      'descripcion': 'Análisis de medios de pago utilizados',
    },
    {
      'titulo': 'Reporte de Caja',
      'descripcion': 'Movimientos e ingresos de caja',
    },
    {
      'titulo': 'Reservas Mensuales (Habitaciones)',
      'descripcion': 'Habitaciones reservadas por mes',
    },
    {
      'titulo': 'Reservas Mensuales (Salones)',
      'descripcion': 'Salones reservados por mes',
    },
  ];

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      rutaActual: '/reportes',
      tituloBarra: 'HotelPMS',
      cuerpo: Scrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de Reportes
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

              // Tarjeta: Periodo de Análisis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoTarjeta,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HotelPMSColors.fondoInput.withOpacity(0.5), width: 1),
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

                    // Campo: Fecha Inicio
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

                    // Campo: Fecha Fin
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

              // Listado de Reportes
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reportes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = reportes[index];
                  return _buildTarjetaReporte(item);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de texto para fechas con icono de calendario simulado
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
  Widget _buildTarjetaReporte(Map<String, String> item) {
    return InkWell(
      onTap: () {
        _abrirReporte(item['titulo']!);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: HotelPMSColors.fondoTarjeta,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: HotelPMSColors.fondoInput.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            // Icono de documento en recuadro naranja/marrón oscuro
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1A0E), // Tono marrón oscuro
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description,
                color: HotelPMSColors.naranjaAcento,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Textos del Reporte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['titulo']!,
                    style: const TextStyle(
                      color: HotelPMSColors.textoPrincipal,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['descripcion']!,
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

  // Simulación de selección de fecha
  Future<void> _seleccionarFecha(TextEditingController controller) async {
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
      // Formatear fecha a DD/MM/YYYY
      final String dia = picked.day.toString().padLeft(2, '0');
      final String mes = picked.month.toString().padLeft(2, '0');
      final String anio = picked.year.toString();
      setState(() {
        controller.text = '$dia/$mes/$anio';
      });
    }
  }

  // Simulación al hacer clic en un reporte
  void _abrirReporte(String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generando $titulo desde ${_fechaInicioController.text} hasta ${_fechaFinController.text}...'),
        backgroundColor: HotelPMSColors.fondoTarjeta,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
