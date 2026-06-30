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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.CheckinCheckout;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.CheckinCheckoutService;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class CheckController {

    @Autowired
    private CheckinCheckoutService checkService;

    @GetMapping("/checks")
    public List<CheckinCheckout> buscarTodos() {
        return checkService.buscarTodos();
    }

    @PostMapping("/checks")
    public CheckinCheckout guardar(@RequestBody CheckinCheckout check) {   
        checkService.guardar(check);     
        return check;
    }

    
    @PutMapping("/checks/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody CheckinCheckout check) {
    
    try {
        check.setId_check(id); // Asegura que use el ID de la URL
        CheckinCheckout actualizada = checkService.modificar(check);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/checks/{id}")
    public Optional<CheckinCheckout> buscarId(@PathVariable("id") Integer id) {
        return checkService.buscarId(id);
    }

    @DeleteMapping("/checks/eliminar/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        checkService.eliminar(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

    
}
