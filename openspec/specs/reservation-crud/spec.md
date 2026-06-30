# Specification: Reservation CRUD

## Metadata
* **Capability Name:** reservation-crud
* **Type:** New / Modified
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability connects the reservation dashboard (`pagina_reservas.dart`) and the step-by-step reservation wizard modal in the Flutter application to the Java Spring Boot backend. It includes fetching dynamic lists of active reservations, creating new reservations (including linking clients and rooms), editing existing reservation details, logically deleting reservations, and cancelling them.

## Requirements

### 1. REST Endpoints & Data Model
The Flutter client MUST communicate with the following Java backend endpoints:
* **GET `/cerro-verde/recepcion/reservas`**: Fetch list of all reservations.
* **POST `/cerro-verde/recepcion/reservas`**: Create a new reservation. Returns HTTP 201 Created on success.
* **PUT `/cerro-verde/recepcion/reservas/{id}`**: Modify an existing reservation.
* **DELETE `/cerro-verde/recepcion/reservas/eliminar/{id}`**: Logically delete a reservation.
* **PUT `/cerro-verde/recepcion/cancelar/{id}`**: Cancel a reservation status directly.

The JSON payload structure for reservations MUST match the `Reservas` entity:
```json
{
  "id_reserva": 1,
  "fecha_inicio": "2026-06-30T12:00:00Z",
  "fecha_fin": "2026-07-02T12:00:00Z",
  "estado_reserva": "Pendiente",
  "comentarios": "Vista al jardín",
  "nro_persona": 2,
  "estado": 1,
  "tipo": "habitacion",
  "sucursal": { "id": 1, "ciudad": "Tarapoto" },
  "cliente": { "idCliente": 1, "dniRuc": "47382910", "nombre": "Juan Pérez", "telefono": "987654321" },
  "habitacionesXReserva": [
    {
      "precio_reserva": 80.0,
      "habitacion": { "id_habitacion": 1, "numero": 101 }
    }
  ]
}
```

### 2. Step-by-Step Wizard Dynamic Feeds
When opening the Reservation wizard, the app MUST dynamically populate options from:
* **Branches:** GET `/cerro-verde/sucursales`
* **Customers:** GET `/cerro-verde/clientes` (Allows searching/selecting from registered clients)
* **Rooms:** GET `/cerro-verde/recepcion/habitaciones` (Used to select available rooms for the reservation dates)

---

## Scenarios

### Scenario 1: Fetch and Render Reservations
* **Given** the user navigates to the Reservations dashboard,
* **When** the page loads,
* **Then** the application MUST query `GET /cerro-verde/recepcion/reservas`,
* **And** display a list of all active reservations showing the Client Name, Status (Check-in, Pagada, Pendiente, Cancelada), Check-in/out Dates, Room Numbers, and Total Cost.

### Scenario 2: Create a Reservation using the Wizard
* **Given** the user opens the "Nueva Reserva" wizard,
* **When** selecting a branch and dates,
* **Then** the wizard MUST retrieve branches from `/cerro-verde/sucursales` and available rooms from `/cerro-verde/recepcion/habitaciones`,
* **When** selecting/searching for a client,
* **Then** the wizard retrieves client profiles from `/cerro-verde/clientes`,
* **When** the user inputs comments, guests number, selects rooms, and clicks "Confirmar",
* **Then** the app MUST send a `POST` request to `/cerro-verde/recepcion/reservas` containing the JSON payload,
* **And** upon receiving an HTTP 201 Created response, the wizard MUST close, and the list reloads to include the new reservation.

### Scenario 3: Cancel a Reservation
* **Given** the user is viewing a reservation with status "Pendiente",
* **When** the user selects the "Cancelar" action and confirms,
* **Then** the app MUST send a `PUT` request to `/cerro-verde/recepcion/cancelar/{id}`,
* **And** upon a successful response, the reservation status in the list MUST update to "Cancelada".

### Scenario 4: Delete a Reservation
* **Given** the user wishes to delete a reservation entry,
* **When** the user selects the delete icon and confirms,
* **Then** the app MUST send a `DELETE` request to `/cerro-verde/recepcion/reservas/eliminar/{id}`,
* **And** upon a successful response, the reservation MUST be removed from the UI list (or marked inactive).
