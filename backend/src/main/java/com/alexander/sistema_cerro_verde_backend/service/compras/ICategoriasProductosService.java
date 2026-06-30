package com.alexander.sistema_cerro_verde_backend.service.compras;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.compras.CategoriasProductos;

public interface ICategoriasProductosService {

    List<CategoriasProductos> buscarTodos(); //Listar categorias

    void guardar(CategoriasProductos categoriaProducto); //Guardar categoria

    void modificar(CategoriasProductos categoriaProducto); //Modificar categoria

    Optional<CategoriasProductos> buscarId(Integer id_categoria); //Buscar por Id categoria

    void eliminar(Integer id_categoria); //Eliminar categoria, estado = 0
}