package com.alexander.sistema_cerro_verde_backend.repository.caja;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.caja.DenominacionDinero;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoDenominacion;

import java.util.List;

public interface DenominacionDineroRepository extends JpaRepository<DenominacionDinero, Integer> {
    List<DenominacionDinero> findByTipo(TipoDenominacion tipo);
}
