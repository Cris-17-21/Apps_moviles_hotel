class ModeloProducto {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;

  const ModeloProducto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.stock,
  });
}