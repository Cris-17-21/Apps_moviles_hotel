package com.alexander.sistema_cerro_verde_backend.service.compras.jpa;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.repository.compras.DetallesCompraRepository;
import com.alexander.sistema_cerro_verde_backend.service.compras.IDetallesCompraService;

@Service
public class DetallesCompraService implements IDetallesCompraService{
    @Autowired
    private DetallesCompraRepository repoDetallesCompra;
    
    @Override
    public void eliminarDetalleCompra (Integer idCompra) {
        repoDetallesCompra.eliminarPorIdCompra(idCompra);
    }
}