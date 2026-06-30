package com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa;

import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.CheckinCheckout;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.HabitacionesXReserva;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.SalonesXReserva;
import com.alexander.sistema_cerro_verde_backend.repository.mantenimiento.LimpiezasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.CheckinCheckoutRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.HabitacionesRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.HabitacionesReservaRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.ReservasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.SalonesRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.SalonesReservaRepository;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.CheckinCheckoutService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class CheckinCheckoutServiceImpl implements CheckinCheckoutService {

    @Autowired
    private CheckinCheckoutRepository repository;

    @Autowired
    private HabitacionesReservaRepository habitacionesReservasRepository;

    @Autowired
    private HabitacionesRepository habitacionRepository;

    @Autowired
    private SalonesReservaRepository salonesReservasRepository;

    @Autowired
    private SalonesRepository salonesRepository;

    @Autowired
    private ReservasRepository reservaRepository;

 

    @Autowired
    private LimpiezasRepository repoLimpiezas;

    @Override
    @Transactional(readOnly = true)
    public List<CheckinCheckout> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional
    public CheckinCheckout guardar(CheckinCheckout check) {

        if (check == null || check.getReserva() == null) {
            throw new IllegalArgumentException("Datos incompletos para guardar el check-in");
        }

        var reserva = reservaRepository.findById(check.getReserva().getId_reserva())
        .orElseThrow(() -> new IllegalArgumentException("Reserva no encontrada"));

        reserva.setEstado_reserva("Check-in");
        check.setReserva(reserva);

        List<HabitacionesXReserva> habitaciones = habitacionesReservasRepository.findByReservaId(reserva.getId_reserva());
        for (HabitacionesXReserva hr : habitaciones) {
            hr.getHabitacion().setEstado_habitacion("Ocupada");
            habitacionRepository.save(hr.getHabitacion());
        }

        reservaRepository.save(reserva);

        return repository.save(check);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<CheckinCheckout> buscarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    @Transactional
    public CheckinCheckout modificar(CheckinCheckout check) {
        if (check == null || check.getId_check() == null) {
            throw new IllegalArgumentException("Datos incompletos para modificar el check-in");
        }

        return repository.findById(check.getId_check())
                .map(existente -> {
                    existente.setFecha_checkout(check.getFecha_checkout());

                    if (check.getFecha_checkout() != null) {
                        var reserva = existente.getReserva();
                        reserva.setEstado_reserva("Completada");

                        // 5. Cambiar estado de habitaciones
                        List<HabitacionesXReserva> habitaciones = habitacionesReservasRepository.findByReservaId(reserva.getId_reserva());
                        for (HabitacionesXReserva hr : habitaciones) {
                            hr.getHabitacion().setEstado_habitacion("Limpieza");
                            
                            Limpiezas limpieza = new Limpiezas();
                            limpieza.setEstado_limpieza("Pendiente");
                            limpieza.setHabitacion(hr.getHabitacion());
                            limpieza.setFecha_registro(new Date());
                            repoLimpiezas.save(limpieza);

                            habitacionRepository.save(hr.getHabitacion());
                        }

                        // 6. Cambiar estado de salones
                        List<SalonesXReserva> salones = salonesReservasRepository.findByReservaId(reserva.getId_reserva());
                        for (SalonesXReserva sr : salones) {
                            sr.getSalon().setEstado_salon("Disponible");

                            Limpiezas limpieza = new Limpiezas();
                            limpieza.setEstado_limpieza("Pendiente");
                            limpieza.setSalon(sr.getSalon());
                            limpieza.setFecha_registro(new Date());
                            repoLimpiezas.save(limpieza);

                            salonesRepository.save(sr.getSalon());
                        }

                        // 7. Guardar cambios finales
                        reservaRepository.save(reserva);
                    }

                    return repository.save(existente);
                })
                .orElseThrow(() -> new EntityNotFoundException(
                "CheckinCheckout no encontrado con ID: " + check.getId_check()));
    }

    @Override
    @Transactional
    public void eliminar(Integer id) {
        CheckinCheckout check = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Conductor no encontrado"));

        check.setEstado(0);
        repository.save(check);
    }
}
