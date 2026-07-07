package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;

import java.util.Optional;

public interface ClientesRepository extends JpaRepository<Clientes, Integer> {
    Optional<Clientes> findByDniRuc(String dniRuc);
}
