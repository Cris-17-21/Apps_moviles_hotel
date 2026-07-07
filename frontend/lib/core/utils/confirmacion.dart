import 'package:flutter/material.dart';
import '../../general/tema/colores_tema.dart';

/// Muestra un diálogo de confirmación y ejecuta [onConfirm] si el usuario acepta.
///
/// Útil para operaciones de crear, editar y eliminar registros.
Future<bool> mostrarConfirmacion({
  required BuildContext context,
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Confirmar',
  String textoCancelar = 'Cancelar',
  IconData icono = Icons.warning_amber_rounded,
  Color? colorConfirmar,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: HotelPMSColors.fondoTarjeta,
      title: Row(
        children: [
          Icon(icono, size: 28, color: colorConfirmar ?? HotelPMSColors.naranjaAcento),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              titulo,
              style: const TextStyle(color: HotelPMSColors.textoPrincipal),
            ),
          ),
        ],
      ),
      content: Text(
        mensaje,
        style: const TextStyle(color: HotelPMSColors.textoSecundario, fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            textoCancelar,
            style: const TextStyle(color: HotelPMSColors.textoSecundario),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorConfirmar ?? HotelPMSColors.naranjaAcento,
            foregroundColor: HotelPMSColors.textoPrincipal,
          ),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );

  return confirmado == true;
}

/// Muestra un diálogo genérico para operaciones de creación.
Future<bool> confirmarCreacion(
  BuildContext context, {
  required String tipoRegistro,
  String? detalle,
}) {
  return mostrarConfirmacion(
    context: context,
    titulo: 'Confirmar registro',
    mensaje: '¿Está seguro de registrar un nuevo $tipoRegistro${detalle != null ? ':\n$detalle' : ''}?',
    textoConfirmar: 'Guardar',
    icono: Icons.add_circle_outline,
    colorConfirmar: Colors.green,
  );
}

/// Muestra un diálogo genérico para operaciones de edición.
Future<bool> confirmarEdicion(
  BuildContext context, {
  required String tipoRegistro,
  String? nombre,
}) {
  return mostrarConfirmacion(
    context: context,
    titulo: 'Confirmar cambios',
    mensaje: '¿Está seguro de guardar los cambios en $tipoRegistro${nombre != null ? ' "$nombre"' : ''}?',
    textoConfirmar: 'Guardar cambios',
    icono: Icons.edit_outlined,
    colorConfirmar: HotelPMSColors.naranjaAcento,
  );
}

/// Muestra un diálogo genérico para operaciones de eliminación.
Future<bool> confirmarEliminacion(
  BuildContext context, {
  required String tipoRegistro,
  String? nombre,
}) {
  return mostrarConfirmacion(
    context: context,
    titulo: 'Confirmar eliminación',
    mensaje: '¿Está seguro de eliminar $tipoRegistro${nombre != null ? ' "$nombre"' : ''}?\nEsta acción no se puede deshacer.',
    textoConfirmar: 'Eliminar',
    icono: Icons.delete_outline,
    colorConfirmar: HotelPMSColors.textoEliminar,
  );
}

/// Muestra un SnackBar de operación exitosa.
void mostrarExito(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Muestra un SnackBar de error.
void mostrarError(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Muestra un SnackBar de error con mensaje de excepción.
void mostrarErrorException(BuildContext context, Object e) {
  mostrarError(context, 'Error: ${e.toString()}');
}
