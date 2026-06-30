package com.alexander.sistema_cerro_verde_backend.controller.recepcion;

import java.util.List;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Pisos;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.PisosService;

@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class PisoController {

    @Autowired
    private PisosService pisoService;

    @GetMapping("/pisos")
    public List<Pisos> buscarTodos() {
        return pisoService.buscarTodos();
    }

    @PostMapping("/pisos")
    public Pisos guardar(@RequestBody Pisos piso) {   
        pisoService.guardar(piso);     
        return piso;
    }

    @GetMapping("/pisos/{id}")
    public Optional<Pisos> buscarId(@PathVariable("id") Integer id) {
        return pisoService.buscarId(id);
    }

    @DeleteMapping("/pisos/eliminar/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        pisoService.eliminar(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

}
