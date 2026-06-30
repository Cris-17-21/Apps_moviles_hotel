package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Pisos;

public interface PisosService {

    List<Pisos> buscarTodos();
    
    Pisos guardar(Pisos piso);

    Optional<Pisos> buscarId(Integer id);

    void eliminar(Integer id);
}
