package com.alexander.sistema_cerro_verde_backend.repository.compras;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;

public interface MovimientosInventarioRepository extends JpaRepository<MovimientosInventario, Integer> {
    @Query("SELECT m FROM MovimientosInventario m WHERE m.tipo_movimiento = 'Entrada'")
    List<MovimientosInventario> listaEntrada ();
    @Query("SELECT m FROM MovimientosInventario m WHERE m.tipo_movimiento = 'Salida'")
    List<MovimientosInventario> listaSalida ();
    @Query("SELECT m FROM MovimientosInventario m WHERE m.fecha BETWEEN :fechaInicio AND :fechaFin")
    List<MovimientosInventario> buscarPorRangoFechas(
        @Param("fechaInicio") LocalDate fechaInicio,
        @Param("fechaFin") LocalDate fechaFin
    );
    void deleteByVenta_IdVenta(Integer id);
}