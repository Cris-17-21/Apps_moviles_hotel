package com.alexander.sistema_cerro_verde_backend.service.seguridad.jpa;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Permisos;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.PermisosRepository;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.IPermisosService;

@Service
public class PermisosService implements IPermisosService{

   
    @Autowired
    private PermisosRepository permisosRepository;
    
    @Override
    public List<Permisos> obtenerTodosLosPermisos() {
        return permisosRepository.findAll();
    }

    @Override
    public Permisos editarPermiso(Permisos permisos) {
        return permisosRepository.save(permisos);
        
    }

    @Override
    public Permisos obtenerPermiso(Integer permisosId) {
        return permisosRepository.findById(permisosId).get();
    }

    @Override
    public Permisos crearPermiso(Permisos permiso) {
        Integer idPermiso = permiso.getId();
        Permisos modulo = permisosRepository.findById(idPermiso).orElse(null);
        if (modulo != null) {
            return permisosRepository.save(permiso);
        } else {
            throw new RuntimeException("Sub modulo no encontrado");
        }
    }

    @Override
    public void eliminarPermiso(Integer idPermiso) {
        Permisos permisos = new Permisos();
        permisos.setId(idPermiso);
        permisosRepository.delete(permisos);
    }
    @Override
    public List<Permisos> obtenerPermisosPorModulo(Integer idModulo) {
        return permisosRepository.findByModulo_IdModulo(idModulo);
    }
  
}