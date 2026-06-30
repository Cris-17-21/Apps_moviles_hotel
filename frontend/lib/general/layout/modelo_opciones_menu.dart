import 'package:flutter/material.dart';

class ModeloOpcionesMenu {
  final IconData icono;
  final String titulo;
  final String? ruta; // Ahora es opcional porque las categorías padres no navegan directamente
  final List<ModeloOpcionesMenu>? subOpciones; // Para almacenar las subrutas

  const ModeloOpcionesMenu({
    required this.icono,
    required this.titulo,
    this.ruta,
    this.subOpciones,
  });

  // Un helper para saber si es una categoría desplegable
  bool get esDesplegable => subOpciones != null && subOpciones!.isNotEmpty;
}