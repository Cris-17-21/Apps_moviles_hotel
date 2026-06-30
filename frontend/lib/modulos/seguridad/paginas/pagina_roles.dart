import 'package:flutter/material.dart';
import '../../../general/tema/colores_tema.dart';
import '../../../general/tema/estilos_texto.dart';
import '../../../general/layout/layout_principal.dart';
import '../../../rutas/nombres_rutas.dart';

class PaginaRoles extends StatelessWidget {
  const PaginaRoles({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Seguridad / Roles',
      rutaActual: NombresRutas.roles,
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabecera
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Roles', style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Administra roles y permisos',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // 2. Botón "+ Nuevo"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
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
            const SizedBox(height: 24),

            // 3. Lista de Roles
            Expanded(
              child: ListView(
                children: [
                  _construirTarjetaRol(
                    titulo: 'Administrador',
                    descripcion: 'Acceso total al sistema',
                    permisos: ['Todos los módulos'],
                  ),
                  const SizedBox(height: 16),
                  _construirTarjetaRol(
                    titulo: 'Recepcionista',
                    descripcion: 'Gestión de reservas y habitaciones',
                    permisos: ['Recepción', 'Ventas'],
                  ),
                  const SizedBox(height: 16),
                  _construirTarjetaRol(
                    titulo: 'Vendedor',
                    descripcion: 'Punto de venta',
                    permisos: ['Ventas', 'Caja'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Molde para las tarjetas de Roles
  Widget _construirTarjetaRol({
    required String titulo,
    required String descripcion,
    required List<String> permisos,
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
              // Icono de escudo naranja
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HotelPMSColors.naranjaAcento.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 24,
                ),
              ),
              // Botones de acción
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: HotelPMSColors.textoSecundario,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.delete_outline,
                    color: HotelPMSColors.textoEliminar,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(titulo, style: HotelPMSTextStyles.tituloTarjeta),
          const SizedBox(height: 4),
          Text(descripcion, style: HotelPMSTextStyles.subtituloGris),
          const SizedBox(height: 16),
          Text(
            'PERMISOS',
            style: TextStyle(
              color: HotelPMSColors.textoSecundario,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          // Lista de etiquetas (badges) de permisos
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permisos.map((permiso) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: HotelPMSColors.naranjaAcento.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: HotelPMSColors.naranjaAcento.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  permiso,
                  style: const TextStyle(
                    color: HotelPMSColors.naranjaAcento,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
