package com.alexander.sistema_cerro_verde_backend.service.mantenimiento.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Incidencias;
import com.alexander.sistema_cerro_verde_backend.repository.mantenimiento.IncidenciasRepository;
import com.alexander.sistema_cerro_verde_backend.service.mantenimiento.IIncidenciasService;



@Service
public class IncidenciasService implements IIncidenciasService{
    @Autowired
    private IncidenciasRepository repoIncidencias;

    @Override //buscar todos con paginación
    public Page<Incidencias> buscarTodos(Pageable pageable) {
        return repoIncidencias.findAll(pageable);
    }

    @Override //Buscar por id
    public Optional<Incidencias> buscarPorId(Integer id) {
        return repoIncidencias.findById(id);
    }

    @Override //Registrar
    public void registrar(Incidencias incidencias) {
        repoIncidencias.save(incidencias);
    }

    @Override //Actualizar
    public void actualizar (Integer id, Incidencias incidencias) {
        Incidencias metodoActualizar = repoIncidencias.findById(id).orElse(null);
        metodoActualizar.setDescripcion(incidencias.getDescripcion());
        metodoActualizar.setEstado_incidencia(incidencias.getEstado_incidencia());
        metodoActualizar.setFecha_registro(incidencias.getFecha_registro());
        metodoActualizar.setFecha_solucion(incidencias.getFecha_solucion());
        metodoActualizar.setGravedad(incidencias.getGravedad());
        repoIncidencias.save(metodoActualizar);
    }

    @Override //Eliminar
    public void eliminarPorId(Integer id) {
        repoIncidencias.deleteById(id);
    }
}