package com.alexander.sistema_cerro_verde_backend.service.compras;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.compras.Compras;

public interface IComprasService {
    List<Compras> buscarTodos();
    //Método para listar todos los registros 
    void guardar(Compras compra);

    void modificar(Compras compra);

    Optional<Compras> buscarId(Integer id_compra);

    void eliminar(Integer id_compra);

    String obtenerProximoCorrelativo();
}