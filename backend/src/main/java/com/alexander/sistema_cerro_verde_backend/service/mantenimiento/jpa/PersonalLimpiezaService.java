package com.alexander.sistema_cerro_verde_backend.service.mantenimiento.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import com.alexander.sistema_cerro_verde_backend.repository.mantenimiento.PersonalLimpiezaRepository;
import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.PersonalLimpieza;
import com.alexander.sistema_cerro_verde_backend.service.mantenimiento.IPersonalLimpiezaService;

@Service
public class PersonalLimpiezaService implements IPersonalLimpiezaService{
    @Autowired
    private PersonalLimpiezaRepository repoPersonalLimpieza;

    @Override //buscar todos
    public List<PersonalLimpieza> buscarTodos() {
        return repoPersonalLimpieza.findAll();
    }

    @Override //Buscar por id
    public Optional<PersonalLimpieza> buscarPorId(Integer id) {
        return repoPersonalLimpieza.findById(id);
    }

    @Override //Registrar
    public void registrar(PersonalLimpieza areashotel) {
        repoPersonalLimpieza.save(areashotel);
    }

    @Override //Actualizar
    public void actualizar (Integer id, PersonalLimpieza areashotel) {
        PersonalLimpieza metodoActualizar = repoPersonalLimpieza.findById(id).orElse(null);
        metodoActualizar.setNombres(areashotel.getNombres());
        repoPersonalLimpieza.save(metodoActualizar);
    }

    @Override //Eliminar
    public void eliminarPorId(Integer id) {
        repoPersonalLimpieza.deleteById(id);
    }
}