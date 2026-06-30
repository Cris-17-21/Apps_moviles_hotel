package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;

public interface ReservasService {
    List<Reservas> buscarTodos();
    
    Reservas guardar(Reservas reserva);

    Optional<Reservas> buscarId(Integer id);

    Reservas modificar(Reservas reserva);

    void cancelar(Integer id);

    void eliminar(Integer id);

}
