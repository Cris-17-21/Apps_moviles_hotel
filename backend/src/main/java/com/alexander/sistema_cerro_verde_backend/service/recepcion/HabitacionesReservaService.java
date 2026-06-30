package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.HabitacionesXReserva;

public interface HabitacionesReservaService {

    List<HabitacionesXReserva> buscarTodos();
    
    HabitacionesXReserva guardar(HabitacionesXReserva reservahabitacion);

    Optional<HabitacionesXReserva> buscarId(Integer id);

    HabitacionesXReserva modificar(HabitacionesXReserva habreserva);
    
    void eliminar(Integer id);

}
