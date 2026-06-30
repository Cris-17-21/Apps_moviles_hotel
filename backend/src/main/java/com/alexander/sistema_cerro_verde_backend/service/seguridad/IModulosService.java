package com.alexander.sistema_cerro_verde_backend.service.seguridad;

import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Modulos;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Permisos;

public interface IModulosService {
    Modulos crearModulo(Modulos modulos);
    Modulos obtenerModuloId(Integer idModulo);
    List<Modulos> obtenerTodosLooModulos();
    List<Permisos> obtenerPermisosPorModulo(Integer idModulo);

    Modulos editarModulo(Modulos modulo);
    void eliminarModulo(Integer idModulo);   
}
