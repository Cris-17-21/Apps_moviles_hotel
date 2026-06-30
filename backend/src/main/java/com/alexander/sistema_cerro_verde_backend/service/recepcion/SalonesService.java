package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;

public interface SalonesService {

    List<Salones> buscarTodos();
    
    Salones guardar(Salones salon);

    Optional<Salones> buscarId(Integer id);

    Salones modificar(Salones salon);


    void eliminar(Integer id);
}
