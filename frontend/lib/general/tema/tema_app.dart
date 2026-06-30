import 'package:flutter/material.dart';
import 'colores_tema.dart';
import 'estilos_texto.dart';

class HotelPMSAppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: HotelPMSColors.fondoOscuro,
      
      // Paleta Global de Componentes
      colorScheme: const ColorScheme.dark(
        primary: HotelPMSColors.naranjaAcento,
        secondary: HotelPMSColors.azulAcento,
        surface: HotelPMSColors.fondoTarjeta,
        error: HotelPMSColors.textoEliminar,
      ),

      // Estilo de las Tarjetas (Cards)
      cardTheme: CardThemeData(
        color: HotelPMSColors.fondoTarjeta,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Estilo de los Botones Principales (como el + Nuevo)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HotelPMSColors.naranjaAcento,
          foregroundColor: HotelPMSColors.textoPrincipal,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Estilo de los Inputs / Buscadores
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HotelPMSColors.fondoInput,
        hintStyle: const TextStyle(color: HotelPMSColors.textoSecundario),
        prefixIconColor: HotelPMSColors.textoSecundario,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),

      // Tipografía por defecto del sistema
      textTheme: const TextTheme(
        headlineLarge: HotelPMSTextStyles.tituloDashboard,
        titleLarge: HotelPMSTextStyles.tituloSeccion,
        bodyLarge: HotelPMSTextStyles.tituloTarjeta,
        bodyMedium: HotelPMSTextStyles.subtituloGris,
      ),
    );
  }
}