# Specification: Maintenance Tabs (Cleanings and Incidents)

## Metadata
* **Capability Name:** maintenance-tabs
* **Type:** New / Modified
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability restructures the Maintenance dashboard (`pagina_mantenimiento.dart`) into two distinct tabs: "Limpiezas" (Cleaning tasks) and "Incidencias" (Incidents). Due to differing state machines, status actions, severity configurations, and backend REST endpoints, this separation enables cleaning staff and maintenance engineers to review and update work orders directly from the database.

## Requirements

### 1. REST Endpoints & Data Model
The Flutter client MUST communicate with these endpoints:
* **Cleaning Tasks (Limpiezas):**
  * `GET /cerro-verde/limpiezas/ver`: Fetch all cleaning tasks.
  * `POST /cerro-verde/limpiezas/registrar`: Register a new cleaning task.
  * `PUT /cerro-verde/limpiezas/actualizar/{id}`: Update task status (`Pendiente`, `En Proceso`, `Completado`) or assign staff.
  * `DELETE /cerro-verde/limpiezas/eliminar/{id}`: Logical deletion of cleaning task.
* **Incidents (Incidencias):**
  * `GET /cerro-verde/incidencias/ver`: Fetch all incident reports.
  * `POST /cerro-verde/incidencias/registrar`: Register a new incident. (Fires SMS notification on backend).
  * `PUT /cerro-verde/incidencias/actualizar/{id}`: Update incident status (`pendiente`, `en proceso`, `resuelta`), gravity, or solution comments.
  * `DELETE /cerro-verde/incidencias/eliminar/{id}`: Logical deletion of incident.

### 2. UI Tab Structure
The `PaginaMantenimiento` widget MUST employ a `TabBar` view separating:
* **Tab 1: Limpiezas (Cleaning)**
  * Renders a list of active cleaning assignments.
  * Cards display the target Room or Salon number, Registration Date, Assigned Staff, and current Status (`Pendiente`, `En Proceso`, `Completado`).
  * Features a dialog to update the cleaning status or assign a cleaning staff member from catalog:
    * `GET /cerro-verde/personallimpieza/ver`
* **Tab 2: Incidencias (Incidents)**
  * Renders active incident logs.
  * Cards display the Incident Type, Area or Room affected, Description, Severity/Gravity (`baja`, `media`, `alta`), Resolution comments, and Status (`pendiente`, `en proceso`, `resuelta`).
  * Features an "Add Incident" modal requiring inputs populated from dynamic catalogs:
    * Room list: `GET /cerro-verde/recepcion/habitaciones`
    * Incident Type: `GET /cerro-verde/tipoincidencia/ver`
    * Hotel Area: `GET /cerro-verde/areashotel/ver`

---

## Scenarios

### Scenario 1: Display Separate Lists for Cleaning Tasks and Incidents
* **Given** the user navigates to the Maintenance page (`pagina_mantenimiento.dart`),
* **When** the page loads,
* **Then** the application MUST display two tabs: "Limpiezas" and "Incidencias",
* **When** the user selects the "Limpiezas" tab,
* **Then** the app sends a `GET` request to `/cerro-verde/limpiezas/ver` and lists the active cleaning orders,
* **When** the user selects the "Incidencias" tab,
* **Then** the app sends a `GET` request to `/cerro-verde/incidencias/ver` and lists the active incident records.

### Scenario 2: Update Cleaning Task Status
* **Given** a cleaning task is in `"Pendiente"` status,
* **When** a team leader opens the task, selects status `"En Proceso"`, assigns a cleaning employee fetched from `/cerro-verde/personallimpieza/ver`, and clicks "Actualizar",
* **Then** the app MUST send a `PUT` request to `/cerro-verde/limpiezas/actualizar/{id}` with the modified fields,
* **And** upon success, reload the "Limpiezas" tab to display the updated status and assigned personnel.

### Scenario 3: Create Incident and Trigger SMS Alert
* **Given** the user opens the "Registrar Incidencia" dialog,
* **When** the dialog launches,
* **Then** the app fetches auxiliary catalogs from `/cerro-verde/recepcion/habitaciones`, `/cerro-verde/tipoincidencia/ver`, and `/cerro-verde/areashotel/ver`,
* **When** the user fills out the form selecting Room `205`, Incident Type `Daño eléctrico`, Gravity `alta`, inputs description *"Cortocircuito en enchufe"* and submits,
* **Then** the app MUST send a `POST` request to `/cerro-verde/incidencias/registrar` with the JSON payload,
* **And** the backend MUST save the record in `"pendiente"` state,
* **And** the backend triggers an SMS text message to the administrator alert queue,
* **And** the dialog closes, and the Incidents tab lists the new electrical issue.
