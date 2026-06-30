# Tasks: Connect Reception and Maintenance CRUDs

## Review Workload Forecast

- **Estimated Changed Lines**: ~640-860 lines
  - Backend changes: ~40-60 lines
  - Frontend services: ~200-300 lines
  - Frontend UI wiring: ~400-500 lines
- **Budget Risk**: Medium
- **Chained PRs**: No (A single PR for local development is acceptable)

---

## Phase 1: Backend Changes

- [x] **Implement Check-in Room State Transitions**
  - Edit `backend-sistema-integral-cerro-verde/src/main/java/com/alexander/sistema_cerro_verde_backend/service/recepcion/jpa/CheckinCheckoutServiceImpl.java`.
  - In the `guardar(CheckinCheckout check)` method, add logic to retrieve the reservation and its associated rooms.
  - Set the reservation's `estado_reserva` to `"Check-in"`.
  - Retrieve the associated rooms using `habitacionesReservasRepository.findByReservaId()` (or the corresponding query method).
  - Iterate through the rooms, update their `estado_habitacion` status to `"Ocupada"`, and save them using `habitacionRepository.save()`.
  - Ensure all database changes execute within a transactional boundary.

- [x] **Expose Sucursales REST Endpoint**
  - Create a new REST controller `SucursalesController.java` under `com/alexander/sistema_cerro_verde_backend/controller/`.
  - Implement a `GET /cerro-verde/sucursales` endpoint returning a list of all branches (`Sucursales`).
  - Autowire `SucursalesRepository` to fetch the branches directly from the database.

- [x] **Verify and Rebuild Backend**
  - Run the Maven build to ensure all code compiles with zero errors.
  - Start the backend and verify database connectivity.

---

## Phase 2: Frontend Services & Models

- [x] **Create Room Service**
  - Create `hoteleria_erp/lib/modulos/recepcion/servicios/habitacion_service.dart`.
  - Implement HTTP requests using plain map decoders (`Map<String, dynamic>`):
    - `obtenerHabitaciones()` (`GET /cerro-verde/recepcion/habitaciones`)
    - `guardarHabitacion(Map<String, dynamic> body)` (`POST /cerro-verde/recepcion/habitaciones`)
    - `actualizarHabitacion(int id, Map<String, dynamic> body)` (`PUT /cerro-verde/recepcion/habitaciones/{id}`)
    - `eliminarHabitacion(int id)` (`DELETE /cerro-verde/recepcion/habitaciones/eliminar/{id}`)
  - Implement auxiliary feeds:
    - `obtenerSucursales()` (`GET /cerro-verde/sucursales`)
    - `obtenerPisos()` (`GET /cerro-verde/recepcion/pisos`)
    - `obtenerTiposHabitacion()` (`GET /cerro-verde/recepcion/habitaciones/tipo`)

- [x] **Create Reservation Service**
  - Create `hoteleria_erp/lib/modulos/recepcion/servicios/reserva_service.dart`.
  - Implement HTTP requests:
    - `obtenerReservas()` (`GET /cerro-verde/recepcion/reservas`)
    - `crearReserva(Map<String, dynamic> body)` (`POST /cerro-verde/recepcion/reservas`)
    - `actualizarReserva(int id, Map<String, dynamic> body)` (`PUT /cerro-verde/recepcion/reservas/{id}`)
    - `eliminarReserva(int id)` (`DELETE /cerro-verde/recepcion/reservas/eliminar/{id}`)
    - `cancelarReserva(int id)` (`PUT /cerro-verde/recepcion/cancelar/{id}`)
  - Implement auxiliary feeds:
    - `obtenerClientes()` (`GET /cerro-verde/clientes`)

- [x] **Create Check-in/out Service**
  - Create `hoteleria_erp/lib/modulos/recepcion/servicios/check_service.dart`.
  - Implement HTTP requests:
    - `obtenerChecks()` (`GET /cerro-verde/recepcion/checks`)
    - `realizarCheckIn(Map<String, dynamic> body)` (`POST /cerro-verde/recepcion/checks`)
    - `realizarCheckOut(int id, Map<String, dynamic> body)` (`PUT /cerro-verde/recepcion/checks/{id}`)
    - `eliminarCheck(int id)` (`DELETE /cerro-verde/recepcion/checks/eliminar/{id}`)

- [x] **Create Guest Service**
  - Create `hoteleria_erp/lib/modulos/recepcion/servicios/huesped_service.dart`.
  - Implement endpoints for listing and linking guest entities.

