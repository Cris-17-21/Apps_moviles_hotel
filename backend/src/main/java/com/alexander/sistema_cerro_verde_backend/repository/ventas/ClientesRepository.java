package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;

public interface ClientesRepository extends JpaRepository<Clientes, Integer> {
}
