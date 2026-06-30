package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.TipoHabitacion;

public interface TipoHabitacionService {

    List<TipoHabitacion> buscarTodos();
    
    TipoHabitacion guardar(TipoHabitacion tipo);

    Optional<TipoHabitacion> buscarId(Integer id);

    TipoHabitacion modificar(TipoHabitacion tipo);

    void eliminar(Integer id);
}
