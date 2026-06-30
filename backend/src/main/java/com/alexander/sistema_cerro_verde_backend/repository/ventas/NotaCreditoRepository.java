package com.alexander.sistema_cerro_verde_backend.repository.ventas;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.NotaCredito;

import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;

public interface NotaCreditoRepository extends JpaRepository<NotaCredito, Integer> {

    @EntityGraph(attributePaths = {
        "venta",
        "venta.cliente",
        "venta.comprobantePago",
        "venta.detalleVenta",
        "venta.ventaHabitacion",
        "venta.ventaSalon",
        "venta.ventaHabitacion.habitacion",
        "venta.ventaSalon.salon"
    })
    Optional<NotaCredito> findById(Integer id);

    @Query("SELECT n FROM NotaCredito n WHERE n.venta.id = :idVenta")
    Optional<NotaCredito> findByVentaId(@Param("idVenta") Integer idVenta);
}
