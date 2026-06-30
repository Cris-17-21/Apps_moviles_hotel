package com.alexander.sistema_cerro_verde_backend.service.caja.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.DetalleArqueo;
import com.alexander.sistema_cerro_verde_backend.repository.caja.DetalleArqueoRepository;
import com.alexander.sistema_cerro_verde_backend.service.caja.DetalleArqueoService;

@Service
public class DetalleArqueoCajaServiceImpl implements DetalleArqueoService {

    @Autowired
    private DetalleArqueoRepository repository;

    @Override
    @Transactional(readOnly = true)
    public List<DetalleArqueo> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<DetalleArqueo> buscarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    @Transactional
    public DetalleArqueo guardar(DetalleArqueo arqueo) {
        return repository.save(arqueo);
    }

    @Override
    @Transactional
    public void eliminarId(Integer id) {
        repository.deleteById(id);
    }
 
}
