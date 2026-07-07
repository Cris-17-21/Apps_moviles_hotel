package com.alexander.sistema_cerro_verde_backend.service.caja;

import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoTransacciones;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;

public interface TransaccionesCajaService {
    
    Page<TransaccionesCaja> buscarTodos(Pageable pageable);

    Optional<TransaccionesCaja> encontrarId(Integer id);

    TransaccionesCaja guardar(TransaccionesCaja transaccion);

    void eliminarId(Integer id);
    
    List<TransaccionesCaja> buscarPorCaja(Cajas caja);

    Page<TransaccionesCaja> buscarPorCaja(Cajas caja, Pageable pageable);

    Page<TransaccionesCaja> buscarPorCajaDesdeFecha(Cajas caja, Date fechaApertura, Pageable pageable);

    TipoTransacciones obtenerTipoPorId(Integer id);
    
}
