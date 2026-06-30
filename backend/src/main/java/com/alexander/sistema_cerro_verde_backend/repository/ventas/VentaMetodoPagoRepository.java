package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaMetodoPago;

public interface VentaMetodoPagoRepository extends JpaRepository<VentaMetodoPago, Integer>{
    void deleteAllByVenta_IdVenta(Integer id);
}
