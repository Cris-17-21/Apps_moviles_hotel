import 'package:flutter/material.dart';

import '../../../../general/layout/layout_principal.dart';
import '../../../../general/tema/colores_tema.dart';
import '../../../../general/tema/estilos_texto.dart';
import '../../../../rutas/nombres_rutas.dart';
import 'servicios/compras_service.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  List<Map<String, dynamic>> _compras = [];
  List<Map<String, dynamic>> _comprasFiltradas = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCompras();
    _searchController.addListener(_filtrarCompras);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarCompras() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ComprasService.obtenerCompras();
      setState(() {
        _compras = data;
        _comprasFiltradas = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'No se pudieron cargar las compras. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _filtrarCompras() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _comprasFiltradas = _compras;
      } else {
        _comprasFiltradas = _compras.where((c) {
          final factura =
              (c['num_comprobante'] ?? '').toString().toLowerCase();
          final proveedor =
              (c['proveedor'] is Map ? c['proveedor']['nombre_proveedor'] ?? '' : '')
                  .toString()
                  .toLowerCase();
          final fecha =
              (c['fecha_compra'] ?? '').toString().toLowerCase();
          return factura.contains(query) ||
              proveedor.contains(query) ||
              fecha.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> compra) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HotelPMSColors.fondoTarjeta,
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: HotelPMSColors.textoPrincipal),
        ),
        content: Text(
          '¿Está seguro de eliminar la compra '
          '"${compra['num_comprobante'] ?? ''}"?',
          style: const TextStyle(color: HotelPMSColors.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: HotelPMSColors.textoSecundario),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: HotelPMSColors.textoEliminar),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ComprasService.eliminarCompra(compra['id_compra']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra eliminada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _cargarCompras();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar compra: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _extractProveedorNombre(Map<String, dynamic> compra) {
    final proveedor = compra['proveedor'];
    if (proveedor is Map) {
      return (proveedor['nombre_proveedor'] ?? '').toString();
    }
    return proveedor?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutPrincipal(
      tituloBarra: 'Compras / Lista',
      rutaActual: NombresRutas.comprasLista,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, NombresRutas.comprasNueva);
        },
        backgroundColor: HotelPMSColors.naranjaAcento,
        foregroundColor: HotelPMSColors.textoPrincipal,
        tooltip: 'Nueva Compra',
        child: const Icon(Icons.add),
      ),
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: HotelPMSColors.naranjaAcento,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text('Compras',
                    style: HotelPMSTextStyles.tituloDashboard),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Lista de órdenes de compra',
              style: HotelPMSTextStyles.subtituloGris,
            ),
            const SizedBox(height: 20),

            // Barra de Búsqueda
            Container(
              decoration: BoxDecoration(
                color: HotelPMSColors.fondoInput,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style:
                    const TextStyle(color: HotelPMSColors.textoPrincipal),
                decoration: InputDecoration(
                  hintText: 'Buscar por factura, proveedor o fecha...',
                  hintStyle: HotelPMSTextStyles.subtituloGris,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: HotelPMSColors.textoSecundario,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cuerpo dinámico: Loading / Error / Tabla
            Expanded(
              child: _buildCuerpo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuerpo() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: HotelPMSColors.naranjaAcento,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: HotelPMSColors.textoEliminar,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: HotelPMSColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarCompras,
              style: ElevatedButton.styleFrom(
                backgroundColor: HotelPMSColors.naranjaAcento,
                foregroundColor: HotelPMSColors.textoPrincipal,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_comprasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: HotelPMSColors.textoSecundario,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se encontraron compras.',
              style: TextStyle(color: HotelPMSColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, NombresRutas.comprasNueva);
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva Compra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HotelPMSColors.naranjaAcento,
                foregroundColor: HotelPMSColors.textoPrincipal,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarCompras,
      color: HotelPMSColors.naranjaAcento,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(HotelPMSColors.fondoOscuro),
                headingRowHeight: 48,
                dataRowHeight: 60,
                columns: const [
                  DataColumn(
                    label: Text(
                      'N° FACTURA',
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
                rows: _comprasFiltradas.map((compra) {
                  final factura = compra['num_comprobante'] ?? '';
                  final proveedorNombre = _extractProveedorNombre(compra);
                  final fecha = compra['fecha_compra'] ?? '';
                  final total = compra['total_compra'] ?? 0;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          factura.toString(),
                          style: const TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          proveedorNombre,
                          style: const TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          fecha.toString(),
                          style: const TextStyle(
                            color: HotelPMSColors.textoPrincipal,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'S/. ${(total is num ? total : 0).toStringAsFixed(2)}',
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
                                // TODO: Ver detalle de compra
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outlined,
                                color: HotelPMSColors.textoEliminar,
                                size: 18,
                              ),
                              onPressed: () =>
                                  _confirmarEliminacion(compra),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
