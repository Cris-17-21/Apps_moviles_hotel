package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Huespedes;

public interface HuespedesService {

    List<Huespedes> buscarTodos();
    
    Huespedes guardar(Huespedes piso);

    Optional<Huespedes> buscarId(Integer id);

    void eliminar(Integer id);
}
