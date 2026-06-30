## Exploration: Connect Reception and Maintenance CRUDs

### Current State
- **Flutter Frontend (`hoteleria_erp/`)**:
  - Currently contains mock/static views for:
    - **Habitaciones (`lib/modulos/recepcion/paginas/pagina_habitaciones.dart`)**: Uses a static grid of mock rooms, mock floor filters, and a static "Nueva Habitación" modal dialog.
    - **Reservas (`lib/modulos/recepcion/paginas/pagina_reservas.dart`)**: Uses a static list of mock reservations, mock client search, and a mock step-by-step reservation wizard dialog.
    - **Check-in/out (`lib/modulos/recepcion/paginas/pagina_checkin_out.dart`)**: Uses static entries representing check-in/out histories, mock reservation associations, and a static check-in registration modal.
    - **Mantenimiento (`lib/modulos/mantenimiento/paginas/pagina_mantenimiento.dart`)**: Employs a single mock array combining cleaning and incident tasks with simplified fields (`tipo`, `estado`, `titulo`, `descripcion`, `responsable`, `fecha`).
- **Spring Boot Backend (`backend-sistema-integral-cerro-verde/`)**:
  - Formally defines controllers, JPA repositories, services, and entities for all reception and maintenance features.
  - Endpoints utilize Jackson annotations (e.g. `@JsonManagedReference`, `@JsonBackReference`, `@JsonIgnore`) to manage bi-directional relationships (such as room-to-reserva and reservation-to-items) without looping.
  - Database entities use default auto-increment primary keys mapping to local MySQL tables.

---

### Determined REST APIs

The following endpoints from the Java backend controllers MUST be integrated into the Flutter app:

#### 1. Reception (Recepción)
* **Habitaciones (`HabitacionController`)**
  * `GET /cerro-verde/recepcion/habitaciones` - List all rooms.
  * `GET /cerro-verde/recepcion/habitaciones/{id}` - Fetch single room.
  * `POST /cerro-verde/recepcion/habitaciones` - Save new room.
  * `PUT /cerro-verde/recepcion/habitaciones/{id}` - Update room details (ensure URL ID is assigned to entity body).
  * `DELETE /cerro-verde/recepcion/habitaciones/eliminar/{id}` - Hard-delete a room.
* **Reservas (`ReservaController`)**
  * `GET /cerro-verde/recepcion/reservas` - List all reservations.
  * `GET /cerro-verde/recepcion/reservas/{id}` - Fetch single reservation details.
  * `POST /cerro-verde/recepcion/reservas` - Create a reservation (returns 201 Created).
  * `PUT /cerro-verde/recepcion/reservas/{id}` - Update reservation details.
  * `DELETE /cerro-verde/recepcion/reservas/eliminar/{id}` - Logically delete a reservation and clear associated relations.
  * `PUT /cancelar/{id}` - Cancel reservation status.
* **Check-in/out (`CheckController`)**
  * `GET /cerro-verde/recepcion/checks` - List all check records.
  * `GET /cerro-verde/recepcion/checks/{id}` - Fetch single check.
  * `POST /cerro-verde/recepcion/checks` - Perform check-in (starts check session).
  * `PUT /cerro-verde/recepcion/checks/{id}` - Perform check-out or edit dates.
  * `DELETE /cerro-verde/recepcion/checks/eliminar/{id}` - Delete check session.
* **Huéspedes (`HuespedController`)**
  * `GET /cerro-verde/recepcion/huespedes` - List all registered guests.
  * `GET /cerro-verde/recepcion/huespedes/{id}` - Get guest details.
  * `POST /cerro-verde/recepcion/huespedes` - Link client as guest to a specific room reservation.
  * `DELETE /cerro-verde/recepcion/huespedes/eliminar/{id}` - Unlink guest.

#### 2. Maintenance (Mantenimiento)
* **Limpiezas (`LimpiezasController`)**
  * `GET /cerro-verde/limpiezas/ver` - List all cleaning tasks.
  * `GET /cerro-verde/limpiezas/limpiezas/{id}` - Get cleaning task details.
  * `POST /cerro-verde/limpiezas/registrar` - Register new cleaning task.
  * `PUT /cerro-verde/limpiezas/actualizar/{id}` - Update cleaning task details/status.
  * `DELETE /cerro-verde/limpiezas/eliminar/{id}` - Logical delete of cleaning task.
* **Incidencias (`IncidenciasController`)**
  * `GET /cerro-verde/incidencias/ver` - List all hotel incidents.
  * `GET /cerro-verde/incidencias/incidencias/{id}` - Get incident details.
  * `POST /cerro-verde/incidencias/registrar` - Create incident (defaults to "pendiente", fires SMS notification).
  * `PUT /cerro-verde/incidencias/actualizar/{id}` - Update incident status, severity, or resolution comments.
  * `DELETE /cerro-verde/incidencias/eliminar/{id}` - Logical delete of incident.

---

### Determined Models (Data Transfer Structure)

To consume the raw JSON from `ApiClient` calls, the frontend will map objects to these nested model structures:

1. **`HabitacionModel`**
   ```json
   {
     "id_habitacion": int,
     "numero": int,
     "estado_habitacion": "Disponible | Reservada | Limpieza | Ocupada",
     "estado": int,
     "sucursal": { "id_sucursal": int, "nombre": String },
     "piso": { "id_piso": int, "numero": int },
     "tipo_habitacion": { "id_tipo_habitacion": int, "nombre": String, "precio": double }
   }
   ```
