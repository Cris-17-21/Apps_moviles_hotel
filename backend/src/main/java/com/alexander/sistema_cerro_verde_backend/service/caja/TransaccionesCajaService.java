package com.alexander.sistema_cerro_verde_backend.service.caja;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoTransacciones;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;

public interface TransaccionesCajaService {
    
    List<TransaccionesCaja> buscarTodos();

    Optional<TransaccionesCaja> encontrarId(Integer id);

    TransaccionesCaja guardar(TransaccionesCaja transaccion);

    void eliminarId(Integer id);
    
    List<TransaccionesCaja> buscarPorCaja(Cajas caja);

    TipoTransacciones obtenerTipoPorId(Integer id);
    
}
