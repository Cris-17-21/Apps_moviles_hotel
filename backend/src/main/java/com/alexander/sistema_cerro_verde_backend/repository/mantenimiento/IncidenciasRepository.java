package com.alexander.sistema_cerro_verde_backend.repository.mantenimiento;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.AreasHotel;
import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Incidencias;
import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.TipoIncidencia;


public interface IncidenciasRepository extends JpaRepository <Incidencias, Integer>{
    boolean existsByArea(AreasHotel area);
    boolean existsByTipoIncidencia(TipoIncidencia tipo);
}