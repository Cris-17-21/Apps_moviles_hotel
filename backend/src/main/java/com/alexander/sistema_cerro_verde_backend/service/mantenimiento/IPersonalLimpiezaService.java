package com.alexander.sistema_cerro_verde_backend.service.mantenimiento;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.PersonalLimpieza;



public interface IPersonalLimpiezaService {

    List<PersonalLimpieza> buscarTodos();
    Optional<PersonalLimpieza> buscarPorId(Integer id);
    void registrar(PersonalLimpieza personalLimpieza);
    void actualizar(Integer id, PersonalLimpieza personalLimpieza);
    void eliminarPorId(Integer id);

}