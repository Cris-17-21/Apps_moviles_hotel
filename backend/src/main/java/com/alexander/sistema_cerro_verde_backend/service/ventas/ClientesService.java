package com.alexander.sistema_cerro_verde_backend.service.ventas;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;

public interface ClientesService {

    Page<Clientes> buscarTodos(Pageable pageable); //Listar todos los clientes con paginación

    Optional<Clientes> buscarPorId(Integer id); //Buscar cliente por Id

    Optional<Clientes> buscarPorDniRuc(String dniRuc); //Buscar cliente por DNI/RUC

    void guardar(Clientes cliente); //Guarda cliente

    void modificar(Clientes cliente); //Modificar cliente

    void eliminar(Integer id); //Eliminar cliente por Id
}
