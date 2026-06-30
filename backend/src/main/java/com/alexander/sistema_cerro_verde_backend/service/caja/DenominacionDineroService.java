package com.alexander.sistema_cerro_verde_backend.service.caja;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.DenominacionDinero;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoDenominacion;

public interface DenominacionDineroService {

    List<DenominacionDinero> buscarTodos();

    Optional<DenominacionDinero> buscarId(Integer id);

    List<DenominacionDinero> buscarPorTipo(TipoDenominacion tipo);
    
}
