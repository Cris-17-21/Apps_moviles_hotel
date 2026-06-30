package com.alexander.sistema_cerro_verde_backend.service.compras.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.compras.Proveedores;
import com.alexander.sistema_cerro_verde_backend.repository.compras.ProveedoresRepository;
import com.alexander.sistema_cerro_verde_backend.service.compras.IProveedoresService;

@Service
public class ProveedoresService implements IProveedoresService {

    @Autowired
    private ProveedoresRepository repoProveedores;

    @Override
    public List<Proveedores> buscarTodos() { //Buscar todos los proveedores
        return repoProveedores.findAll();
    }

    @Override
    public void guardar(Proveedores proveedor) {
        repoProveedores.save(proveedor);
    }

    @Override
    public void modificar(Proveedores proveedor) {
        repoProveedores.save(proveedor);
    }

    @Override
    public Optional<Proveedores> buscarId(String ruc_proveedor) {
        return repoProveedores.findById(ruc_proveedor);
    }

    @Override
    public void eliminar(String ruc_proveedor) {
        repoProveedores.deleteById(ruc_proveedor);
    }
}
