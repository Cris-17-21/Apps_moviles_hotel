package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;

public interface ReservasService {
    Page<Reservas> buscarTodos(Pageable pageable);
    
    Reservas guardar(Reservas reserva);

    Optional<Reservas> buscarId(Integer id);

    Reservas modificar(Reservas reserva);

    void cancelar(Integer id);

    void eliminar(Integer id);

}
