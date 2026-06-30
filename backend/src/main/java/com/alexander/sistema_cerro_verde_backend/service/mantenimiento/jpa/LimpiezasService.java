package com.alexander.sistema_cerro_verde_backend.service.mantenimiento.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;
import com.alexander.sistema_cerro_verde_backend.repository.mantenimiento.LimpiezasRepository;
import com.alexander.sistema_cerro_verde_backend.service.mantenimiento.ILimpiezasService;



@Service
public class LimpiezasService implements ILimpiezasService{
    @Autowired
    private LimpiezasRepository repoLimpiezas;

    @Override //buscar todos
    public List<Limpiezas> buscarTodos() {
        return repoLimpiezas.findAll();
    }

    @Override //Buscar por id
    public Optional<Limpiezas> buscarPorId(Integer id) {
        return repoLimpiezas.findById(id);
    }

    @Override //Registrar
    public void registrar(Limpiezas limpiezas) {
        repoLimpiezas.save(limpiezas);
    }

    @Override //Actualizar
    public void actualizar (Integer id, Limpiezas limpiezas) {
        Limpiezas metodoActualizar = repoLimpiezas.findById(id).orElse(null);
        metodoActualizar.setFecha_registro(limpiezas.getFecha_registro());
        metodoActualizar.setFecha_solucion(limpiezas.getFecha_solucion());
        metodoActualizar.setEstado_limpieza(limpiezas.getEstado_limpieza());
        metodoActualizar.setObservaciones(limpiezas.getObservaciones());
        repoLimpiezas.save(metodoActualizar);
    }

    @Override //Eliminar
    public void eliminarPorId(Integer id) {
        repoLimpiezas.deleteById(id);
    }
}