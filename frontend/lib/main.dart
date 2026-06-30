import 'package:flutter/material.dart';
import 'app.dart';
import 'core/storage/session_storage.dart';
import 'modulos/seguridad/servicios/auth_service.dart';
import 'rutas/nombres_rutas.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de arrancar la app
  WidgetsFlutterBinding.ensureInitialized();
  
  String initialRoute = NombresRutas.login;

  try {
    final hasToken = await SessionStorage.hasToken();
    if (hasToken) {
      final success = await AuthService.fetchCurrentUser();
      if (success) {
        initialRoute = NombresRutas.dashboard;
      } else {
        // Si falló pero el token sigue existiendo, fue un error de red (no 401).
        // En ese caso, la especificación dice "MUST NOT delete the cached token".
        // Iniciamos en login pero conservamos el token.
        final tokenStillExists = await SessionStorage.hasToken();
        if (!tokenStillExists) {
          initialRoute = NombresRutas.login;
        }
      }
    }
  } catch (_) {
    initialRoute = NombresRutas.login;
  }

  runApp(MyApp(initialRoute: initialRoute));
}