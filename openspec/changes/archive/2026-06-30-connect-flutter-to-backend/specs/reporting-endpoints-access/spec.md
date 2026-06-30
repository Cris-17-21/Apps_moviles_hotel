# Specification: Flexible Reporting Endpoints Access

## Metadata
* **Capability Name:** reporting-endpoints-access
* **Type:** Modified
* **Status:** Draft
* **Created:** 2026-06-30
* **Updated:** 2026-06-30

## Overview
This capability modifies the backend access restrictions to allow clients other than the default Angular client (running at `http://localhost:4200`) to access reporting endpoints. This change modifies Spring Boot controllers and security configurations to support cross-origin requests from Flutter Web clients (which bind to random ports at runtime) and Android Emulators.

## Requirements

### 1. Spring Boot Controller CORS Configurations
* **Removal of Specific Origin Restrictions:** The `@CrossOrigin(origins = "http://localhost:4200")` annotations on `CajaReporteController` and `ReportesVentasController` MUST be removed.
* **Delegation to Global CORS Filter:** Controllers MUST delegate CORS policy verification to the central Spring Security configuration.

### 2. Spring Security Global CORS Config
* **Global Filter Mapping:** `SecurityConfig.java` MUST configure a global `CorsConfigurationSource` bean mapped to all endpoints (`/**`).
* **Allowed Origins:**
  * In local development mode, the CORS configuration MUST support wildcard origins (`*`) or dynamically permit the request host to avoid breaking Flutter Web.
* **Allowed Methods:** The configuration MUST permit the HTTP methods: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`.
* **Allowed Headers:** The configuration MUST allow standard headers like `Authorization`, `Content-Type`, and basic metadata headers.
* **CORS Preflight Requests:** The backend MUST return `200 OK` without requiring authentication headers for preflight `OPTIONS` requests matching CORS parameters.

---

## Scenarios

### Scenario 1: CORS Request from Flutter Web Client (Preflight Options Handshake)
* **Given** the Spring Boot backend is configured with global CORS policy,
* **When** a Flutter Web client on origin `http://localhost:5241` issues an HTTP `OPTIONS` preflight request to `/cerro-verde/reportes/caja/resumen`,
* **Then** the backend MUST return a status code of `200 OK`,
* **And** the response headers MUST include:
  * `Access-Control-Allow-Origin` matching `*` or `http://localhost:5241`,
  * `Access-Control-Allow-Methods` containing `GET`,
  * `Access-Control-Allow-Headers` containing `Authorization`.

### Scenario 2: Authorized Report Data Request from Android Emulator
* **Given** a user is operating the app on an Android Emulator targeting endpoint `http://10.0.2.2:8080/cerro-verde/reportes/ventas/productos`,
* **And** the request contains a valid JWT token in the `Authorization` header,
* **When** the client issues a `GET` request to fetch sales reports,
* **Then** the Spring Boot backend MUST process the query,
* **And** the backend MUST return the JSON response containing the list of top-selling products,
* **And** the response headers MUST include the appropriate `Access-Control-Allow-Origin` values.
