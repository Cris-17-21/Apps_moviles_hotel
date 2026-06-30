package com.alexander.sistema_cerro_verde_backend.controller.IA;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.IA.PrecioRequest;
import com.alexander.sistema_cerro_verde_backend.entity.IA.PrecioResponse;
import com.alexander.sistema_cerro_verde_backend.service.IA.PrecioService;

@RestController
@CrossOrigin("*")
@RequestMapping("/cerro-verde")
public class PrecioController {

    private final PrecioService precioService = new PrecioService();

    @PostMapping("/consultar-precio")
    public PrecioResponse consultarPrecio(@RequestBody PrecioRequest request) {
        return precioService.predecirPrecio(request.getFecha());
    }
}
