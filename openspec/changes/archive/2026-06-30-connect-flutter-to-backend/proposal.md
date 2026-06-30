# Proposal: Connect Flutter to Backend

## Intent
The goal of this change is to bridge the Flutter UI prototype (`hoteleria_erp`) with the Spring Boot backend (`backend-sistema-integral-cerro-verde`). This will replace static mock data in the frontend with dynamic HTTP requests, enabling authentication (JWT), user management, POS transactions, and cash register logs.

## Scope
### In Scope
- **Flutter Networking**: Add the standard `http` package and configure a manual constants file (`lib/core/config/constants.dart`) to easily switch between `localhost` (iOS/Web/Simulators) and `10.0.2.2` (Android Emulator).
- **Session Management**: Store JWT tokens using `shared_preferences` in Flutter.
- **UI Integration**: Replace mock data references in pages like `pagina_usuarios.dart`, `pagina_pos.dart`, and `pagina_caja.dart` with API client requests.
- **Backend CORS Policy**: Configure global CORS mappings inside `SecurityConfig.java` to support wildcard origins (`*`) during local development.
- **Controller Adjustments**: Clean up hardcoded `@CrossOrigin("http://localhost:4200")` annotations on `CajaReporteController` and `ReportesVentasController` to support the Flutter frontend.

### Out of Scope
- Migrating to secure hardware storage (e.g. Keychain/Keystore) in this iteration.
- Production CORS origin restrictions (left to deployment environment configurations).
- Automated API client code generation (e.g., using Retrofit/Dio).

## Capabilities
### New Capabilities
- Dynamic backend synchronization for users, cash registers, and sales transactions.
- Automatic session persistence in Flutter using locally cached JWT tokens via `shared_preferences`.

### Modified Capabilities
- Reporting endpoints (`CajaReporteController`, `ReportesVentasController`) are now accessible by clients other than Angular default port 4200.

## Approach
We will proceed with **Approach 1** from the exploration findings (Direct HTTP Integration with Global CORS Configuration):

1. **Flutter HTTP Package Integration**:
   - Add `http` package to `pubspec.yaml`.
   - Create `core/config/constants.dart` for environment variables:
     ```dart
     // Manual switch for dev environments
     const String baseUrl = "http://10.0.2.2:8080"; // Android Emulator
     // const String baseUrl = "http://localhost:8080"; // iOS/Web
     ```
   - Build lightweight client repositories using Dart's standard `http` library.
   - Use `shared_preferences` to persist and retrieve JWT tokens.

2. **Backend Global CORS Configuration**:
   - Update `SecurityConfig.java` to define a global `CorsConfigurationSource` matching `*` for all endpoints.
   - Remove or replace specific controller annotations blocking origins.

## Affected Areas
- `hoteleria_erp/pubspec.yaml`
- `hoteleria_erp/lib/core/config/constants.dart` (new)
- `hoteleria_erp/lib/modulos/...` (various pages making mock calls)
- `backend-sistema-integral-cerro-verde/src/main/resources/application.properties`
- `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/config/SecurityConfig.java`
- `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/controller/reportes/CajaReporteController.java`
- `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/controller/reportes/ReportesVentasController.java`

## Risks & Mitigation
- **CORS blockages during development**: Flutter Web runs on random ports by default. Mitigated by allowing wildcard origins (`*`) in Spring Security configuration.
- **Android loopback vs Localhost**: Devs using Android Emulators may suffer request timeouts if pointing to `localhost`. Mitigated by clearly separating configuration in `constants.dart` and documenting `10.0.2.2`.
- **Insecure JWT Storage**: Storing JWT tokens in plaintext in `shared_preferences` can be a vulnerability in production. Mitigated by restricting it to the development/prototype phase; a secure storage ticket will be created prior to production.

## Rollback Plan
- Revert additions in `pubspec.yaml` and files created in `hoteleria_erp/lib/`.
- Revert changes to backend's `SecurityConfig.java` and controller classes using git.

## Dependencies
- Standard `http` package for Flutter.
- `shared_preferences` package for Flutter.
- MySQL database active with `cerroverde` schema locally.

## Success Criteria
1. Flutter frontend starts successfully and reads configuration without errors.
2. User can authenticate, receive a JWT token, and see it stored in `shared_preferences`.
3. Flutter UI successfully loads data (users, transaction list, reporting data) dynamically from the running Spring Boot backend.
4. CORS requests from Flutter Web or Android Emulator succeed without blocks.
