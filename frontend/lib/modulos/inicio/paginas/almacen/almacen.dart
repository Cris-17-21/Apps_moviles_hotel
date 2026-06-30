import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../rutas/nombres_rutas.dart';

class AlmacenPage extends StatefulWidget {
  const AlmacenPage({Key? key}) : super(key: key);

  @override
  State<AlmacenPage> createState() => _AlmacenPageState();
}

class _AlmacenPageState extends State<AlmacenPage> {
  final TextEditingController _searchController = TextEditingController();
  String _tipoMovimientoSeleccionado = 'todos';

  // Datos de ejemplo
  final List<Map<String, dynamic>> movimientos = [
    {
      'tipo': 'Entrada',
      'producto': 'Coca Cola 500ml',
      'cantidad': 50,
      'referencia': 'FACT-001-00001',
      'fecha': '2026-05-01',
      'hora': '10:30',
    },
    {
      'tipo': 'Salida',
      'producto': 'Coca Cola 500ml',
      'cantidad': 10,
      'referencia': 'PED-2026-0042',
      'fecha': '2026-05-02',
      'hora': '14:45',
    },
    {
      'tipo': 'Entrada',
      'producto': 'Detergente Industrial',
      'cantidad': 25,
      'referencia': 'FACT-001-00002',
      'fecha': '2026-05-02',
      'hora': '09:15',
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
      rutaActual: NombresRutas.almacen,
      cuerpo: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Almacén',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HotelPMSColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Movimientos de inventario',
                style: TextStyle(
                  fontSize: 14,
                  color: HotelPMSColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 24),

              // Buscador
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
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

              // Filtro de Movimientos
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
                  value: _tipoMovimientoSeleccionado,
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
                        _tipoMovimientoSeleccionado = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'todos',
                      child: Text('Todos los movimientos'),
                    ),
                    DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                    DropdownMenuItem(value: 'salida', child: Text('Salida')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tabla de Movimientos
              _buildTablaMovimientos(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaMovimientos() {
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
          dataRowHeight: 60,
          columns: const [
            DataColumn(
              label: Text(
                'TIPO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
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
                'CANTIDAD',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'REFERENCIA',
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
                'HORA',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          rows: movimientos
              .map(
                (movimiento) => DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: movimiento['tipo'] == 'Entrada'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movimiento['tipo'],
                          style: TextStyle(
                            color: movimiento['tipo'] == 'Entrada'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        movimiento['producto'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        movimiento['cantidad'].toString(),
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        movimiento['referencia'],
                        style: const TextStyle(
                          color: HotelPMSColors.naranjaAcento,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        movimiento['fecha'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        movimiento['hora'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
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
