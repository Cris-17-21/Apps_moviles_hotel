package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.DetalleVenta;

public interface DetalleVentaRepository extends JpaRepository<DetalleVenta, Integer>{
    List<DetalleVenta> findByVenta_IdVenta(Integer id);
    void deleteAllByVenta_IdVenta(Integer id);
}
