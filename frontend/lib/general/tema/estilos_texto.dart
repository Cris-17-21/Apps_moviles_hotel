import 'package:flutter/material.dart';
import 'colores_tema.dart';

class HotelPMSTextStyles {
  // Títulos Principales
  static const TextStyle tituloDashboard = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: HotelPMSColors.textoPrincipal,
  );

  static const TextStyle tituloSeccion = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: HotelPMSColors.textoPrincipal,
  );

  // Tarjetas (Nombres, Habitaciones, etc.)
  static const TextStyle tituloTarjeta = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: HotelPMSColors.textoPrincipal,
  );

  static const TextStyle subtituloGris = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: HotelPMSColors.textoSecundario,
  );

  // Valores Numéricos Fuertes
  static const TextStyle valorGrande = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: HotelPMSColors.textoPrincipal,
  );

  static const TextStyle precioDestacado = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: HotelPMSColors.naranjaAcento,
  );

  // Estados y Roles
  static const TextStyle textoRolNaranja = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: HotelPMSColors.naranjaAcento,
  );

  static const TextStyle estadoBadge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: HotelPMSColors.textoPrincipal,
  );
}