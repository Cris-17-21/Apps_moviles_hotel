package com.alexander.sistema_cerro_verde_backend.service.mantenimiento;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;



public interface ILimpiezasService {

    Page<Limpiezas> buscarTodos(Pageable pageable);
    Optional<Limpiezas> buscarPorId(Integer id);
    void registrar(Limpiezas limpiezas);
    void actualizar(Integer id, Limpiezas limpiezas);
    void eliminarPorId(Integer id);

}