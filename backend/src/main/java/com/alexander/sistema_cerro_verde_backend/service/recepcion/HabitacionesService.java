package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Habitaciones;


public interface HabitacionesService {

    List<Habitaciones> buscarTodos();
    
    Habitaciones guardar(Habitaciones habitacion);

    Optional<Habitaciones> buscarId(Integer id);

    Habitaciones modificar(Habitaciones habitacion);

    void eliminar(Integer id);
}
