/// Converts a date string from DD/MM/YYYY to ISO format (YYYY-MM-DD).
///
/// If the string is already in YYYY-MM-DD format, it is returned as-is.
/// Returns `null` if the input cannot be parsed.
String? aFormatoISO(String fecha) {
  // Already in ISO format: YYYY-MM-DD
  if (fecha.contains('-') && fecha.length == 10) {
    return fecha;
  }

  // Expect DD/MM/YYYY
  final partes = fecha.split('/');
  if (partes.length != 3) return null;

  final dia = partes[0].padLeft(2, '0');
  final mes = partes[1].padLeft(2, '0');
  final anio = partes[2];

  if (anio.length != 4) return null;

  return '$anio-$mes-$dia';
}
