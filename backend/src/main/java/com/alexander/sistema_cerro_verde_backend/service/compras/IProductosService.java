package com.alexander.sistema_cerro_verde_backend.service.compras;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.compras.Productos;

public interface IProductosService {
    List<Productos> buscarTodos(); //Buscar todos los Productos

    void guardar(Productos producto); //Guardar producto

    void modificar(Productos producto); //Modificar producto

    Optional<Productos> buscarId(Integer id_producto); //Buscar el producto por Id

    void eliminar(Integer id_producto); //Eliminar producto, estado = 0
}