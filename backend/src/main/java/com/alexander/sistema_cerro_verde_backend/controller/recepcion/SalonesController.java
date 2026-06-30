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
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.SalonesService;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class SalonesController {

    @Autowired
    private SalonesService salonesService;

    @GetMapping("/salones")
    public List<Salones> buscarTodos() {
        return salonesService.buscarTodos();
    }

    @PostMapping("/salones")
    public Salones guardar(@RequestBody Salones salon) {   
        salonesService.guardar(salon);     
        return salon;
    }

    
    @PutMapping("/salones/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody Salones salon) {
    
    try {
        salon.setId_salon(id); // Asegura que use el ID de la URL
        Salones actualizada = salonesService.modificar(salon);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/salones/{id}")
    public Optional<Salones> buscarId(@PathVariable("id") Integer id) {
        return salonesService.buscarId(id);
    }

    @DeleteMapping("/salones/eliminar/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id){
        salonesService.eliminar(id);
        return ResponseEntity.noContent().build(); // HTTP 204
    }
    
}

