package com.alexander.sistema_cerro_verde_backend.repository.caja;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;

public interface TransaccionesCajaRepository extends JpaRepository<TransaccionesCaja, Integer> {

    List<TransaccionesCaja> findByCaja(Cajas caja);

    @Query("SELECT t FROM TransaccionesCaja t WHERE t.venta.idVenta = :idVenta AND t.tipo.id = :tipoId")
    List<TransaccionesCaja> findByVentaIdAndTipoId(@Param("idVenta") Integer idVenta, @Param("tipoId") Integer tipoId);

    @Query("SELECT t FROM TransaccionesCaja t WHERE t.venta.idVenta = :idVenta AND t.tipo.id = :tipoId AND t.metodoPago.idMetodoPago = :idMetodoPago")
    List<TransaccionesCaja> findByVentaIdAndMetodoPagoIdAndTipoId(
            @Param("idVenta") Integer idVenta,
            @Param("tipoId") Integer tipoId,
            @Param("idMetodoPago") Integer idMetodoPago
    );

    List<TransaccionesCaja> findByVenta(Ventas venta);

}
