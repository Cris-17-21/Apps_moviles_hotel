package com.alexander.sistema_cerro_verde_backend.service.ventas;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;

public interface ClientesService {

    List<Clientes> buscarTodos(); //Listar todos los clientes

    Optional<Clientes> buscarPorId(Integer id); //Buscar cliente por Id

    void guardar(Clientes cliente); //Guarda cliente

    void modificar(Clientes cliente); //Modificar cliente

    void eliminar(Integer id); //Eliminar cliente por Id
}
