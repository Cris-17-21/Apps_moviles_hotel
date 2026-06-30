package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaSalon;

public interface VentaSalonRepository extends JpaRepository<VentaSalon, Integer> {

    List<VentaSalon> findByVenta_IdVenta(Integer id);

}
