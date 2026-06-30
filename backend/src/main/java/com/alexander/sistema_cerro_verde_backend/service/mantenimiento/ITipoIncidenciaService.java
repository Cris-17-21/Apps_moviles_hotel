package com.alexander.sistema_cerro_verde_backend.service.mantenimiento;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.TipoIncidencia;



public interface ITipoIncidenciaService {

    List<TipoIncidencia> buscarTodos();
    Optional<TipoIncidencia> buscarPorId(Integer id);
    void registrar(TipoIncidencia tipoincidencia);
    void actualizar(Integer id, TipoIncidencia tipoincidencia);
    void eliminarPorId(Integer id);

}