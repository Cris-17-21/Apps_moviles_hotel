package com.alexander.sistema_cerro_verde_backend.service.caja;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.ArqueosCaja;
import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;

public interface ArqueosCajaService {
    
    List<ArqueosCaja> buscarTodos();
    
    ArqueosCaja guardar(ArqueosCaja arqueo);

    Optional<ArqueosCaja> buscarId(Integer id);

    void eliminarId(Integer id);

    Optional<ArqueosCaja> buscarPorCaja(Cajas caja);

    List<ArqueosCaja> buscarTodosPorCaja(Cajas caja);

}
