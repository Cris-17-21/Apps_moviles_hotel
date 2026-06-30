# Specification: Check-in / Check-out Synchronization

## Metadata
* **Capability Name:** checkin-checkout-sync
* **Type:** New / Modified
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability handles the synchronization of hotel guest entry (*Check-in*) and exit (*Check-out*) procedures. It coordinates frontend screens and backend transactions so that starting a check-in automatically updates associated room statuses to "Ocupada" in the database, and performing a check-out transitions rooms to "Limpieza" while automatically dispatching a cleaning task to the maintenance queue.

## Requirements

### 1. REST Endpoints & Data Model
The Flutter client MUST communicate with the following Java backend endpoints:
* **GET `/cerro-verde/recepcion/checks`**: List check-in/out records.
* **POST `/cerro-verde/recepcion/checks`**: Perform a check-in (starts a check session).
* **PUT `/cerro-verde/recepcion/checks/{id}`**: Perform a check-out (sends checkout date).
* **DELETE `/cerro-verde/recepcion/checks/eliminar/{id}`**: Delete/cancel a check session.

The JSON payload structure for check sessions:
```json
{
  "id_check": 1,
  "fecha_checkin": "2026-06-30T14:30:00Z",
  "fecha_checkout": null,
  "estado": 1,
  "sucursal": { "id": 1 },
  "reserva": { "id_reserva": 1, "estado_reserva": "Check-in" }
}
```

### 2. Backend Check-in Room State Transitions (Modified)
When executing check-in via `POST /cerro-verde/recepcion/checks`, the backend service `CheckinCheckoutServiceImpl.java`'s `guardar()` method MUST perform the following actions within a single transaction:
1. Retrieve the linked `Reservas` entity.
2. Set the reservation's `estado_reserva` to `"Check-in"`.
3. Query all rooms associated with the reservation (`HabitacionesXReserva`).
4. Loop through each associated room:
   * Transition `estado_habitacion` from `"Reservada"` to `"Ocupada"`.
   * Persist the updated `Habitaciones` entity to the database.
5. Save the check record.

### 3. Backend Check-out Symmetrical Transitions (Existing)
When performing check-out via `PUT /cerro-verde/recepcion/checks/{id}`, the backend service's `modificar()` method MUST:
1. Update `fecha_checkout` to the current timestamp.
2. Retrieve the linked `Reservas` entity and set `estado_reserva` to `"Completada"`.
3. For each associated room:
   * Transition `estado_habitacion` to `"Limpieza"`.
   * Automatically create a new `Limpiezas` entity with `estado_limpieza = "Pendiente"` and `fecha_registro = current_date`.
   * Persist both entities to the database.
4. For each associated salon:
   * Transition `estado_salon` to `"Disponible"`.
   * Automatically create a new `Limpiezas` entity with `estado_limpieza = "Pendiente"`.
   * Persist entities.

---

## Scenarios

### Scenario 1: Retrieve Entry and Exit History in Flutter
* **Given** the user enters the "Check-in / Out" page (`pagina_checkin_out.dart`),
* **When** the page initializes,
* **Then** the application MUST send a `GET` request to `/cerro-verde/recepcion/checks`,
* **And** display a list of all check entries showing the Reservation reference, Guest Name, Room numbers, Check-in timestamp, Check-out timestamp, and overall session status (active vs. completed).

### Scenario 2: Perform Check-in and Update Rooms to Occupied
* **Given** a reservation is in `"Pendiente"` status with associated rooms in `"Reservada"` status,
* **When** the receptionist initiates check-in for the reservation through `ModalNuevoCheckIn` and submits,
* **Then** the application MUST send a `POST` request to `/cerro-verde/recepcion/checks` with the payload linking the reservation,
* **And** the backend database transaction MUST set the reservation status to `"Check-in"`,
* **And** all rooms associated with that reservation MUST have their status set to `"Ocupada"` in the database.

### Scenario 3: Perform Check-out, Set Room to Cleaning, and Dispatch Maintenance
* **Given** a guest is currently checked in with active rooms in `"Ocupada"` status,
* **When** the receptionist clicks the "Check-out" button and confirms,
* **Then** the application MUST send a `PUT` request to `/cerro-verde/recepcion/checks/{id}` with the checkout date-time,
* **And** the backend MUST set the reservation status to `"Completada"`,
* **And** set the associated rooms' status to `"Limpieza"`,
* **And** insert a new row in the `limpiezas` table for each room with status `"Pendiente"` to enqueue it for the cleaning staff.
