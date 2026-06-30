package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.MetodosPago;

public interface MetodoPagoRepository extends JpaRepository<MetodosPago, Integer> {

    @Query("SELECT COUNT(v) FROM VentaMetodoPago v WHERE v.metodoPago.idMetodoPago = :id")
    int countVentasByMetodoPagoId(@Param("id") Integer id);

}
