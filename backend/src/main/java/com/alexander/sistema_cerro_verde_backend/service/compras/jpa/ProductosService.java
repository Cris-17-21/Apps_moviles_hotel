package com.alexander.sistema_cerro_verde_backend.service.compras.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.compras.Productos;
import com.alexander.sistema_cerro_verde_backend.repository.compras.ProductosRepository;
import com.alexander.sistema_cerro_verde_backend.service.compras.IProductosService;

@Service
public class ProductosService implements IProductosService{
    @Autowired
    private ProductosRepository repoProductos;

    @Override
    public List<Productos> buscarTodos(){ //Buscar todos los productos
        return repoProductos.findAll();
    }

    @Override
    public void guardar(Productos producto){ //Guardar producto
        repoProductos.save(producto);
    }

    @Override
    public void modificar(Productos producto){ //Modificar productos
        repoProductos.save(producto);
    }
    
    @Override
    public Optional<Productos> buscarId(Integer id_producto){ //Buscar productos por Id
        return repoProductos.findById(id_producto);
    }

    @Override
    public void eliminar(Integer id_producto){ //Eliminar producto
        repoProductos.deleteById(id_producto);
    }
}