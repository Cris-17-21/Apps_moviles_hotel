import 'package:flutter/material.dart';

import '../../rutas/nombres_rutas.dart'; // Asegúrate de importar tu clase
import 'modelo_opciones_menu.dart';

const List<ModeloOpcionesMenu> opcionesDelMenu = [
  ModeloOpcionesMenu(
    icono: Icons.home_outlined,
    titulo: 'Dashboard',
    ruta: NombresRutas.dashboard, // Usando la constante
  ),
  ModeloOpcionesMenu(
    icono: Icons.security,
    titulo: 'Seguridad',
    subOpciones: [
      ModeloOpcionesMenu(
        icono: Icons.person_outline,
        titulo: 'Usuarios',
        ruta: NombresRutas.usuarios,
      ),
      ModeloOpcionesMenu(
        icono: Icons.shield_outlined,
        titulo: 'Roles',
        ruta: NombresRutas.roles,
      ),
    ],
  ),
  ModeloOpcionesMenu(
    icono: Icons.business,
    titulo: 'Recepción',
    subOpciones: [
      ModeloOpcionesMenu(
        icono: Icons.single_bed_outlined,
        titulo: 'Habitaciones',
        ruta: NombresRutas.habitaciones,
      ),
      ModeloOpcionesMenu(
        icono: Icons.calendar_today_outlined,
        titulo: 'Reservas',
        ruta: NombresRutas.reservas,
      ),
      ModeloOpcionesMenu(
        icono: Icons.assignment_turned_in,
        titulo: 'Check-in/Check-out',
        ruta: NombresRutas.checkInOut,
      ),
    ],
  ),
  ModeloOpcionesMenu(
    icono: Icons.shopping_cart,
    titulo: 'Ventas',
    subOpciones: [
      ModeloOpcionesMenu(icono: Icons.shopping_cart, titulo: 'Punto de venta', ruta: NombresRutas.pos),
    ],
  ),
  ModeloOpcionesMenu(
    icono: Icons.payments,
    titulo: 'Caja',
    ruta: NombresRutas.caja,
  ),
  ModeloOpcionesMenu(
    icono: Icons.shopping_cart_outlined,
    titulo: 'Compras',
    subOpciones: [
      ModeloOpcionesMenu(
        icono: Icons.person_outline,
        titulo: 'Proveedores',
        ruta: NombresRutas.proveedores,
      ),
      ModeloOpcionesMenu(
        icono: Icons.inventory_outlined,
        titulo: 'Productos',
        ruta: NombresRutas.productos,
      ),
      ModeloOpcionesMenu(
        icono: Icons.assignment_outlined,
        titulo: 'Compras',
        ruta: NombresRutas.comprasLista,
      ),
    ],
  ),
  ModeloOpcionesMenu(
    icono: Icons.warehouse_outlined,
    titulo: 'Almacén',
    ruta: NombresRutas.almacen,
  ),
  ModeloOpcionesMenu(
    icono: Icons.build_outlined,
    titulo: 'Mantenimiento',
    ruta: NombresRutas.mantenimiento,
  ),
  ModeloOpcionesMenu(
    icono: Icons.bar_chart_outlined,
    titulo: 'Reportes',
    ruta: NombresRutas.reportes,
  ),
];
