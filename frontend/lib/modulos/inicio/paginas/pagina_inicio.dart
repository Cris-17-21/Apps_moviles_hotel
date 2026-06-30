import 'package:flutter/material.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../general/tema/colores_tema.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      rutaActual: '/dashboard',
      tituloBarra: 'HotelPMS',
      cuerpo: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del Dashboard
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: HotelPMSColors.textoPrincipal,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bienvenido al Sistema de Gestión Hotelera',
              style: TextStyle(
                fontSize: 14,
                color: HotelPMSColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 20),

            // Contenedor de Tarjetas de Métricas (Habitaciones, Reservas, Ventas, Huéspedes)
            const _MetricasGrid(),
            const SizedBox(height: 24),

            // Sección: Reservas Recientes
            const _SeccionReservasRecientes(),
            const SizedBox(height: 24),

            // Sección: Alertas y Notificaciones
            const _SeccionAlertas(),
            const SizedBox(height: 24),

            // Sección: Acciones Rápidas
            const _SeccionAccionesRapidas(),
            const SizedBox(height: 24),

            // Sección: Gráfico de Ocupación Semanal
            const _SeccionOcupacionSemanal(),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// WIDGETS INTERNOS COMPONENTIZADOS
// -------------------------------------------------------------------

class _MetricasGrid extends StatelessWidget {
  const _MetricasGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TarjetaMetrica(
          titulo: 'Habitaciones Disponibles',
          valor: '12',
          subvalor: ' / 24',
          icono: Icons.business,
          colorIcono: HotelPMSColors.textoSecundario,
        ),
        SizedBox(height: 12),
        _TarjetaMetrica(
          titulo: 'Reservas Hoy',
          valor: '8',
          icono: Icons.calendar_today_outlined,
          colorIcono: HotelPMSColors.naranjaAcento,
        ),
        SizedBox(height: 12),
        _TarjetaMetrica(
          titulo: 'Ventas del Día',
          valor: 'S/ 4,250',
          icono: Icons.shopping_cart_outlined,
          colorIcono: HotelPMSColors.textoSecundario,
        ),
        SizedBox(height: 12),
        _TarjetaMetrica(
          titulo: 'Huéspedes Activos',
          valor: '32',
          icono: Icons.people_alt_outlined,
          colorIcono: HotelPMSColors.azulAcento,
        ),
      ],
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? subvalor;
  final IconData icono;
  final Color colorIcono;

  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    this.subvalor,
    required this.icono,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: HotelPMSColors.textoSecundario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        valor,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                      if (subvalor != null)
                        Text(
                          subvalor!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: HotelPMSColors.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: colorIcono, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionReservasRecientes extends StatelessWidget {
  const _SeccionReservasRecientes();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: HotelPMSColors.naranjaAcento, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Reservas Recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HotelPMSColors.textoPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _ItemReserva(
              nombre: 'Juan Pérez',
              detalle: 'Hab. 101 • 2026-05-02',
              estadoTexto: 'Check-in',
              estadoColor: HotelPMSColors.textoPrincipal,
              estadoFondo: Colors.transparent,
            ),
            const SizedBox(height: 12),
            const _ItemReserva(
              nombre: 'María García',
              detalle: 'Hab. 205 • 2026-05-03',
              estadoTexto: 'Pendiente',
              estadoColor: HotelPMSColors.textoPrincipal,
              estadoFondo: Colors.transparent,
            ),
            const SizedBox(height: 12),
            const _ItemReserva(
              nombre: 'Carlos López',
              detalle: 'Hab. 304 • 2026-05-02',
              estadoTexto: 'Pagada',
              estadoColor: HotelPMSColors.naranjaAcento,
              estadoFondo: Color(0xFF2C1A0E), // Tono marrón/naranja muy oscuro Noir
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemReserva extends StatelessWidget {
  final String nombre;
  final String detalle;
  final String estadoTexto;
  final Color estadoColor;
  final Color estadoFondo;

  const _ItemReserva({
    required this.nombre,
    required this.detalle,
    required this.estadoTexto,
    required this.estadoColor,
    required this.estadoFondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoOscuro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HotelPMSColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detalle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HotelPMSColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: estadoFondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              estadoTexto,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: estadoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionAlertas extends StatelessWidget {
  const _SeccionAlertas();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: HotelPMSColors.textoPrincipal, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Alertas y Notificaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HotelPMSColors.textoPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoOscuro,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: HotelPMSColors.fondoInput),
              ),
              child: const Text(
                '3 habitaciones en limpieza pendiente',
                style: TextStyle(fontSize: 13, color: HotelPMSColors.textoPrincipal),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoOscuro,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: HotelPMSColors.azulAcento.withOpacity(0.3)),
              ),
              child: const Text(
                'Reserva de salón para mañana: Evento Corporativo',
                style: TextStyle(fontSize: 13, color: HotelPMSColors.textoPrincipal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionAccionesRapidas extends StatelessWidget {
  const _SeccionAccionesRapidas();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: HotelPMSColors.textoPrincipal,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HotelPMSColors.naranjaAcento,
                      foregroundColor: HotelPMSColors.textoPrincipal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                    child: const Text('Nueva Reserva', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HotelPMSColors.fondoInput,
                      foregroundColor: HotelPMSColors.textoPrincipal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                    child: const Text('Check-in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionOcupacionSemanal extends StatelessWidget {
  const _SeccionOcupacionSemanal();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: HotelPMSColors.naranjaAcento, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Ocupación Esta Semana',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HotelPMSColors.textoPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.transparent,
              child: const Align(
                alignment: Alignment.center,
                child: Text(
                  '[Espacio para Gráfico]',
                  style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 12),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lun', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                  Text('Mar', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                  Text('Mié', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                  Text('Jue', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                  Text('Vie', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                  Text('Sáb', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                  Text('Dom', style: TextStyle(fontSize: 11, color: HotelPMSColors.textoSecundario)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}