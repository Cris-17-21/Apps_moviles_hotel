import 'package:flutter/material.dart';
import '../tema/colores_tema.dart';
import 'opciones_menu.dart';
import 'modelo_opciones_menu.dart';

class MenuLateral extends StatelessWidget {
  final String rutaActual;

  const MenuLateral({super.key, required this.rutaActual});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      child: Column(
        children: [
          // Encabezado
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  const Text(
                    'HotelPMS',
                    style: TextStyle(
                      color: HotelPMSColors.naranjaAcento,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: HotelPMSColors.textoSecundario, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          ),
          
          // Lista de opciones con Scroll
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: opcionesDelMenu.length,
              itemBuilder: (context, index) {
                final opcion = opcionesDelMenu[index];
                
                if (opcion.esDesplegable) {
                  return _buildMenuDesplegable(context, opcion);
                } else {
                  return _buildItemSimple(context, opcion);
                }
              },
            ),
          ),

          // Perfil de Usuario en el Footer (image_c1e2e5.png)
          const Divider(color: HotelPMSColors.fondoInput, height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: HotelPMSColors.fondoOscuro,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: HotelPMSColors.naranjaAcento,
                  radius: 18,
                  child: Icon(Icons.person, color: HotelPMSColors.textoPrincipal, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(color: HotelPMSColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Recepcionista',
                        style: TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: HotelPMSColors.textoSecundario, size: 20),
                  onPressed: () {
                    // Acción logout
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Item Simple (Dashboard, Caja, Almacén, etc.)
  Widget _buildItemSimple(BuildContext context, ModeloOpcionesMenu opcion) {
    final esActivo = rutaActual == opcion.ruta;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: esActivo ? HotelPMSColors.naranjaAcento : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          opcion.icono, 
          color: esActivo ? HotelPMSColors.textoPrincipal : HotelPMSColors.textoSecundario
        ),
        title: Text(
          opcion.titulo,
          style: TextStyle(
            color: esActivo ? HotelPMSColors.textoPrincipal : HotelPMSColors.textoPrincipal,
            fontWeight: esActivo ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          if (!esActivo && opcion.ruta != null) {
            Navigator.pushReplacementNamed(context, opcion.ruta!);
          }
        },
      ),
    );
  }

  // Categoría Desplegable (Seguridad, Recepción, Ventas, Compras)
  Widget _buildMenuDesplegable(BuildContext context, ModeloOpcionesMenu padre) {
    // Verificar si algún hijo está activo para dejar el menú expandido por defecto
    final tieneHijoActivo = padre.subOpciones!.any((hijo) => hijo.ruta == rutaActual);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: tieneHijoActivo,
        leading: Icon(padre.icono, color: HotelPMSColors.textoSecundario),
        title: Text(
          padre.titulo,
          style: const TextStyle(color: HotelPMSColors.textoPrincipal, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        iconColor: HotelPMSColors.textoSecundario,
        collapsedIconColor: HotelPMSColors.textoSecundario,
        childrenPadding: const EdgeInsets.only(left: 16),
        children: padre.subOpciones!.map((hijo) {
          final esHijoActivo = rutaActual == hijo.ruta;
          return Container(
            margin: const EdgeInsets.only(bottom: 2, top: 2),
            decoration: BoxDecoration(
              color: esHijoActivo ? HotelPMSColors.naranjaAcento : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                hijo.icono, 
                color: esHijoActivo ? HotelPMSColors.textoPrincipal : HotelPMSColors.textoSecundario,
                size: 20,
              ),
              title: Text(
                hijo.titulo,
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: esHijoActivo ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                if (!esHijoActivo && hijo.ruta != null) {
                  Navigator.pushReplacementNamed(context, hijo.ruta!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}