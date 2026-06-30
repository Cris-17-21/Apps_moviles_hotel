package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import jakarta.persistence.EntityNotFoundException;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Habitaciones;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.HabitacionesXReserva;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.HabitacionesRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.HabitacionesReservaRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.HabitacionesReservaService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.HabitacionesService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ReservasService;

@Service
public class HabitacionesReservaServiceImpl implements HabitacionesReservaService {

    @Autowired
    private HabitacionesReservaRepository repository;

    @Autowired
    private HabitacionesService habitacionService;

    @Autowired
    private ReservasService reservaService;

    @Autowired
    private HabitacionesRepository habitacionRepository;

    @Override
    @Transactional(readOnly = true)
    public List<HabitacionesXReserva> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional
    public HabitacionesXReserva guardar(HabitacionesXReserva habreserva) {

        if (habreserva.getHabitacion() != null && habreserva.getHabitacion().getId_habitacion() != null) {
        Habitaciones habitacion = habitacionService.buscarId(habreserva.getHabitacion().getId_habitacion()).orElse(null);
        habreserva.setHabitacion(habitacion);

        habreserva.setPrecio_reserva(habitacion.getTipo_habitacion().getPrecio());
        
        habitacion.setEstado_habitacion("Reservada");
        }

        if (habreserva.getReserva() != null && habreserva.getReserva().getId_reserva() != null) {
            Reservas reserva = reservaService.buscarId(habreserva.getReserva().getId_reserva()).orElse(null);
            
            if (reserva == null || !reserva.getTipo().equalsIgnoreCase("Habitación")) {
                throw new IllegalArgumentException("Solo se puede asignar una habitación si la reserva es de tipo 'Habitación'.");
            }
            
            
            habreserva.setReserva(reserva);
        }

        return repository.save(habreserva);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<HabitacionesXReserva> buscarId(Integer id) {
        return repository.findById(id);
    }


    @Override
    public HabitacionesXReserva modificar(HabitacionesXReserva habreserva) {

    if (habreserva == null) {
        throw new IllegalArgumentException("El objeto habreserva no puede ser nulo");
    }

    if (habreserva.getId_hab_reserv() == null) {
        throw new IllegalArgumentException("El ID de la relación hab-reserva es requerido");
    }

    if (habreserva.getHabitacion() == null || habreserva.getHabitacion().getId_habitacion() == null) {
        throw new IllegalArgumentException("Debe proporcionar una habitación existente con ID");
    }

    // Buscar la habitación existente en la base de datos
    Habitaciones habitacionExistente = habitacionRepository.findById(habreserva.getHabitacion().getId_habitacion())
        .orElseThrow(() -> new EntityNotFoundException("Habitación no encontrada con ID: " + habreserva.getHabitacion().getId_habitacion()));

    return repository.findById(habreserva.getId_hab_reserv())
        .map(existente -> {
            // Solo se actualiza la habitación asociada
            existente.setHabitacion(habitacionExistente);
            return repository.save(existente);
        })
        .orElseThrow(() -> new EntityNotFoundException(
            "Habitación por reserva no encontrada con ID: " + habreserva.getId_hab_reserv()
        ));
    }



    @Override
    @Transactional
    public void eliminar(Integer id) {
    HabitacionesXReserva habreserva = repository.findById(id)
        .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));

    // Eliminación lógica de la relación
    habreserva.setEstado(0);
    repository.save(habreserva);

    // Cambiar el estado de la habitación a "Disponible"
    if (habreserva.getHabitacion() != null) {
        Habitaciones habitacion = habreserva.getHabitacion();
        habitacion.setEstado_habitacion("Disponible");
        habitacionRepository.save(habitacion); // necesitas este repositorio
    }
    }

    
}
