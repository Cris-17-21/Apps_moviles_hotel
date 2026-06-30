import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../rutas/nombres_rutas.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({Key? key}) : super(key: key);

  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  final TextEditingController _searchController = TextEditingController();

  // Datos de ejemplo
  final List<Map<String, dynamic>> proveedores = [
    {
      'ruc': '20123456789',
      'razonSocial': 'Distribuidora Norte SAC',
      'direccion': 'Av. Los Pinos 123',
      'telefono': '555-0101',
      'email': 'contacto@norte.com',
    },
    {
      'ruc': '20987654321',
      'razonSocial': 'Alimentos Frescos EIRL',
      'direccion': 'Jr. Comercio 456',
      'telefono': '555-0202',
      'email': 'ventas@frescos.com',
    },
    {
      'ruc': '20555666777',
      'razonSocial': 'Químicos Industriales SpA',
      'direccion': 'Calle Principal 789',
      'telefono': '555-0303',
      'email': 'info@quimicos.com',
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
      rutaActual: NombresRutas.proveedores,
      cuerpo: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Proveedores',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HotelPMSColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Administra tus proveedores',
                style: TextStyle(
                  fontSize: 14,
                  color: HotelPMSColors.textoSecundario,
                ),
              ),
              const SizedBox(height: 24),

              // Botón Nuevo Proveedor
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navegar a formulario de nuevo proveedor
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
                  hintText: 'Buscar por RUC o nombre...',
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

              // Tabla de Proveedores
              _buildTablaProveedores(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaProveedores() {
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
                'RUC',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'RAZÓN SOCIAL',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'DIRECCIÓN',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'TELÉFONO',
                style: TextStyle(
                  color: HotelPMSColors.textoPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'EMAIL',
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
          rows: proveedores
              .map(
                (proveedor) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        proveedor['ruc'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        proveedor['razonSocial'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        proveedor['direccion'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        proveedor['telefono'],
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        proveedor['email'],
                        style: const TextStyle(
                          color: HotelPMSColors.naranjaAcento,
                          fontSize: 12,
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
