package com.alexander.sistema_cerro_verde_backend.controller.compras;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.service.compras.IDetallesCompraService;

@RestController
@RequestMapping("/api")
@CrossOrigin("*")
public class DetallesCompraController {
    @Autowired
    private IDetallesCompraService serviceDetallesCompra;
    @DeleteMapping("/detallescompra/{id}")
    public void eliminar(@PathVariable("id") Integer idCompra){
        serviceDetallesCompra.eliminarDetalleCompra(idCompra);
    }
}