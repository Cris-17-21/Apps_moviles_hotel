# Specification: Room CRUD

## Metadata
* **Capability Name:** room-crud
* **Type:** New / Modified
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability connects the static rooms dashboard in the Flutter application (`pagina_habitaciones.dart`) to the Java Spring Boot backend, replacing mock rooms with live database entities. It also populates the room registration/edit forms using real-time dynamic catalogs (Branches, Floors, and Room Types) and handles database referential integrity violations gracefully when attempting to delete rooms linked to active reservations or check-ins.

## Requirements

### 1. REST Endpoints & Data Model
The Flutter client MUST communicate with the following Java backend endpoints:
* **GET `/cerro-verde/recepcion/habitaciones`**: Lists all rooms in the system.
* **POST `/cerro-verde/recepcion/habitaciones`**: Creates a new room.
* **PUT `/cerro-verde/recepcion/habitaciones/{id}`**: Updates an existing room.
* **DELETE `/cerro-verde/recepcion/habitaciones/eliminar/{id}`**: Deletes a room.

The JSON payload structure for rooms MUST match the `Habitaciones` entity:
```json
{
  "id_habitacion": 1,
  "numero": 101,
  "estado_habitacion": "Disponible",
  "estado": 1,
  "sucursal": { "id": 1, "ciudad": "Tarapoto" },
  "piso": { "id_piso": 1, "numero": 1 },
  "tipo_habitacion": { "id_tipo_habitacion": 1, "nombre": "Simple", "precio": 80.0 }
}
```
*Note: `estado_habitacion` must be one of: `Disponible`, `Reservada`, `Limpieza`, `Ocupada`.*

### 2. Dynamic Selection Catalogs
To populate the room registration and modification forms, the app MUST query these reference feeds dynamically:
* **GET `/cerro-verde/sucursales`**: Lists all Branches (*Sucursales*).
* **GET `/cerro-verde/recepcion/pisos`**: Lists all Floors (*Pisos*).
* **GET `/cerro-verde/recepcion/habitaciones/tipo`**: Lists all Room Types (*Tipos de Habitación*).

Forms MUST dynamically fetch and populate these options upon opening, ensuring that the selected objects are sent as nested objects in the POST/PUT requests.

### 3. Graceful Deletion Guarding
When attempting to delete a room using the `DELETE` endpoint:
* If the backend returns a database constraint violation (e.g. HTTP 409 Conflict, or HTTP 500 containing foreign key errors), the Flutter app MUST catch this exception.
* Instead of crashing or failing silently, the UI MUST display a friendly `AlertDialog` explaining that the room cannot be deleted because it has active or historical reservation/cleaning history linked to it.

---

## Scenarios

### Scenario 1: Fetch and List Rooms Dynamically
* **Given** the user is on the Rooms dashboard (`pagina_habitaciones.dart`),
* **And** the backend has rooms configured in the database,
* **When** the page initializes,
* **Then** the application MUST send a `GET` request to `/cerro-verde/recepcion/habitaciones`,
* **And** the UI MUST display a loading indicator,
* **And** upon a successful response, the loading indicator MUST be replaced by a grid of rooms displaying each room's number, type, floor, price, and status.

### Scenario 2: Create a Room with Dynamic Selection Catalogs
* **Given** the user has opened the "Nueva Habitación" modal dialog,
* **When** the dialog initializes,
* **Then** the app MUST fetch data from `/cerro-verde/sucursales`, `/cerro-verde/recepcion/pisos`, and `/cerro-verde/recepcion/habitaciones/tipo` concurrently,
* **And** populates the respective Dropdown fields with these dynamic options,
* **When** the user inputs room number `204`, selects Branch `Tarapoto`, Floor `Piso 2`, and Room Type `Matrimonial`, and submits,
* **Then** the app MUST send a `POST` request to `/cerro-verde/recepcion/habitaciones` with the mapped body,
* **And** upon a successful `200 OK` or `201 Created` response, the dialog MUST close, and the rooms grid MUST reload to show the newly added room.

### Scenario 3: Edit Room Details
* **Given** the user has selected a room to modify,
* **When** the edit modal opens, the fields are pre-populated with the current room details,
* **And** the user modifies the room number to `204-A` and selects a different room type,
* **And** submits the form,
* **Then** the app MUST send a `PUT` request to `/cerro-verde/recepcion/habitaciones/{id}` with the modified payload,
* **And** upon success, the dialog closes, and the grid updates with the edited information.

### Scenario 4: Delete a Room with Database Violations (Graceful Catching)
* **Given** a room with ID `101` is associated with historical reservations in the database,
* **When** the user clicks the delete button for room `101` and confirms deletion,
* **Then** the app MUST submit a `DELETE` request to `/cerro-verde/recepcion/habitaciones/eliminar/101`,
* **And** the backend returns a database referential integrity error (e.g. HTTP 409, 500, or network level error),
* **Then** the app MUST catch the error,
* **And** the app MUST present an Alert Dialog to the user with the message: *"No se puede eliminar la habitación. Existen registros históricos de reservas o limpiezas asociados a esta habitación."*
* **And** the room MUST NOT be removed from the grid.
