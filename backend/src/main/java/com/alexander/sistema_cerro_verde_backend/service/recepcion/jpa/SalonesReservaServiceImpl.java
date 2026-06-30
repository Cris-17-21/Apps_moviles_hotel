package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.SalonesXReserva;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.SalonesRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.SalonesReservaRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ReservasService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.SalonesReservaService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.SalonesService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class SalonesReservaServiceImpl implements SalonesReservaService {

    @Autowired
    private SalonesReservaRepository repository;

    @Autowired
    private SalonesRepository salonRepository;

    @Autowired
    private SalonesService salonService;

    @Autowired
    private ReservasService reservaService;

    @Override
    @Transactional(readOnly = true)
    public List<SalonesXReserva> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional
    public SalonesXReserva guardar(SalonesXReserva salreserva) {

        if (salreserva.getSalon() != null && salreserva.getSalon().getId_salon() != null) {
        Salones salon = salonService.buscarId(salreserva.getSalon().getId_salon()).orElse(null);
        salreserva.setSalon(salon);
        salon.setEstado_salon("Reservado");
        }

        if (salreserva.getReserva() != null && salreserva.getReserva().getId_reserva() != null) {
            Reservas reserva = reservaService.buscarId(salreserva.getReserva().getId_reserva()).orElse(null);
            salreserva.setReserva(reserva);

            if (reserva == null || !reserva.getTipo().equalsIgnoreCase("Salón")) {
                throw new IllegalArgumentException("Solo se puede asignar un salón si la reserva es de tipo 'Salón'.");
            }
        }

        return repository.save(salreserva);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<SalonesXReserva> buscarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    public SalonesXReserva modificar(SalonesXReserva salreserva) {
    if (salreserva == null) {
        throw new IllegalArgumentException("el salón no puede ser nula");
    }

    // 2. Verificar que el ID existe
    if (salreserva.getId_salon_reserv() == null) {
        throw new IllegalArgumentException("El ID de el salón es requerido");
    }

    // 3. Comprobar si existe antes de actualizar
    return repository.findById(salreserva.getId_salon_reserv())
        .map(existente -> {
            existente.setSalon(salreserva.getSalon());
            existente.setReserva(salreserva.getReserva());
            return repository.save(existente);
        })
        .orElseThrow(() -> new EntityNotFoundException(
            "Habitación no encontrada con ID: " + salreserva.getId_salon_reserv()
        ));
    }

    @Override
    @Transactional
    public void eliminar(Integer id) {
        SalonesXReserva salreserva = repository.findById(id)
        .orElseThrow(() -> new RuntimeException("Salón no encontrado"));
    
        salreserva.setEstado(0); // 0 representa inactivo/eliminado lógico
        repository.save(salreserva);

        if (salreserva.getSalon() != null) {
            Salones salon = salreserva.getSalon();
            salon.setEstado_salon("Disponible");
            salonRepository.save(salon); // necesitas este repositorio
        }
    }

    
}

