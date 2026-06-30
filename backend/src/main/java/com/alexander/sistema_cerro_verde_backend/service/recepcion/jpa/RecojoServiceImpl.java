package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Conductores;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Recojo;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.RecojoRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ConductoresService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.RecojoService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ReservasService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class RecojoServiceImpl implements RecojoService{

    @Autowired
    private RecojoRepository repository;

    @Autowired
    private ConductoresService conductorService;

    @Autowired
    private ReservasService reservaService;

    @Override
    @Transactional(readOnly = true)
    public List<Recojo> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional
    public Recojo guardar(Recojo recojo) {
        
        if (recojo.getConductor() != null && recojo.getConductor().getId_conductor() != null) {
            Conductores conductor = conductorService.buscarId(recojo.getConductor().getId_conductor()).orElse(null);
            recojo.setConductor(conductor);
        }

        if (recojo.getReserva() != null && recojo.getReserva().getId_reserva() != null ||  recojo.getEstado() == 1) {
            Reservas reserva = reservaService.buscarId(recojo.getReserva().getId_reserva()).orElse(null);
            recojo.setReserva(reserva);
        }

        return repository.save(recojo);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Recojo> buscarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Recojo modificar(Recojo recojo) {
    if (recojo == null) {
        throw new IllegalArgumentException("El recojo no puede ser nulo");
    }

    if (recojo.getId_recojo() == null) {
        throw new IllegalArgumentException("El ID del recojo es requerido");
    }

    return repository.findById(recojo.getId_recojo())
        .map(existente -> {
            existente.setDestino(recojo.getDestino());
            existente.setFecha_hora(recojo.getFecha_hora());
            existente.setReserva(recojo.getReserva());
            existente.setConductor(recojo.getConductor());
            existente.setEstado_recojo(recojo.getEstado_recojo());
            return repository.save(existente);
        })
        .orElseThrow(() -> new EntityNotFoundException(
            "Recojo no encontrado con ID: " + recojo.getId_recojo()
        ));
    }

    
    @Override
    public void eliminar(Integer id) {
        Recojo recojo = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Recojo no encontrado"));

        recojo.setEstado(0); 
        repository.save(recojo);
    }
}
