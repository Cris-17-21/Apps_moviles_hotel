import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../general/tema/colores_tema.dart';
import '../servicios/reportes_service.dart';

/// Column definition for the report results table.
class ColumnaReporte {
  final String titulo;
  final String campo;
  final bool esNumerico;
  final String? Function(dynamic)? formatear;

  const ColumnaReporte({
    required this.titulo,
    required this.campo,
    this.esNumerico = false,
    this.formatear,
  });
}

/// Generic page to display report results.
class PaginaResultadoReporte extends StatefulWidget {
  final String titulo;
  final Future<List<Map<String, dynamic>>> Function() fetchData;
  final List<ColumnaReporte> columnas;
  final bool mostrarTotales;
  final String? urlPDF;
  final String? urlExcel;

  const PaginaResultadoReporte({
    super.key,
    required this.titulo,
    required this.fetchData,
    required this.columnas,
    this.mostrarTotales = false,
    this.urlPDF,
    this.urlExcel,
  });

  @override
  State<PaginaResultadoReporte> createState() => _PaginaResultadoReporteState();
}

class _PaginaResultadoReporteState extends State<PaginaResultadoReporte> {
  List<Map<String, dynamic>>? _datos;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await widget.fetchData();
      if (!mounted) return;
      setState(() {
        _datos = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar los datos. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  Future<void> _descargar(String tipo, String url) async {
    setState(() => _isDownloading = true);
    try {
      final bytes = tipo == 'pdf'
          ? await ReportesService.descargarPDF(url)
          : await ReportesService.descargarExcel(url);
      if (!mounted) return;

      // Save to temp directory and share
      final dir = await getTemporaryDirectory();
      final extension = tipo == 'pdf' ? 'pdf' : 'xlsx';
      final file = File(
          '${dir.path}/reporte_${DateTime.now().millisecondsSinceEpoch}.$extension');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)],
          text: '${widget.titulo} - $tipo');

      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte $tipo descargado'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Calculate totals for numeric columns.
  Map<String, double> _calcularTotales() {
    final totals = <String, double>{};
    if (_datos == null || _datos!.isEmpty) return totals;

    for (final col in widget.columnas) {
      if (col.esNumerico) {
        double sum = 0;
        for (final row in _datos!) {
          final val = row[col.campo];
          if (val is num) {
            sum += val.toDouble();
          } else if (val is String) {
            sum += double.tryParse(val) ?? 0;
          }
        }
        totals[col.campo] = sum;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HotelPMSColors.fondoPrincipal,
      appBar: AppBar(
        backgroundColor: HotelPMSColors.fondoOscuro,
        title: Text(widget.titulo,
            style: const TextStyle(color: HotelPMSColors.textoPrincipal)),
        iconTheme: const IconThemeData(color: HotelPMSColors.textoPrincipal),
        actions: [
          if (widget.urlPDF != null)
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: HotelPMSColors.naranjaAcento,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf,
                      color: HotelPMSColors.textoEliminar),
              onPressed: _isDownloading
                  ? null
                  : () => _descargar('pdf', widget.urlPDF!),
              tooltip: 'Descargar PDF',
            ),
          if (widget.urlExcel != null)
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: HotelPMSColors.naranjaAcento,
                      ),
                    )
                  : const Icon(Icons.table_chart_outlined,
                      color: HotelPMSColors.naranjaAcento),
              onPressed: _isDownloading
                  ? null
                  : () => _descargar('excel', widget.urlExcel!),
              tooltip: 'Descargar Excel',
            ),
        ],
      ),
      body: _buildCuerpo(),
    );
  }

  Widget _buildCuerpo() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: HotelPMSColors.naranjaAcento),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: HotelPMSColors.textoEliminar, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: HotelPMSColors.textoSecundario)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDatos,
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

    if (_datos == null || _datos!.isEmpty) {
      return const Center(
        child: Text('No se encontraron datos para el período seleccionado.',
            style: TextStyle(color: HotelPMSColors.textoSecundario)),
      );
    }

    final totals = widget.mostrarTotales ? _calcularTotales() : null;

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: HotelPMSColors.naranjaAcento,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(HotelPMSColors.fondoOscuro),
          headingRowHeight: 48,
          dataRowHeight: 60,
          columns: widget.columnas
              .map((col) => DataColumn(
                    label: Text(
                      col.titulo,
                      style: const TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    numeric: col.esNumerico,
                  ))
              .toList(),
          rows: [
            ..._datos!.map((fila) {
              return DataRow(
                cells: widget.columnas.map((col) {
                  final rawValue = fila[col.campo];
                  final displayValue = col.formatear != null
                      ? col.formatear!(rawValue) ?? ''
                      : rawValue?.toString() ?? '';

                  return DataCell(
                    Text(
                      displayValue,
                      style: TextStyle(
                        color: HotelPMSColors.textoPrincipal,
                        fontWeight: col.esNumerico
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            // Totals row
            if (totals != null)
              DataRow(
                color: WidgetStateProperty.all(
                    HotelPMSColors.naranjaAcento.withValues(alpha: 0.15)),
                cells: widget.columnas.map((col) {
                  if (col.esNumerico && totals.containsKey(col.campo)) {
                    final total = totals[col.campo]!;
                    return DataCell(
                      Text(
                        total.toStringAsFixed(2),
                        style: const TextStyle(
                          color: HotelPMSColors.textoPrincipal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const DataCell(Text(''));
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
