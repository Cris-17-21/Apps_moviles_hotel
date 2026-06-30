import 'package:flutter/material.dart';
import 'barra_superior.dart';
import 'menu_lateral.dart';

class LayoutPrincipal extends StatelessWidget {
  final Widget cuerpo;
  final String rutaActual;
  final String? tituloBarra;

  const LayoutPrincipal({
    super.key,
    required this.cuerpo,
    required this.rutaActual,
    this.tituloBarra,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraSuperior(titulo: tituloBarra ?? 'HotelPMS'),
      drawer: MenuLateral(rutaActual: rutaActual),
      body: SafeArea(
        child: cuerpo,
      ),
    );
  }
}