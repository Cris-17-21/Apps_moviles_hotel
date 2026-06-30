# SDD Proposal: Connect Reception and Maintenance CRUDs

## Intent
Connect the Flutter frontend reception and maintenance modules to the Java Spring Boot backend, replacing static mock views with real-time dynamic CRUD operations.

## Scope

### In Scope
- **Frontend Integration**: Implement REST API communication for Rooms (*Habitaciones*), Reservations (*Reservas*), Check-in/out, Guests (*Huespedes*), Cleaning Tasks (*Limpiezas*), and Incidents (*Incidencias*).
- **Backend Refinement**: Modify `CheckinCheckoutServiceImpl.java` during check-in (`guardar`) to automatically set the status of all rooms associated with the reservation to "Ocupada", making the state machine symmetrical with the check-out flow (which already sets rooms to "Limpieza" and registers pending tasks).
- **UI Restructuring**: Separate the Maintenance screen (`pagina_mantenimiento.dart`) into two distinct tabs: "Limpiezas" (Cleaning) and "Incidencias" (Incidents) to accommodate differing state/severity models and actions.
- **Reference Catalog Feeds**: Dynamically query auxiliary catalogs (Branches, Floors, Room Types, Customers, Cleaning Staff, Incident Types, Areas) from the backend to populate dropdowns dynamically in registration forms.
- **Graceful Error Handling**: Catch referential integrity exceptions (e.g., trying to hard-delete a room that has active/historical reservations) and display descriptive, user-friendly alert dialogs in the Flutter app.

### Out of Scope
- Migrating the app to typed serialization models (Approach 2 from exploration) or implementing new global state management packages (like Provider/Riverpod) for this change. The project will continue to use raw Map JSON decoders (`Map<String, dynamic>`) to align with existing frontend services (`UsuarioService.dart`, `PosService.dart`).
- UI adjustments outside the Reception and Maintenance modules.

## Capabilities

### New Capabilities
- **Automated Check-in Transitions**: Setting a reservation status to "Check-in" automatically updates all linked rooms to "Ocupada" via a single backend transaction.
- **Automated Cleaning Dispatch**: Performing a check-out automatically transitions room states to "Limpieza" and enqueues a pending cleaning task.
- **Divided Maintenance Dashboard**: Distinct tabs to list and update status for Cleanings and Incidents, mapping correctly to their respective REST endpoints.
- **Dynamic Selection Forms**: Forms for creating rooms, reservations, check-ins, and incidents populate their dropdowns via real-time backend list queries.

### Modified Capabilities
- **Room Deletion Warning**: Hard-deletes for rooms are guarded by graceful error catching. If a database foreign key violation occurs, a friendly alert details why the room cannot be deleted.

## Approach
- **Service Integration**: Implement specialized services under `lib/modulos/recepcion/servicios/` and `lib/modulos/mantenimiento/servicios/` using the established `ApiClient` or base HTTP patterns.
- **Data Decoding**: Return raw maps and list of maps (`List<Map<String, dynamic>>`) from the services to local widget state variables to preserve local codebase practices.
- **Symmetric Room State Machine**: Relocate room occupancy state transition on check-in to the Java backend service layer (`CheckinCheckoutServiceImpl.java`) to keep business logic out of the client app.

## Affected Areas
- **Backend**:
  - `backend-sistema-integral-cerro-verde/src/main/java/.../CheckinCheckoutServiceImpl.java` (modify check-in logic to update room status).
- **Frontend Services**:
  - `hoteleria_erp/lib/modulos/recepcion/servicios/habitacion_service.dart`
  - `hoteleria_erp/lib/modulos/recepcion/servicios/reserva_service.dart`
  - `hoteleria_erp/lib/modulos/recepcion/servicios/check_service.dart`
  - `hoteleria_erp/lib/modulos/recepcion/servicios/huesped_service.dart`
  - `hoteleria_erp/lib/modulos/mantenimiento/servicios/mantenimiento_service.dart`
- **Frontend Pages**:
  - `hoteleria_erp/lib/modulos/recepcion/paginas/pagina_habitaciones.dart`
  - `hoteleria_erp/lib/modulos/recepcion/paginas/pagina_reservas.dart`
  - `hoteleria_erp/lib/modulos/recepcion/paginas/pagina_checkin_out.dart`
  - `hoteleria_erp/lib/modulos/mantenimiento/paginas/pagina_mantenimiento.dart`

## Risks
- **Compilation Issues**: Modifying `CheckinCheckoutServiceImpl.java` requires ensuring that related JPA entities and imports compile properly without circular reference errors.
- **Datetime Parsing**: ISO-8601 strings returned by the API (e.g. `fecha_inicio`, `fecha_registro`) must be parsed safely using `DateTime.parse()` to avoid crashes on formatting issues.

## Rollback Plan
- Use git to revert changes:
  - Frontend: `git checkout HEAD -- hoteleria_erp/`
  - Backend: `git checkout HEAD -- backend-sistema-integral-cerro-verde/`
  - Re-run localized builds to restore original static mock flows.

## Dependencies
- Running Spring Boot backend instance with local MySQL database schema containing test branches, floors, customers, and room types.
- Success of backend compilation.

## Success Criteria
1. Users can list, add, edit, and delete rooms, with deletion errors showing a friendly alert dialog when the room is linked to records.
2. Check-in changes the reservation status to "Check-in" and sets associated rooms to "Ocupada" in the database.
3. Check-out sets rooms to "Limpieza" and automatically generates a cleaning task.
4. The Maintenance screen separates cleanings and incidents into two tabs and lets the user update their status dynamically.
5. All selection dropdowns fetch up-to-date data from the backend REST APIs.
