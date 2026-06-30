package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.SalonesRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.SalonesReservaRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.SalonesService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class SalonesServiceImpl implements SalonesService{

    @Autowired
    private SalonesRepository repository;

    @Autowired
    private SalonesReservaRepository salonReservaRepository;


    @Override
    @Transactional(readOnly = true)
    public List<Salones> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional
    public Salones guardar(Salones salon) {

        return repository.save(salon);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Salones> buscarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Salones modificar(Salones salon) {
    // 1. Validar que la habitación no sea nula
    if (salon == null) {
        throw new IllegalArgumentException("La habitación no puede ser nula");
    }

    // 2. Verificar que el ID existe
    if (salon.getId_salon() == null) {
        throw new IllegalArgumentException("El ID de la habitación es requerido");
    }

    // 3. Comprobar si existe antes de actualizar
    return repository.findById(salon.getId_salon())
        .map(existente -> {
            existente.setNombre(salon.getNombre());
            existente.setCapacidad(salon.getCapacidad());
            existente.setEstado_salon(salon.getEstado_salon());
            existente.setPrecio_diario(salon.getPrecio_diario());
            existente.setPrecio_hora(salon.getPrecio_hora());
            return repository.save(existente);
        })
        .orElseThrow(() -> new EntityNotFoundException(
            "Salón no encontrado con ID: " + salon.getId_salon()
        ));
    }

    @Override
    @Transactional
    public void eliminar(Integer id) {
        Salones salon = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));

            if (salonReservaRepository.existsBySalon(id)) {
                throw new RuntimeException("No se puede eliminar: la habitación está asociada a una reserva");
            }
            

        salon.setEstado(0);
        repository.save(salon);
    }

}

