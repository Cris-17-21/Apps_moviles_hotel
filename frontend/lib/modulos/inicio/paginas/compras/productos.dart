import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../rutas/nombres_rutas.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({Key? key}) : super(key: key);

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _estadoSeleccionado = 'todos';

  // Datos de ejemplo
  final List<Map<String, dynamic>> productos = [
    {
      'producto': 'Coca Cola 500ml',
      'categoria': 'Bebidas',
      'unidad': 'Unidad',
      'stock': 150,
      'precio': 2.50,
      'estado': 'Activo',
    },
    {
      'producto': 'Toallas de Baño',
      'categoria': 'Limpieza',
      'unidad': 'Unidad',
      'stock': 45,
      'precio': 12.00,
      'estado': 'Activo',
    },
    {
      'producto': 'Detergente Industrial',
      'categoria': 'Limpieza',
      'unidad': 'Litro',
      'stock': 25,
      'precio': 15.50,
      'estado': 'Activo',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      rutaActual: NombresRutas.productos,
      cuerpo: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Productos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HotelPMSColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Administra el catálogo',
                style: TextStyle(
                  fontSize: 14,
                  color: HotelPMSColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 24),

              // Botón Nuevo Producto
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar a formulario de nuevo producto
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nuevo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HotelPMSColors.naranjaAcento,
                    foregroundColor: HotelPMSColors.textoPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Buscador
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  hintStyle: const TextStyle(
                    color: HotelPMSColors.textoSecundario,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: HotelPMSColors.textoSecundario,
                  ),
                  filled: true,
                  fillColor: HotelPMSColors.fondoInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: HotelPMSColors.textoPrincipal),
              ),
              const SizedBox(height: 16),

              // Filtro de Estados
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: HotelPMSColors.fondoInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _estadoSeleccionado,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: HotelPMSColors.fondoTarjeta,
                  style: const TextStyle(
                    color: HotelPMSColors.textoPrincipal,
                    fontSize: 14,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _estadoSeleccionado = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'todos',
                      child: Text('Todos los estados'),
                    ),
                    DropdownMenuItem(value: 'activo', child: Text('Activo')),
                    DropdownMenuItem(
                      value: 'inactivo',
                      child: Text('Inactivo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tabla de Productos
              _buildTablaProductos(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaProductos() {
    return Container(
      decoration: BoxDecoration(
        color: HotelPMSColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            HotelPMSColors.fondoOscuro,
          ),
          headingRowHeight: 48,
          dataRowHeight: 56,
          columns: const [
            DataColumn(
              label: Text(
                'PRODUCTO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'CATEGORÍA',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'UNIDAD',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'STOCK',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'PRECIO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ESTADO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ACCIONES',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          rows: productos
              .map(
                (producto) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        producto['producto'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        producto['categoria'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        producto['unidad'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        producto['stock'].toString(),
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        'S/. ${producto['precio'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: HotelPMSColors.naranjaAcento,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: producto['estado'] == 'Activo'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          producto['estado'],
                          style: TextStyle(
                            color: producto['estado'] == 'Activo'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: HotelPMSColors.textoSecundario,
                              size: 18,
                            ),
                            onPressed: () {
                              // TODO: Editar
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: HotelPMSColors.textoEliminar,
                              size: 18,
                            ),
                            onPressed: () {
                              // TODO: Eliminar
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
