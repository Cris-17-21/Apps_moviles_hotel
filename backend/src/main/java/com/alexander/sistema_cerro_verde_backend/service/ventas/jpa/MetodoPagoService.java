package com.alexander.sistema_cerro_verde_backend.service.ventas.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.MetodosPago;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.MetodoPagoRepository;
import com.alexander.sistema_cerro_verde_backend.service.ventas.IMetodoPagoService;

@Service
public class MetodoPagoService implements IMetodoPagoService {

    @Autowired
    private MetodoPagoRepository repoMetodo;

    @Override
    public List<MetodosPago> buscarTodos() { //Listar todos los métodos de pago
        return repoMetodo.findAll();
    }

    @Override
    public Optional<MetodosPago> buscarPorId(Integer id) { //Buscar método de pago por el ID
        return repoMetodo.findById(id);
    }

    @Override
    public void registrar(MetodosPago metodo) { //Registrar método de pago
        repoMetodo.save(metodo);
    }

    @Override
    public void modificar(MetodosPago metodo) { //Modificar el método de pago
        repoMetodo.save(metodo);
    }

    @Override
    public void eliminar(Integer id) { //Eliminar el método de pago por el ID
        if (repoMetodo.countVentasByMetodoPagoId(id) > 0) {
            throw new DataIntegrityViolationException("El método de pago está relacionado con una o muchas ventas");
        }
        repoMetodo.deleteById(id);
    }
}
