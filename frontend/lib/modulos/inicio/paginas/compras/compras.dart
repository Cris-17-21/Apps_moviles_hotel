import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../rutas/nombres_rutas.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({Key? key}) : super(key: key);

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> compras = [
    {
      'factura': '001-00001',
      'proveedor': 'Distribuidora Norte SAC',
      'fecha': '2026-05-01',
      'items': 5,
      'total': 1250.50,
    },
    {
      'factura': '001-00002',
      'proveedor': 'Alimentos Frescos EIRL',
      'fecha': '2026-05-02',
      'items': 3,
      'total': 850.00,
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
      rutaActual: NombresRutas.comprasLista,
      cuerpo: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Compras',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HotelPMSColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Registra y administra compras',
                style: TextStyle(
                  fontSize: 14,
                  color: HotelPMSColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 24),

              // Botón Nueva Compra
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar a formulario de nueva compra
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nueva'),
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
                  hintText: 'Buscar por factura o proveedor...',
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
              const SizedBox(height: 24),

              // Tabla de Compras
              _buildTablaCompras(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaCompras() {
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
                'FACTURA',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'PROVEEDOR',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'FECHA',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ITEMS',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'TOTAL',
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
          rows: compras
              .map(
                (compra) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        compra['factura'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        compra['proveedor'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        compra['fecha'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        compra['items'].toString(),
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        'S/. ${compra['total'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: HotelPMSColors.naranjaAcento,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: HotelPMSColors.textoSecundario,
                              size: 18,
                            ),
                            onPressed: () {
                              // TODO: Ver detalles
                            },
                          ),
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
