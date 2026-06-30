package com.alexander.sistema_cerro_verde_backend.service.ventas;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.ComprobantePago;

public interface IComprobantePagoService {

    List<ComprobantePago> buscarTodos();

    Optional<ComprobantePago> buscarPorId(Integer id);

    void guardar(ComprobantePago comprobantePago);

    void modificar(ComprobantePago comprobantePago);

    void eliminar(Integer id);

    String generarSiguienteCorrelativo(String serie);
}
