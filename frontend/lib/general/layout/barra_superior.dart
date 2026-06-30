import 'package:flutter/material.dart';
import '../tema/colores_tema.dart';

class BarraSuperior extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;

  const BarraSuperior({
    super.key, 
    this.titulo = 'HotelPMS',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: HotelPMSColors.fondoOscuro,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: HotelPMSColors.textoPrincipal, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          color: HotelPMSColors.naranjaAcento,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: HotelPMSColors.textoSecundario),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}