- [x] **Create Maintenance Service**
  - Create `hoteleria_erp/lib/modulos/mantenimiento/servicios/mantenimiento_service.dart`.
  - Implement cleaning task endpoints:
    - `obtenerLimpiezas()` (`GET /cerro-verde/limpiezas/ver`)
    - `registrarLimpieza(Map<String, dynamic> body)` (`POST /cerro-verde/limpiezas/registrar`)
    - `actualizarLimpieza(int id, Map<String, dynamic> body)` (`PUT /cerro-verde/limpiezas/actualizar/{id}`)
    - `eliminarLimpieza(int id)` (`DELETE /cerro-verde/limpiezas/eliminar/{id}`)
    - `obtenerPersonalLimpieza()` (`GET /cerro-verde/personallimpieza/ver`)
  - Implement incident task endpoints:
    - `obtenerIncidencias()` (`GET /cerro-verde/incidencias/ver`)
    - `registrarIncidencia(Map<String, dynamic> body)` (`POST /cerro-verde/incidencias/registrar`)
    - `actualizarIncidencia(int id, Map<String, dynamic> body)` (`PUT /cerro-verde/incidencias/actualizar/{id}`)
    - `eliminarIncidencia(int id)` (`DELETE /cerro-verde/incidencias/eliminar/{id}`)
    - `obtenerTiposIncidencia()` (`GET /cerro-verde/tipoincidencia/ver`)
    - `obtenerAreasHotel()` (`GET /cerro-verde/areashotel/ver`)

---

## Phase 3: Frontend UI Integration

- [x] **Integrate Rooms Screen (`pagina_habitaciones.dart`)**
  - Replace static/mock list with an asynchronous call to `HabitacionService.obtenerHabitaciones()` on `initState` and refresh actions.
  - Display a loading indicator while fetching rooms.
  - In the "Nueva Habitación" and "Editar Habitación" modals, query dynamic lists concurrently for sucursales, pisos, and tipos de habitación to populate the dropdown forms.
  - Map form inputs to nested JSON structures when sending POST/PUT requests.
  - Implement try-catch block for deletion: catch database constraint violations (HTTP 409/500) and trigger a friendly `AlertDialog` detailing why the room cannot be deleted.

- [x] **Integrate Reservations Screen (`pagina_reservas.dart`)**
  - Bind the reservations list to `ReservaService.obtenerReservas()`.
  - Wire the multi-step Reservation Wizard to query branches, clients, and rooms from backend APIs.
  - Bind the "Confirmar" wizard submission to POST to `/recepcion/reservas`.
  - Wire the "Cancelar" row action to PUT to `/recepcion/cancelar/{id}` and update status visually to "Cancelada".
  - Wire the "Eliminar" action to DELETE `/recepcion/reservas/eliminar/{id}`.

- [x] **Integrate Check-in/out Screen (`pagina_checkin_out.dart`)**
  - Bind check entries to `CheckService.obtenerChecks()`.
  - Wire the check-in modal to perform POST request to `/recepcion/checks` with the reservation details.
  - Wire the check-out action to PUT request to `/recepcion/checks/{id}` with the current timestamp.

- [x] **Integrate Maintenance Screen (`pagina_mantenimiento.dart`)**
  - Redesign the dashboard layout to utilize a `TabBar` separating "Limpiezas" (Cleaning) and "Incidencias" (Incidents).
  - **Tab 1: Limpiezas (Cleaning)**:
    - Load task list via `MantenimientoService.obtenerLimpiezas()`.
    - Render cards displaying room/salon, date, assigned staff, and status.
    - Wire status update dialog, loading staff list dynamically from `/personallimpieza/ver`, and submitting update via PUT to `/actualizar/{id}`.
  - **Tab 2: Incidencias (Incidents)**:
    - Load incident log via `MantenimientoService.obtenerIncidencias()`.
    - Render cards displaying details, type, area, severity, status, and resolution comments.
    - Wire "Registrar Incidencia" modal, loading dropdown feeds from `/habitaciones`, `/tipoincidencia/ver`, and `/areashotel/ver`.
    - Submit incident registrations via POST to `/incidencias/registrar`.
    - Wire status updates/resolution comments via PUT to `/incidencias/actualizar/{id}`.

---

## Phase 4: Verification

- [ ] **Backend Integration Verification**
  - Execute API tests simulating check-in via POST to verify reservation is marked as "Check-in" and all rooms update status to "Ocupada" in database.
  - Assert that check-out via PUT triggers status "Completada" on reservation, transitions rooms to "Limpieza", and correctly enqueues a "Pendiente" cleaning task.
  - Assert new `GET /cerro-verde/sucursales` returns correct data.

- [ ] **Frontend Catalog Feeds Verification**
  - Verify that opening forms (New Room, New Reservation, New Incident) correctly fetches and populates all selection menus dynamically without console errors.

- [ ] **Referential Integrity Catch Verification**
  - Verify room deletion guard by attempting to delete a room linked to historical reservations. Check that the UI correctly intercepts the error and displays the descriptive alert dialog.

- [ ] **Maintenance Layout and State Updates Verification**
  - Verify the TabBar displays cleanings and incidents separately.
  - Assert updating a cleaning task status or incident status calls the respective PUT endpoint, and refreshes the lists correctly.
  - Verify registering an incident triggers the backend simulation for SMS alerts.
