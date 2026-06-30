package com.alexander.sistema_cerro_verde_backend.repository.caja;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.caja.ArqueosCaja;
import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;

public interface ArqueosCajaRepository extends JpaRepository<ArqueosCaja, Integer> {
    Optional<ArqueosCaja> findByCaja(Cajas caja);
    List<ArqueosCaja> findAllByCaja(Cajas caja);
}
