class ModeloMovimiento {
  final String id;
  final String tipo; // 'Venta', 'Ingreso', 'Egreso'
  final String descripcion;
  final String fecha;
  final String hora;
  final double monto;

  const ModeloMovimiento({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.monto,
  });
}