package com.alexander.sistema_cerro_verde_backend.controller.seguridad;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Roles;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.RolesRepository;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.IRolesService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin(origins = "*") // Para permitir peticiones desde el frontend (ajusta según sea necesario)
public class RolesController {

    @Autowired
    private IRolesService rolesService;
    
    @Autowired
    private RolesRepository rolesRepository;

    @GetMapping("/roles/")
    public ResponseEntity<List<Roles>> obtenerTodosLosPermisos() {
        List<Roles> roles = rolesService.obtenerTodosLosRoles();
        return ResponseEntity.ok(roles);  // Esto debería devolver la lista de roles con el tipo Content-Type: application/json
    }
    

@PutMapping("/roles/")
public ResponseEntity<?> actualizarRol(@RequestBody Roles rol) {
    try {
        // Validar que el rol existe por ID
        Optional<Roles> rolExistenteOpt = rolesRepository.findById(rol.getId());
        if (!rolExistenteOpt.isPresent()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Rol con ID " + rol.getId() + " no encontrado");
        }

        // Validar que el nombre del rol no esté siendo usado por otro (evita duplicados)
        Optional<Roles> rolConMismoNombre = rolesRepository.findByNombreRol(rol.getNombreRol());
        if (rolConMismoNombre.isPresent() && !rolConMismoNombre.get().getId().equals(rol.getId())) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Ya existe otro rol con el nombre " + rol.getNombreRol());
        }

        // Procesar la actualización
        Roles rolActualizado = rolesService.actualizarRol(rol);
        return ResponseEntity.ok(rolActualizado);

    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error al actualizar el rol: " + e.getMessage());
    }
}


    @GetMapping("/roles/{id}")
    public ResponseEntity<Roles> obtenerRol(@PathVariable Integer id) {
        Roles rol = rolesService.obtenerRolPorId(id);
        if (rol == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(rol);
    }

    @PostMapping("/roles/")
    public ResponseEntity<Roles> crearRol(@RequestBody Roles rol) throws Exception {
        return ResponseEntity.ok(rolesService.crearRol(rol));
    }

    
    @PostMapping("/roles-sp/")
    public ResponseEntity<Roles> crearRolSinPermisos(@RequestBody Roles rol) throws Exception {
        return ResponseEntity.ok(rolesService.crearRol(rol));
    }
    
    
   
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarRol(@PathVariable Integer id) {
        Roles existente = rolesService.obtenerRolPorId(id);
        if (existente == null) {
            return ResponseEntity.notFound().build();
        }
        rolesService.eliminarRol(id);
        return ResponseEntity.noContent().build();
    }
}