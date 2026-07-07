# inventory-crud Specification

## Purpose

Full CRUD for inventory movements (MovimientosInventario) from the Almacén page. Backend removes `@JsonIgnore` on `producto`/`sucursal` fields; frontend adds service layer, CRUD dialogs, loading/error/empty states, search, and tipo filter.

## Requirements

### Requirement: Backend — Expose Entity Relationships for Writes

The backend MUST remove `@JsonIgnore` from `producto` and `sucursal` in `MovimientosInventario.java`. `compra` and `venta` MUST remain `@JsonIgnore`.

#### Scenario: POST accepts producto and sucursal IDs
- GIVEN a JSON body with `producto.id` and `sucursal.id`
- WHEN POST /cerro-verde/movimientosinventario is called
- THEN status is 200 or 201

#### Scenario: PUT accepts updated references
- GIVEN an existing movement with updated `producto.id` and `sucursal.id`
- WHEN PUT /cerro-verde/movimientosinventario is called
- THEN status is 200

### Requirement: Frontend — Almacén Service

The frontend MUST provide a static `AlmacenService` class following `ProductosService` patterns.

| Method | HTTP | Endpoint |
|--------|------|----------|
| obtenerMovimientos() | GET | /cerro-verde/movimientosinventario |
| crearMovimiento(data) | POST | /cerro-verde/movimientosinventario |
| actualizarMovimiento(data) | PUT | /cerro-verde/movimientosinventario |
| eliminarMovimiento(id) | DELETE | /cerro-verde/movimientosinventario/{id} |
| obtenerProductos() | GET | /cerro-verde/productos |

#### Scenario: Service fetches and returns movements
- GIVEN backend has movements
- WHEN obtenerMovimientos() is called
- THEN a List<Map> is returned

#### Scenario: Service creates a movement
- WHEN crearMovimiento(data) is called with valid data
- THEN the response Map is returned

#### Scenario: Service deletes by ID
- WHEN eliminarMovimiento(id) is called with a valid ID
- THEN backend returns 200 or 204

#### Scenario: Service propagates errors
- GIVEN the backend is unreachable
- WHEN any method is called
- THEN the exception is rethrown to the caller

### Requirement: Frontend — Page States

The page MUST show loading spinner, error with retry, empty message, and support pull-to-refresh.

#### Scenario: Loading shows spinner during init
- GIVEN the page is initializing
- WHEN initState triggers fetch
- THEN CircularProgressIndicator is shown

#### Scenario: Error shows message and retry button
- GIVEN the API call fails
- THEN an error message and "Reintentar" button appear
- WHEN retry is pressed
- THEN the fetch is retried

#### Scenario: Empty list shows "No hay movimientos"
- GIVEN the API returns an empty list
- THEN the empty-state text is displayed

#### Scenario: Pull-to-refresh reloads data
- GIVEN data is loaded
- WHEN the user pulls down
- THEN data is refetched from API

### Requirement: Frontend — CRUD Dialogs

The page MUST provide create, edit, and delete dialogs matching the productos.dart pattern. Table columns: `idMovimiento`, `producto`, `tipoMovimiento`, `cantidad`, `fecha`. Drop `referencia` and `hora`.

#### Scenario: Create dialog submits and refreshes
- GIVEN the user fills producto dropdown (from API), tipo dropdown, cantidad input, and date picker
- WHEN "Guardar" is pressed with valid data
- THEN POST is called and the list refreshes

#### Scenario: Edit dialog pre-fills existing values
- GIVEN the user edits an existing movement
- THEN dialog shows current values pre-filled
- WHEN saved, PUT is called and list refreshes

#### Scenario: Delete confirmation
- GIVEN the user presses delete
- THEN a confirmation dialog shows movement info
- WHEN confirmed, DELETE is called and list refreshes

#### Scenario: CRUD failure shows error SnackBar
- GIVEN a create, update, or delete API call fails
- THEN a red SnackBar with the error message is shown

### Requirement: Frontend — Search and Filter

Search TextField MUST filter by `producto` name. Tipo DropdownButton MUST filter by `tipoMovimiento`.

#### Scenario: Search filters by producto name
- GIVEN the user types in the search field
- THEN the table filters to matching producto names

#### Scenario: Tipo dropdown filters movements
- GIVEN the user selects "Entrada" from the dropdown
- THEN only movements with tipoMovimiento "Entrada" are shown

### Requirement: Frontend — Cantidad Parsing

The DTO returns `cantidad` as String; the frontend MUST parse it to int for display.

#### Scenario: cantidad displayed as integer
- GIVEN the API returns `"cantidad": "10"`
- THEN the table shows "10" as a numeric value, no quotes

## Removed Columns

The columns `referencia` and `hora` from the current mock table MUST be removed — the backend DTO does not provide these fields.
