package com.alexander.sistema_cerro_verde_backend.service.ventas.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.ReservasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.ClientesRepository;
import com.alexander.sistema_cerro_verde_backend.service.ventas.ClientesService;

@Service
public class ClientesServiceImpl implements ClientesService{
    @Autowired
    private ClientesRepository repoClientes;

    @Autowired
    private ReservasRepository repoReservas;

    @Override
    public List<Clientes> buscarTodos() {
        return repoClientes.findAll();
    }

    @Override
    public Optional<Clientes> buscarPorId(Integer id){
        return repoClientes.findById(id);
    }

    @Override
    public void guardar(Clientes cliente){
        repoClientes.save(cliente);
    }

    @Override
    public void modificar(Clientes cliente){
        repoClientes.save(cliente);
    }

    @Override
    public void eliminar(Integer id){
        if (repoReservas.existsReservas(id)) {
            throw new DataIntegrityViolationException("El cliente está relacionado con una o muchas reservas");
        }

        repoClientes.deleteById(id);
    }
}
