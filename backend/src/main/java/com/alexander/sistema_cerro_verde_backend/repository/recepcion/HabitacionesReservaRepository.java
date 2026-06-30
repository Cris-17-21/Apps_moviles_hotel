package com.alexander.sistema_cerro_verde_backend.repository.recepcion;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.HabitacionesXReserva;

import jakarta.transaction.Transactional;

public interface HabitacionesReservaRepository extends JpaRepository<HabitacionesXReserva, Integer>{

    @Query("SELECT s FROM HabitacionesXReserva s WHERE s.reserva.id_reserva = :idReserva")
    List<HabitacionesXReserva> findByReservaId(@Param("idReserva") Integer idReserva);

    @Modifying
    @Transactional
    @Query("UPDATE HabitacionesXReserva hr SET hr.estado = 0 WHERE hr.reserva.id_reserva = :idReserva")
    void deleteByReservaId(@Param("idReserva") Integer idReserva);

    @Query("SELECT hxr FROM HabitacionesXReserva hxr WHERE hxr.habitacion.id = :id_habitacion AND hxr.reserva.id = :id_reserva")
    Optional<HabitacionesXReserva> findByHabitacionAndReserva(@Param("id_habitacion") Integer id_habitacion, @Param("id_reserva") Integer id_reserva);

    @Query("SELECT COUNT(hxr) > 0 FROM HabitacionesXReserva hxr WHERE hxr.habitacion.id = :id_habitacion")
    boolean existsByHabitacion(@Param("id_habitacion") Integer id_habitacion);

}