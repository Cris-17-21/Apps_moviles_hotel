# Proposal: Fix Proveedores Field Name Mismatches

## Intent

Fix field key mismatches between the Flutter frontend and Spring Boot backend in the Proveedores (Suppliers) CRUD. The frontend sends/reads `nombre_proveedor` and `direccion_proveedor`, but the backend only accepts `razon_social` and `direccion`. This breaks every Proveedores operation. Follows the same pattern as the previous Productos fix (fix-field-mismatches).

## Scope

### In Scope
- Fix 12 field key references in `proveedores.dart` (`nombre_proveedor` → `razon_social`, `direccion_proveedor` → `direccion`)
- Fix 1 reference in `nueva_compra.dart` (line 330: `nombre_proveedor` → `razon_social`)
- Fix 2 references in `compras.dart` (lines 68, 142: `nombre_proveedor` → `razon_social`)

### Out of Scope
- Merging/dropping duplicate NOMBRE / RAZÓN SOCIAL UI columns (separate change)
- Other modules (Almacén, Reportes)
- Backend changes (contract is correct)

## Capabilities

### New Capabilities
None — pure frontend refactor, no new spec-level behavior.

### Modified Capabilities
None — existing capabilities are unchanged at the spec level. Backend contract stays the same; frontend aligns to it.

## Approach

Find-and-replace all occurrences of `nombre_proveedor` → `razon_social` and `direccion_proveedor` → `direccion` across the 3 Flutter files. Same pattern as the Productos fix: single pass, verify by reading each changed line, no structural refactoring.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/proveedores.dart` | Modified | 12 key refs: create, read, update, delete payloads + table render |
| `lib/nueva_compra.dart` | Modified | 1 key ref: supplier dropdown reads `nombre_proveedor` |
| `lib/compras.dart` | Modified | 2 key refs: nested `proveedor.nombre_proveedor` reads |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Missed references | Low | Grep for remaining `nombre_proveedor\|direccion_proveedor` after changes |
| Breaking compras dropdown by not matching backend shape | Low | Verify supplier list endpoint uses `razon_social` not `nombre_proveedor` |

## Rollback Plan

Revert the 3 files using `git checkout -- <file>` before commit. If committed, revert the commit.

## Dependencies

None.

## Success Criteria

- [ ] `git grep "nombre_proveedor\|direccion_proveedor"` returns 0 hits in Flutter source
- [ ] Proveedores CRUD (create, read, update, delete) works end-to-end
- [ ] Compras create/edit dropdown shows supplier names correctly
