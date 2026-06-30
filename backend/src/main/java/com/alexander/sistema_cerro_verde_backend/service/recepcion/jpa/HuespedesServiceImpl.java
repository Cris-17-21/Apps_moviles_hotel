package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.HabitacionesXReserva;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Huespedes;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.HuespedesRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.HabitacionesReservaService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.HuespedesService;
import com.alexander.sistema_cerro_verde_backend.service.ventas.ClientesService;


@Service
public class HuespedesServiceImpl implements HuespedesService {

    @Autowired
    private HuespedesRepository repository;

    @Autowired
    private ClientesService clientesService;

    @Autowired
    private HabitacionesReservaService habitacionReservaService;


    @Override
    @Transactional(readOnly = true)
    public List<Huespedes> buscarTodos() {
        return repository.findAll();
    }

    @Override
@Transactional
public Huespedes guardar(Huespedes huesped) {

    if (huesped.getCliente() != null && huesped.getCliente().getIdCliente() != null) {
        Clientes cliente = clientesService.buscarPorId(huesped.getCliente().getIdCliente())
                                           .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));
        huesped.setCliente(cliente);
    }

    if (huesped.getHabres() != null && huesped.getHabres().getId_hab_reserv() != null) {
        HabitacionesXReserva habitacion = habitacionReservaService.buscarId(
            huesped.getHabres().getId_hab_reserv()
        ).orElseThrow(() -> new RuntimeException("Habitación no encontrada"));
        huesped.setHabres(habitacion);
    }

    return repository.save(huesped);
}

    @Override
    @Transactional(readOnly = true)
    public Optional<Huespedes> buscarId(Integer id) {
        return repository.findById(id);
    }
    
    @Override
    @Transactional
    public void eliminar(Integer id) {
        Huespedes huesped = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Huesped no encontrado"));

        huesped.setId_huesped(0); 
        repository.save(huesped);
    }
}

