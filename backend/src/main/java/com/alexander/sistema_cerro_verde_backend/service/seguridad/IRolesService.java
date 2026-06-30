package com.alexander.sistema_cerro_verde_backend.service.seguridad;
import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Permisos;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Roles;

public interface IRolesService {
    Roles crearRol(Roles rol)  throws Exception;                       
    Roles actualizarRol(Roles rol);                  
    Roles obtenerRolPorId(Integer idRol);
    List<Roles> obtenerTodosLosRoles();
    void eliminarRol(Integer idRol);
    Roles crearRolSinPermiso(Roles rol) throws Exception;
    List<Permisos> obtenerPermisosPorRol(Integer idRol); 
    Roles asignarPermisosARol(Integer idRol, List<Integer> idPermisos);

}
