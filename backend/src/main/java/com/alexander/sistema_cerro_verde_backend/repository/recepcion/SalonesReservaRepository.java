package com.alexander.sistema_cerro_verde_backend.repository.recepcion;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.SalonesXReserva;

import jakarta.transaction.Transactional;

public interface SalonesReservaRepository extends JpaRepository<SalonesXReserva, Integer> {


    @Query("SELECT s FROM SalonesXReserva s WHERE s.reserva.id_reserva = :idReserva")
    List<SalonesXReserva> findByReservaId(@Param("idReserva") Integer idReserva);


    @Modifying
    @Transactional
    @Query("UPDATE SalonesXReserva hr SET hr.estado = 0 WHERE hr.reserva.id_reserva = :idReserva")
    void deleteByReservaId(@Param("idReserva") Integer idReserva);

    @Query("SELECT hxr FROM SalonesXReserva hxr WHERE hxr.salon.id = :id_salon AND hxr.reserva.id = :id_reserva")
    Optional<SalonesXReserva> findBySalonAndReserva(@Param("id_salon") Integer id_salon, @Param("id_reserva") Integer id_reserva);

    @Query("SELECT COUNT(hxr) > 0 FROM SalonesXReserva hxr WHERE hxr.salon.id = :id_salon")
    boolean existsBySalon(@Param("id_salon") Integer id_salon);

}
