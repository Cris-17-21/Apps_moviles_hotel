package com.alexander.sistema_cerro_verde_backend.repository.mantenimiento;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;
import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.PersonalLimpieza;


public interface LimpiezasRepository extends JpaRepository <Limpiezas, Integer> {
    boolean existsByPersonal(PersonalLimpieza personal);
}