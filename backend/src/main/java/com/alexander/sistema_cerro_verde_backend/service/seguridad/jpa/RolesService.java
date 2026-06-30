package com.alexander.sistema_cerro_verde_backend.service.seguridad.jpa;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Permisos;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Roles;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.RolesPermisos;
import com.alexander.sistema_cerro_verde_backend.excepciones.NombreRolYaExisteException;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.PermisosRepository;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.RolesPermisosRepository;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.RolesRepository;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.IRolesService;

@Service
public class RolesService implements IRolesService {

    @Autowired
    private RolesRepository rolesRepository;
    @Autowired
    private RolesPermisosRepository rolesPermisosRepo;
    @Autowired
    private PermisosRepository permisosRepository;
    
   @Override
   public Roles crearRol(Roles rol) throws Exception {
    // Verificar si el rol ya existe
    Optional<Roles> existingRole = rolesRepository.findByNombreRol(rol.getNombreRol());
    if (existingRole.isPresent()) {
        throw new NombreRolYaExisteException("El rol con el nombre " + rol.getNombreRol() + " ya existe en el sistema");
    }

    return rolesRepository.save(rol);
}
@Override
public Roles actualizarRol(Roles rol) {
    // Verificar que el rol exista antes de actualizar
    Roles rolExistente = rolesRepository.findById(rol.getId())
        .orElseThrow(() -> new RuntimeException("Rol con ID " + rol.getId() + " no encontrado"));

    System.out.println("Actualizando rolesPermisos para el rol ID: " + rol.getId());
    rolesPermisosRepo.deleteByRolId(rol.getId());
    Set<RolesPermisos> rolesPermisosSet = new HashSet<>();

    for (RolesPermisos rp : rol.getRolesPermisos()) {
        if (rp.getPermisos() != null) {
            Integer idPermiso = rp.getPermisos().getId();
            Permisos permiso = permisosRepository.findById(idPermiso)
                .orElseThrow(() -> new RuntimeException("Permiso con ID " + idPermiso + " no encontrado"));

            rp.setPermisos(permiso);
            rp.setRoles(rol); // Relación inversa
            rolesPermisosSet.add(rp);
        } else {
            throw new RuntimeException("Permiso nulo recibido en rolesPermisos");
        }
    }

    // Establecemos los permisos actualizados en el rol
    rol.setRolesPermisos(rolesPermisosSet);

    // Guardamos el rol con los nuevos permisos
    return rolesRepository.save(rol);
}

    @Override
    public Roles obtenerRolPorId(Integer idRol) {
        return rolesRepository.findById(idRol).get();
    }

    @Override
    public List<Roles> obtenerTodosLosRoles() {
        return rolesRepository.findAll();
    }


    @Override
    public void eliminarRol(Integer idRol) {
        if (!rolesRepository.existsById(idRol)) {
            throw new RuntimeException("El rol con ID " + idRol + " no existe");
        }
        rolesRepository.deleteById(idRol);
    }

    public Roles buscarPorNombre(String rol) {
        return rolesRepository.findByNombreRol(rol).orElse(null);
    }

    @Override
    public List<Permisos> obtenerPermisosPorRol(Integer idRol) {
        throw new UnsupportedOperationException("Unimplemented method 'obtenerPermisosPorRol'");
    }

    @Override
    public Roles asignarPermisosARol(Integer idRol, List<Integer> idPermisos) {
        throw new UnsupportedOperationException("Unimplemented method 'asignarPermisosARol'");
    }

    @Override
    public Roles crearRolSinPermiso(Roles rol) throws Exception {
        Optional<Roles> existingRole = rolesRepository.findByNombreRol(rol.getNombreRol());
        if (existingRole.isPresent()) {
            throw new NombreRolYaExisteException("El rol con el nombre " + rol.getNombreRol() + " ya existe en el sistema");
        }
        return rolesRepository.save(rol);
    }
    
}
