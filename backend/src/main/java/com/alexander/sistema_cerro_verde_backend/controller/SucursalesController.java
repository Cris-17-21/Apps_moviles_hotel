package com.alexander.sistema_cerro_verde_backend.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.repository.administrable.SucursalesRepository;

@CrossOrigin("*")
@RestController
@RequestMapping("/cerro-verde")
public class SucursalesController {

    @Autowired
    private SucursalesRepository sucursalesRepository;

    @GetMapping("/sucursales")
    public List<Sucursales> buscarTodos() {
        return sucursalesRepository.findAll();
    }
}
