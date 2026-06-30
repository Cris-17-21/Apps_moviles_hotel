package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Recojo;

public interface RecojoService {

    List<Recojo> buscarTodos();
    
    Recojo guardar(Recojo recojo);

    Optional<Recojo> buscarId(Integer id);

    Recojo modificar(Recojo recojo);

    void eliminar(Integer id);
}
