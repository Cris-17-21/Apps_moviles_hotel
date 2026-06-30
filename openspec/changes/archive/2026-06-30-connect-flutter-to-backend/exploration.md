## Exploration: Connect Flutter to Backend

### Current State
- **Flutter Frontend (`hoteleria_erp/`)**: Currently a pure UI prototype containing mock data (such as static lists of products, users, transactions) and has no network dependencies or API client implementation (no `http` or `dio` packages in `pubspec.yaml`).
- **Spring Boot Backend (`backend-sistema-integral-cerro-verde/`)**: A layered MVC backend running on default port 8080 (since `server.port` is not configured). Database settings point to a local MySQL schema named `cerroverde` with username `root` and an empty password. Security configuration (`SecurityConfig.java`) uses JWT and supports CORS via `.cors(withDefaults())`. Controller classes mostly utilize `@CrossOrigin("*")`, but some reporting controllers (`CajaReporteController` and `ReportesVentasController`) restrict access with `@CrossOrigin(origins = "http://localhost:4200")`.

### Affected Areas
- `hoteleria_erp/pubspec.yaml` — Needs network dependencies (`http` or `dio`) added.
- `hoteleria_erp/lib/core/config/constants.dart` — Needs to be created to define the API base URL (handling loopbacks like `10.0.2.2` for Android Emulators, `localhost` for iOS simulators/Web, or host LAN IP for physical devices).
- `hoteleria_erp/lib/modulos/...` (various pages like `pagina_usuarios.dart`, `pagina_pos.dart`, `pagina_caja.dart`) — Need to replace local mocks with API calls using the client.
- `backend-sistema-integral-cerro-verde/src/main/resources/application.properties` — Need to verify port availability (port 8080) and database connectivity (`cerroverde` MySQL schema).
- `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/config/SecurityConfig.java` — Define a global `CorsConfigurationSource` to handle wildcard origins or dynamic port mappings safely.
- `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/controller/reportes/CajaReporteController.java` — Needs to adjust `@CrossOrigin` from `http://localhost:4200` to allow access from the Flutter client.
- `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/controller/reportes/ReportesVentasController.java` — Same CORS adjustment as above.

### Approaches
1. **Direct HTTP Integration with Global/Flexible CORS Configuration** — Add `http` package to Flutter, write central API service classes referencing a configurable base URL, and configure a global `CorsConfigurationSource` in Spring Security (`SecurityConfig.java`) or change specific controller restrictions to wildcard/dynamic settings.
   - Pros: Cleans up controller-level CORS definitions; handles all targets (web, android emulator, and physical devices); keeps dependencies minimal using Flutter's standard `http` package.
   - Cons: Requires modifying Java security settings and re-writing mock-based UI widgets in Flutter.
   - Effort: Medium

2. **Controller-level CORS patching + Dio/Retrofit Client** — Keep controller-level `@CrossOrigin` annotations, changing only the restricted ones to target the specific port of the Flutter app, and use `dio` with code-generation/Retrofit for network clients.
   - Pros: Highly typed API client in Flutter; doesn't touch global Java config.
   - Cons: Overkill for this prototype stage; code-generation adds complexity; hardcoded origins on controllers remain fragile.
   - Effort: High

### Recommendation
I recommend **Approach 1**. It is cleaner and more robust for development. Modifying `SecurityConfig.java` to define a global `CorsConfigurationSource` removes the duplicate and hardcoded `http://localhost:4200` annotations on the report controllers, preventing future CORS issues on Web/Mobile targets. Adding the standard `http` package to Flutter is simple, lightweight, and sufficient for fetching data and sending transactions.

### Risks
- **CORS blockages**: Flutter Web run options assign random ports by default, which will trigger CORS failures unless configured dynamically or using wildcards (`*`) during local development.
- **Emulator networking loopback**: Developer might try to use `localhost` inside the Flutter app running on an Android Emulator, which resolves to the emulator itself instead of the host machine (must use `10.0.2.2`).
- **Database schema mismatches**: Spring Boot auto-updates the schema on startup, but the MySQL server must be active and the empty database `cerroverde` must exist first.

### Ready for Proposal
Yes
