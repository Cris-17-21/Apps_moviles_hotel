package com.alexander.sistema_cerro_verde_backend.service.caja.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.DenominacionDinero;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoDenominacion;
import com.alexander.sistema_cerro_verde_backend.repository.caja.DenominacionDineroRepository;
import com.alexander.sistema_cerro_verde_backend.service.caja.DenominacionDineroService;

@Service
public class DenominacionDineroServiceImpl implements DenominacionDineroService {

    @Autowired
    private DenominacionDineroRepository repository;

    @Override
    @Transactional(readOnly = true)
    public List<DenominacionDinero> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<DenominacionDinero> buscarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DenominacionDinero> buscarPorTipo(TipoDenominacion tipo) {
        return repository.findByTipo(tipo);
    }

}
