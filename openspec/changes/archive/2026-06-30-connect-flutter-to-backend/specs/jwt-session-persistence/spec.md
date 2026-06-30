# Specification: Automatic JWT Session Persistence

## Metadata
* **Capability Name:** jwt-session-persistence
* **Type:** New
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability introduces session management and token persistence in the Flutter mobile application using standard HTTP headers and local caching with the `shared_preferences` package. It enables users to stay logged in across application relaunches without re-entering credentials and handles token invalidation dynamically.

## Requirements

### 1. Storage and Cache
* **Local Persistence:** The Flutter application MUST store the generated JWT token string locally using `shared_preferences`.
* **Storage Key:** The token MUST be stored under the key name `jwt_token`.
* **State Cleansing:** Logging out or encountering an unrecoverable `401 Unauthorized` API response MUST completely remove the `jwt_token` key from `shared_preferences`.

### 2. Startup Authentication Workflow
* **Token Check:** At application startup (`main.dart` / initialization phase), the app MUST check for the presence of the `jwt_token` key.
* **Token Validation:**
  * If the token is NOT found, the app MUST redirect the user to the Login screen.
  * If the token IS found, the app MUST make a `GET` request to `/cerro-verde/usuario-actual` containing the token in the `Authorization` header.
    * If the response status code is `200 OK`, the app MUST load the user's role and details into the global application state and navigate directly to the Dashboard screen, bypassing the Login screen.
    * If the response status code is `401 Unauthorized`, the app MUST purge the cached token and navigate to the Login screen.
    * If the request fails due to a network connection issue, the app SHOULD inform the user of connection problems but MUST NOT delete the cached token.

### 3. Login Workflow
* **Authentication Endpoint:** The Login screen MUST issue a `POST` request to `/cerro-verde/generar-token` with the user's credentials inside a JSON payload:
  ```json
  {
    "username": "...",
    "password": "..."
  }
  ```
* **Success Flow:**
  * On a successful response (`200 OK`), the app MUST parse the `token` value from the JSON payload.
  * The app MUST cache this token in `shared_preferences` under the key `jwt_token`.
  * The app MUST invoke GET `/cerro-verde/usuario-actual` with the new token to fetch the current user's details (username, name, email, role).
  * The app MUST store the user details in memory and redirect to the Dashboard.
* **Failure Flow:**
  * If the API returns `401 Unauthorized` or standard auth error, the app MUST show a specific error message (e.g. `"Credenciales inválidas"` or `"Usuario deshabilitado"`).

### 4. Global HTTP Header Injection & Request Handling
* **Bearer Token Injection:** Every HTTP request made to the Spring Boot backend (except the open endpoints `/cerro-verde/generar-token`, `/cerro-verde/reset-password`, etc.) MUST include the header:
  ```http
  Authorization: Bearer <jwt_token>
  ```
* **401 Interception:** If any authenticated HTTP request returns a `401 Unauthorized` status during normal application use, the app MUST intercept this status, delete the stored token, empty the global session state, and reset the navigation stack to present the Login screen.

---

## Scenarios

### Scenario 1: Startup without Cached Token
* **Given** the user opens the application,
* **And** no `jwt_token` key is present in `shared_preferences`,
* **When** the application completes its initialization,
* **Then** the application MUST route the user directly to the Login screen.

### Scenario 2: Startup with Valid Cached Token
* **Given** a valid JWT token is stored under `jwt_token` in `shared_preferences`,
* **When** the user starts the application,
* **Then** the app MUST query `GET /cerro-verde/usuario-actual` with the token in the `Authorization` header,
* **And** upon receiving a successful `200 OK` response, the app MUST store the retrieved user details in the application state,
* **And** the app MUST route the user directly to the Dashboard screen, bypassing the Login screen.

### Scenario 3: Startup with Expired/Invalid Cached Token
* **Given** an expired or invalid JWT token is stored under `jwt_token` in `shared_preferences`,
* **When** the user starts the application,
* **Then** the app MUST query `GET /cerro-verde/usuario-actual` with the token,
* **And** upon receiving a `401 Unauthorized` response, the app MUST delete the `jwt_token` from `shared_preferences`,
* **And** the app MUST route the user to the Login screen.

### Scenario 4: Successful User Login
* **Given** the user is on the Login screen,
* **When** the user enters correct credentials and taps the "Login" button,
* **Then** the application MUST send a `POST` request to `/cerro-verde/generar-token` with the username and password,
* **And** upon receiving a successful token response, the app MUST save the token in `shared_preferences` under the key `jwt_token`,
* **And** the app MUST retrieve user details from `GET /cerro-verde/usuario-actual`,
* **And** the app MUST redirect the user to the Dashboard screen.

### Scenario 5: User Logout
* **Given** the user is logged into the application and viewing the Dashboard,
* **When** the user clicks the "Logout" button,
* **Then** the application MUST remove the `jwt_token` key from `shared_preferences`,
* **And** the app MUST clear all active user session data in memory,
* **And** the app MUST redirect the user to the Login screen, clearing the navigation stack history.

### Scenario 6: Active Session Token Expiration (401 Interception)
* **Given** the user has an active session and is navigating the app,
* **When** an API request returns a `401 Unauthorized` status code,
* **Then** the application MUST immediately catch the exception/status code,
* **And** the app MUST delete the `jwt_token` from `shared_preferences`,
* **And** the app MUST display a message saying `"Sesión expirada. Inicie sesión nuevamente"`,
* **And** the app MUST route the user to the Login screen.
