package com.alexander.sistema_cerro_verde_backend.service.caja;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.DetalleArqueo;

public interface DetalleArqueoService {

    List<DetalleArqueo> buscarTodos();

    Optional<DetalleArqueo> buscarId(Integer id);

    DetalleArqueo guardar(DetalleArqueo arqueo);

    void eliminarId(Integer id);

}