2. **`ReservaModel`**
   ```json
   {
     "id_reserva": int,
     "fecha_inicio": "ISO-8601-String",
     "fecha_fin": "ISO-8601-String",
     "estado_reserva": "Check-in | Pagada | Pendiente | Cancelada",
     "comentarios": String,
     "nro_persona": int,
     "estado": int,
     "tipo": "habitacion | salon",
     "sucursal": { "id_sucursal": int, "nombre": String },
     "cliente": { "idCliente": int, "dniRuc": String, "nombre": String, "telefono": String },
     "habitacionesXReserva": [
       {
         "id_hab_reserv": int,
         "precio_reserva": double,
         "habitacion": { "id_habitacion": int, "numero": int }
       }
     ]
   }
   ```
3. **`CheckinCheckoutModel`**
   ```json
   {
     "id_check": int,
     "fecha_checkin": "ISO-8601-String",
     "fecha_checkout": "ISO-8601-String | null",
     "estado": int,
     "sucursal": { "id_sucursal": int },
     "reserva": { "id_reserva": int, "estado_reserva": String }
   }
   ```
4. **`HuespedModel`**
   ```json
   {
     "id_huesped": int,
     "habres": { "id_hab_reserv": int, "precio_reserva": double },
     "cliente": { "idCliente": int, "dniRuc": String, "nombre": String },
     "estado": int
   }
   ```
5. **`LimpiezaModel`**
   ```json
   {
     "id_limpieza": int,
     "fecha_registro": "ISO-8601-String",
     "fecha_solucion": "ISO-8601-String | null",
     "observaciones": String,
     "estado_limpieza": "Pendiente | En Proceso | Completado",
     "estado": int,
     "personal": { "id_personal_limpieza": int, "nombres": String },
     "habitacion": { "id_habitacion": int, "numero": int }
   }
   ```
6. **`IncidenciaModel`**
   ```json
   {
     "id_incidencia": int,
     "fecha_registro": "ISO-8601-String",
     "fecha_solucion": "ISO-8601-String | null",
     "estado_incidencia": "pendiente | en proceso | resuelta",
     "descripcion": String,
     "gravedad": "baja | media | alta",
     "observaciones_solucion": String,
     "estado": int,
     "sucursal": { "id_sucursal": int },
     "habitacion": { "id_habitacion": int, "numero": int },
     "tipoIncidencia": { "id_tipo_incidencia": int, "nombre": String },
     "area": { "id_area": int, "nombre": String }
   }
   ```

---

### Affected Areas
- **`hoteleria_erp/lib/modulos/recepcion/paginas/`**
  - `pagina_habitaciones.dart` - Implement loading state, API fetches, and form submits.
  - `pagina_reservas.dart` - Wire up wizard modal to submit reservation payloads.
  - `pagina_checkin_out.dart` - Wire checkin forms and checkout buttons.
- **`hoteleria_erp/lib/modulos/mantenimiento/paginas/`**
  - `pagina_mantenimiento.dart` - Fetch both limpiezas and incidencias, compile a sorted unified list, and bind status updating dialogs to the PUT endpoints.
- **`hoteleria_erp/lib/modulos/recepcion/servicios/`**
  - Add services to wrap API requests: `habitacion_service.dart`, `reserva_service.dart`, `check_service.dart`, `huesped_service.dart`.
- **`hoteleria_erp/lib/modulos/mantenimiento/servicios/`**
  - Add `mantenimiento_service.dart` to handle fetching, creating, and updating Limpiezas & Incidencias.

---

### Approaches

#### Approach 1: Plain Map JSON Decoders with Local State Fetching
- Keep Flutter services returning `List<Map<String, dynamic>>` or `Map<String, dynamic>`, matching existing app patterns. Retrieve entity structures dynamically and update screen states directly.
- **Pros**: Matches style of `UsuarioService` and `PosService`. No extra dependencies or boilerplate required. Highly flexible.
- **Cons**: Lack of strict type-safety, which can lead to runtime issues if keys change.
- **Effort**: Low-Medium

#### Approach 2: Fully-Typed Serialization Models with a State Management Provider
- Implement full deserialization with class helpers (`fromMap()`, `toMap()`) for every object, and utilize state management packages (like Provider/Riverpod) to synchronize updates.
- **Pros**: Robust, self-documenting code, compiler checks for field keys.
- **Cons**: High boilerplate for a prototype environment; inconsistent with existing services.
- **Effort**: High

---

### Recommendation
I recommend **Approach 1**. This matches the existing convention established in `UsuarioService.dart` and `PosService.dart`. It keeps the integration clean, directly updates local widget states, and keeps codebase changes localized.

---

### Risks
1. **Datetime String Formats**: JSON date properties utilize local date/time strings or ISO-8601 formatting, which must be carefully decoded to display in user-friendly formats.
2. **Missing Reference Relationships**: Objects like Pisos, TipoHabitacion, Clientes, and PersonalLimpieza must exist in the database before linking. The frontend must query these lists first to populate dropdowns correctly.
3. **Circular JSON references**: Bi-directional Java references will fail serialization if missing JSON annotation guards. The explore pass confirmed that correct reference markings are already in place on the backend.

### Ready for Proposal
Yes
