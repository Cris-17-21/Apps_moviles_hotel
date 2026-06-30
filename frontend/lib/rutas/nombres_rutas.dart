class NombresRutas {
  NombresRutas._();

  // Autenticación y General
  static const String login = '/login';
  static const String dashboard = '/dashboard'; // Cambiado de 'inicio' a 'dashboard' para hacer match con tu menú
  static const String perfil = '/perfil';
  static const String configuracion = '/configuracion';

  // Módulo: Seguridad
  static const String usuarios = '/usuarios';
  static const String roles = '/roles';
  static const String permisos = '/permisos';

  // Módulo: Recepción
  static const String habitaciones = '/habitaciones';
  static const String reservas = '/reservas';
  static const String checkInOut = '/check-in-out';

  // Módulo: Ventas / POS
  static const String pos = '/pos';
  static const String caja = '/caja';

  // Módulo: Compras y Almacén
  static const String proveedores = '/proveedores';
  static const String productos = '/productos';
  static const String comprasLista = '/compras-lista';
  static const String almacen = '/almacen';

  // Otros Módulos
  static const String mantenimiento = '/mantenimiento';
  static const String reportes = '/reportes';
}