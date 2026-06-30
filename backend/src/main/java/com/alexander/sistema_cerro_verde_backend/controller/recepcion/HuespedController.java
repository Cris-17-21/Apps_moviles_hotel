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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Huespedes;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.HuespedesService;

@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class HuespedController {

    @Autowired
    private HuespedesService huespedService;

    @GetMapping("/huespedes")
    public List<Huespedes> buscarTodos() {
        return huespedService.buscarTodos();
    }

    @PostMapping("/huespedes")
    public Huespedes guardar(@RequestBody Huespedes piso) {   
        huespedService.guardar(piso);     
        return piso;
    }

    @GetMapping("/huespedes/{id}")
    public Optional<Huespedes> buscarId(@PathVariable("id") Integer id) {
        return huespedService.buscarId(id);
    }

    @DeleteMapping("/huespedes/eliminar/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        huespedService.eliminar(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

}
