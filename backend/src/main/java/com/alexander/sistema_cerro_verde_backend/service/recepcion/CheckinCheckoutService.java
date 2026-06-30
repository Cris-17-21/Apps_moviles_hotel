package com.alexander.sistema_cerro_verde_backend.service.recepcion;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.CheckinCheckout;

public interface CheckinCheckoutService {

    List<CheckinCheckout> buscarTodos();
    
    CheckinCheckout guardar(CheckinCheckout check);

    Optional<CheckinCheckout> buscarId(Integer id);

    CheckinCheckout modificar(CheckinCheckout check);

    void eliminar(Integer id);
}
