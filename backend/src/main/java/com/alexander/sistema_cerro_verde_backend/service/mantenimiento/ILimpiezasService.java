package com.alexander.sistema_cerro_verde_backend.service.mantenimiento;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;



public interface ILimpiezasService {

    List<Limpiezas> buscarTodos();
    Optional<Limpiezas> buscarPorId(Integer id);
    void registrar(Limpiezas limpiezas);
    void actualizar(Integer id, Limpiezas limpiezas);
    void eliminarPorId(Integer id);

}