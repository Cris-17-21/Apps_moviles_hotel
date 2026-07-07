package com.alexander.sistema_cerro_verde_backend.service.mantenimiento;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Incidencias;



public interface IIncidenciasService {

    Page<Incidencias> buscarTodos(Pageable pageable);
    Optional<Incidencias> buscarPorId(Integer id);
    void registrar(Incidencias incidencias);
    void actualizar(Integer id, Incidencias incidencias);
    void eliminarPorId(Integer id);

}