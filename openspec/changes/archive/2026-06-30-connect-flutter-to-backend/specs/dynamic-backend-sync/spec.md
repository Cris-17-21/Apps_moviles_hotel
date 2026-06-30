# Specification: Dynamic Backend Synchronization

## Metadata
* **Capability Name:** dynamic-backend-sync
* **Type:** New
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability connects the static Flutter prototype (`hoteleria_erp`) to the Spring Boot backend by replacing hardcoded mock lists with real-time HTTP requests. The synchronization covers three primary areas:
1. **Users Management:** Retrieving, creating, and modifying user entities.
2. **Cash Register (Caja):** Checking box status, performing cash opening (apertura), tracking transaction entries/exits, and closing the register.
3. **POS Transactions:** Fetching active products and submitting complete sale payloads (products, pricing, payment details) to the backend database.

## Requirements

### 1. Networking Configurations
* **Base URL Resolution:** The Flutter application MUST resolve the API endpoint from `lib/core/config/constants.dart`. It MUST support switching between `http://10.0.2.2:8080` (Android Emulator loopback) and `http://localhost:8080` (iOS / Web / local simulator targets).
* **Network Client:** The Flutter app SHALL use the standard Dart `http` library to make REST requests.
* **Authentication Headers:** All endpoints (except public/unauthenticated routes) MUST include the `Authorization` header with the format `Bearer <jwt_token>` as specified in the session persistence capability.

### 2. Users Synchronization (`/cerro-verde/usuarios/`)
* **List Users:** The app MUST perform a `GET` request to `/cerro-verde/usuarios/` to load user details on entering `PaginaUsuarios`.
* **State Mapping:** The JSON array returned MUST be mapped to a Flutter model containing: `idUsuario`, `username`, `nombre`, `apellidos`, `email`, `telefono`, `enable`, and `rol` (mapped to its name/description).
* **UI States:** The `PaginaUsuarios` widget MUST display:
  * A loading indicator while fetching users.
  * A user card list upon success.
  * An error dialog or inline warning message upon network or API failures.

### 3. Cash Register (Caja) Synchronization (`/cerro-verde/caja`)
* **Verification:** Upon initializing `PaginaCaja`, the app MUST perform a `GET` request to `/cerro-verde/caja`. 
  * If the response status code is `200 OK`, the app MUST inspect the returned `Cajas` object fields (e.g. `estadoCaja`).
  * If the box is "abierta" (open), the app MUST display the current cash summary (Initial amount, Total revenues, Total expenses, and Current balance) and allow the user to view transactions.
  * If the box is "cerrada" (closed), the app MUST block transactions and display a prompt/modal to open the register.
* **Aperture:**
  * When opening the box, the app MUST display a form to input the starting amount (`montoApertura`).
  * Submitting the form MUST send a `POST` request to `/cerro-verde/caja/aperturar` with a JSON body:
    ```json
    {
      "montoApertura": 500.00
    }
    ```
  * On a successful `200 OK` response, the app MUST transition the UI to the "Open" state and reload the box statistics.
* **Closure:**
  * When closing the box, the user MUST input the physical cash counted (`montoCierre`).
  * Submitting the closure MUST send a `POST` request to `/cerro-verde/caja/cerrar` with a JSON body representing the double value of the closing count.
  * On a successful `200 OK` response, the app MUST transition the UI to the "Closed" state and block further register operations.

### 4. POS / Sales Transactions Synchronization (`/cerro-verde/venta/productos`)
* **Registering Sales:**
  * Upon finishing a purchase in the POS interface, the app MUST send a `POST` request to `/cerro-verde/venta/productos`.
  * The request payload MUST match the Spring Boot `Ventas` schema structure, including nested detail objects (e.g. product ID, quantity, unit price).
  * On success (`200 OK`), the app MUST clear the cart and display a success modal with an option to download the PDF receipt using GET `/cerro-verde/pdf/{id}`.

---

## Scenarios

### Scenario 1: Retrieve and Display Dynamic Users List
* **Given** the user is logged into the Flutter application with a valid session token,
* **And** the Spring Boot backend is running and returning a list of 3 users at `/cerro-verde/usuarios/`,
* **When** the user navigates to the "Seguridad / Usuarios" screen,
* **Then** the application MUST display a loading indicator,
* **And** the application MUST send a `GET` request to `/cerro-verde/usuarios/` with the bearer token,
* **And** once the response is received, the loading indicator MUST disappear,
* **And** the screen MUST render exactly 3 user cards matching the backend data.

### Scenario 2: Initialize Cash Register Page in Closed State
* **Given** the user has a cash register assigned with status `"cerrada"`,
* **When** the user navigates to the "Caja" screen,
* **Then** the app MUST send a `GET` request to `/cerro-verde/caja`,
* **And** upon receiving the status response, the screen MUST disable the "Arqueo" button,
* **And** the screen MUST show an "Aperturar Caja" modal or card prompting the user to enter a starting amount.

### Scenario 3: Successfully Open Cash Register
* **Given** the user's cash register is currently in `"cerrada"` state,
* **And** the user is viewing the "Caja" screen,
* **When** the user inputs a starting amount of `500.00` and clicks the "Aperturar" button,
* **Then** the application MUST send a `POST` request to `/cerro-verde/caja/aperturar` with payload `{"montoApertura": 500.00}`,
* **And** upon receiving a successful response from the backend, the screen MUST reload the cash register status,
* **And** the UI MUST update to reflect the "abierta" state, displaying the initial amount of `S/ 500.00` and enabling transaction tracking.

### Scenario 4: Successfully Close Cash Register
* **Given** the user's cash register is currently in `"abierta"` state,
* **When** the user clicks "Cerrar", inputs the physical cash counted value of `1510.00`, and confirms the closure,
* **Then** the application MUST send a `POST` request to `/cerro-verde/caja/cerrar` with the raw payload `1510.00` (or wrapped JSON equivalent),
* **And** upon receiving a successful response, the app MUST show a confirmation message,
* **And** the UI MUST transition back to the `"cerrada"` state.

### Scenario 5: Submit Sale Transaction from POS
* **Given** the user has added items to the POS shopping cart,
* **And** the total amount of the cart is `S/ 50.00`,
* **When** the user confirms the sale in the UI with a selected payment method,
* **Then** the application MUST submit a `POST` request to `/cerro-verde/venta/productos` with the mapped cart structure,
* **And** upon receiving a successful `200 OK` response with the `ventaId` key, the app MUST empty the shopping cart,
* **And** the app MUST display a success dialog enabling the user to download the generated receipt.
