package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Conductores;

public interface ConductoresService {

    List<Conductores> buscarTodos();
    
    Conductores guardar(Conductores conductor);

    Optional<Conductores> buscarId(Integer id);

    Conductores modificar(Conductores conductor);

    void eliminar(Integer id);
}
