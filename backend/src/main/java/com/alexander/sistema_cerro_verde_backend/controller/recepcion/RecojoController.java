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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Recojo;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.RecojoService;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class RecojoController {

    @Autowired
    private RecojoService recojoService;

    @GetMapping("/recojos")
    public List<Recojo> buscarTodos() {
        return recojoService.buscarTodos();
    }

    @PostMapping("/recojos")
    public Recojo guardar(@RequestBody Recojo recojo) {   
        recojoService.guardar(recojo);     
        return recojo;
    }

    
    @PutMapping("/recojos/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody Recojo recojo) {
    
    try {
        recojo.setId_recojo(id); // Asegura que use el ID de la URL
        Recojo actualizada = recojoService.modificar(recojo);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/recojos/{id}")
    public Optional<Recojo> buscarId(@PathVariable("id") Integer id) {
        return recojoService.buscarId(id);
    }

    @DeleteMapping("/recojos/eliminar/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        recojoService.eliminar(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

    
}
