package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import jakarta.persistence.EntityNotFoundException;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Conductores;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.ConductoresRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.RecojoRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ConductoresService;

@Service
public class ConductoresServiceImpl implements ConductoresService {

    @Autowired
    private ConductoresRepository repository;

    @Autowired
    private RecojoRepository recojoRepository;

    @Override
    @Transactional(readOnly = true)
    public List<Conductores> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional
    public Conductores guardar(Conductores conductor) {

        return repository.save(conductor);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Conductores> buscarId(Integer id) {
        return repository.findById(id);
    }


    @Override
    public Conductores modificar(Conductores conductor) {
    if (conductor == null) {
        throw new IllegalArgumentException("El conductor no puede ser nulo");
    }

    if (conductor.getId_conductor() == null) {
        throw new IllegalArgumentException("El ID del conductor es requerido");
    }

    return repository.findById(conductor.getId_conductor())
        .map(existente -> {
            existente.setDni(conductor.getDni());
            existente.setNombre(conductor.getNombre());
            existente.setTelefono(conductor.getTelefono());
            existente.setPlaca(conductor.getPlaca());
            existente.setModelo_vehiculo(conductor.getModelo_vehiculo());
            return repository.save(existente);
        })
        .orElseThrow(() -> new EntityNotFoundException(
            "Conductor no encontrado con ID: " + conductor.getId_conductor()
        ));
    }

    
    @Override
    @Transactional
    public void eliminar(Integer id) {
        Conductores conductor = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Conductor no encontrado"));

        Integer recojosActivos = recojoRepository.contarRecojosActivosPorConductor(id);
        if (Optional.ofNullable(recojosActivos).orElse(0) > 0){
        throw new ResponseStatusException(
            HttpStatus.CONFLICT, "No se puede eliminar: el conductor tiene recojos activos."
        );
        }

        conductor.setEstado(0); 
        repository.save(conductor);
    }
}
