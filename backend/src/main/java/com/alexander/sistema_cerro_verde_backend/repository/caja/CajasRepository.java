package com.alexander.sistema_cerro_verde_backend.repository.caja;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.CajaResumenDTO;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;

public interface CajasRepository extends JpaRepository<Cajas, Integer> {

    Optional<Cajas> findByEstadoCaja(String estadoCaja);

    List<Cajas> findAllByEstadoCaja(String estadoCaja);

    Optional<Cajas> findByUsuarioAndEstadoCaja(Usuarios usuario, String estadoCaja);

    Optional<Cajas> findByUsuario(Usuarios usuario);

    // 1) Resumen global (ingresos vs egresos)
    @Query("""
        SELECT new com.alexander.sistema_cerro_verde_backend.entity.reportes.CajaResumenDTO(
          tt.nombre,
          SUM(tc.montoTransaccion)
        )
        FROM com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja tc
        JOIN tc.tipo tt
        WHERE tc.estado = 1
          AND tc.fechaHoraTransaccion BETWEEN :desde AND :hasta
          AND tt.nombre IN :tipos
        GROUP BY tt.nombre
    """)
    List<CajaResumenDTO> fetchResumenCaja(
      @Param("desde") LocalDateTime desde,
      @Param("hasta") LocalDateTime hasta,
      @Param("tipos") List<String> tipos
    );

   


}
