# Tasks: Connect Flutter to Backend

## Review Workload Forecast

- **Estimated Changed Lines**: ~400-500 lines
- **Budget Risk**: Medium
- **Chained PRs**: No (A single PR for local development is acceptable)

---

## Phase 1: Backend: CORS & Controllers

- [x] **Configure Global CORS in Spring Security**
  - Edit `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/config/SecurityConfig.java`.
  - Add a global `CorsConfigurationSource` bean mapped to all endpoints (`/**`).
  - Configure permitted origins to wildcard `*` (or mirror request origin) for local development to support Flutter Web random ports.
  - Allow methods: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`.
  - Allow headers: `Authorization`, `Content-Type`, `X-Requested-With`, `Accept`.
  - Ensure preflight `OPTIONS` requests bypass authentication checks and return status `200 OK`.

- [x] **Clean up Controller CORS Annotations**
  - Edit `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/controller/reportes/CajaReporteController.java`.
  - Remove `@CrossOrigin(origins = "http://localhost:4200")` or replace with global delegation.
  - Edit `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/controller/reportes/ReportesVentasController.java`.
  - Remove `@CrossOrigin(origins = "http://localhost:4200")` or replace with global delegation.

- [x] **Build & Run Backend**
  - Run the Maven build to ensure zero compile errors.
  - Launch backend-sistema-integral-cerro-verde to run locally on port 8080.
  - Verify DB connection to the local MySQL `cerroverde` schema.

---

## Phase 2: Frontend: Infrastructure/Services

- [x] **Add Pubspec Dependencies**
  - Edit `hoteleria_erp/pubspec.yaml`.
  - Add `http: ^1.2.0` and `shared_preferences: ^2.2.0` in the dependencies section.
  - Run `flutter pub get` and verify dependency installation.

- [x] **Create Network Configuration Constants**
  - Create `hoteleria_erp/lib/core/config/constants.dart`.
  - Define `baseUrl` with a dynamic switcher to support `http://10.0.2.2:8080` (Android emulator loopback) and `http://localhost:8080` (iOS / Web / local simulator targets).

- [x] **Create Session Storage Helper**
  - Create `hoteleria_erp/lib/core/storage/session_storage.dart`.
  - Implement helper methods to write, read, and delete `jwt_token` key from `shared_preferences`.

- [x] **Create Central HTTP client wrapper (`ApiClient`)**
  - Create `hoteleria_erp/lib/core/network/api_client.dart`.
  - Add logic to intercept outgoing requests and append the `Authorization: Bearer <token>` header when a token exists.
  - Add logic to intercept response error codes. If `401 Unauthorized` is returned:
    - Purge token from local storage.
    - Clear application state.
    - Redirect navigation stack immediately to `/login` using the global navigation key.

- [x] **Create Security Domain Services**
  - Create `hoteleria_erp/lib/modulos/seguridad/servicios/auth_service.dart`.
    - Implement login endpoint post wrapper `/cerro-verde/generar-token`.
    - Implement `/cerro-verde/usuario-actual` GET handler to fetch logged user info and roles.
  - Create `hoteleria_erp/lib/modulos/seguridad/servicios/usuario_service.dart`.
    - Implement GET `/cerro-verde/usuarios/` to list all registered users.

- [x] **Create Caja and Sales Services**
  - Create `hoteleria_erp/lib/modulos/caja/servicios/caja_service.dart`.
    - Implement state check GET `/cerro-verde/caja`.
    - Implement open box POST `/cerro-verde/caja/aperturar`.
    - Implement close box POST `/cerro-verde/caja/cerrar`.
    - Implement list transactions GET `/cerro-verde/caja/transacciones`.
    - Implement add movement POST `/cerro-verde/caja/transacciones/guardar`.
  - Create `hoteleria_erp/lib/modulos/ventas/servicios/pos_service.dart`.
    - Implement GET `/cerro-verde/productos`.
    - Implement POST `/cerro-verde/venta/productos` to register sales transactions.

---

## Phase 3: Frontend: UI Wiring

- [x] **Create PaginaLogin Widget**
  - Create `hoteleria_erp/lib/modulos/seguridad/paginas/pagina_login.dart`.
  - Build credential inputs, validate forms, display dynamic progress spinners, and show user-friendly error banners upon authentication failures.
  - On successful login, persist JWT token, fetch user profile details, and route to dashboard.

- [x] **Wire Global Navigator Key & Routes**
  - Edit `hoteleria_erp/lib/app.dart`.
    - Declare a static `final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();`.
    - Inject `navigatorKey` into the `MaterialApp` instance.
    - Define a new route for `NombresRutas.login` referencing `PaginaLogin`.
    - Update `MyApp` constructor to accept `initialRoute` string parameter.

- [x] **Wire App Startup Check**
  - Edit `hoteleria_erp/lib/main.dart`.
    - Update the `main()` method to run asynchronously.
    - Read `jwt_token` from `shared_preferences`.
    - If found, attempt validation against `usuario-actual`. If valid, start `MyApp(initialRoute: NombresRutas.dashboard)`.
    - If not found or invalid, start `MyApp(initialRoute: NombresRutas.login)`.

- [x] **Wire PaginaUsuarios**
  - Edit `hoteleria_erp/lib/modulos/seguridad/paginas/pagina_usuarios.dart`.
  - Replace mock arrays with a stateful widget call to `UsuarioService.obtenerUsuarios()`.
  - Handle asynchronous lifecycle: loading indicators, success cards mapping database users, and error retry indicators.

- [x] **Wire PaginaCaja**
  - Edit `hoteleria_erp/lib/modulos/caja/paginas/pagina_caja.dart`.
  - Fetch register status on page load.
  - Wire state toggling in UI:
    - **Closed state**: Disable cash movements, show prompt overlay to open the caja. Submit aperture starting amount to backend.
    - **Open state**: Display real numerical values for transactions, load dynamic list of movements, allow addition of income/egress transactions, and enable the close register flow.

- [x] **Wire PaginaPOS**
  - Edit `hoteleria_erp/lib/modulos/ventas/paginas/pagina_pos.dart`.
  - Pull products catalog dynamically from backend.
  - Map cart checkout payload structure matching the backend `Ventas` entity requirements.
  - On successful transaction callback: empty cart state and prompt customer download receipt linking to GET `/cerro-verde/pdf/{id}`.

---

## Phase 4: Verification

- [x] **CORS Preflight Check**
  - Make a preflight request manually (using curl/Postman) simulating cross-origin OPTIONS request.
  - Assert the HTTP response is `200 OK` and includes correct CORS headers.

- [x] **App Launch and Persistence Verification**
  - Launch application without local storage token: verify routing defaults to login screen.
  - Perform login with invalid credentials: assert UI displays `"Credenciales inválidas"`.
  - Perform login with valid credentials: assert token saves in preferences and routes to dashboard.
  - Restart the application: verify it boots directly to the dashboard, avoiding login screen.

- [x] **401 Session Expiration Hook Test**
  - Inject an invalid token in preferences manually or mock a 401 response.
  - Trigger any backend query: verify token gets wiped out, and the user is redirected to the login screen with an expiration alert.

- [x] **End-to-End Workflow Verification**
  - **Usuarios Module**: Verify list displays database records correctly.
  - **Caja Module**: Test dynamic status checking, cash opening, transaction record injection, and register closure.
  - **POS Module**: Verify product listings, add items to cart, submit payment, check MySQL db tables (ventas, detalle_venta) update appropriately, and checkout success modal is rendered.
