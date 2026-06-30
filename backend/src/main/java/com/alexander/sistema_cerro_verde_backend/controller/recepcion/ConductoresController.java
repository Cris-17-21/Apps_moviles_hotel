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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Conductores;
import com.alexander.sistema_cerro_verde_backend.service.PlacaService;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ConductoresService;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class ConductoresController {

    @Autowired
    private ConductoresService conductorService;

    @Autowired
    private PlacaService placaService;

    @GetMapping("/conductores")
    public List<Conductores> buscarTodos() {
        return conductorService.buscarTodos();
    }

    @PostMapping("/conductores")
    public Conductores guardar(@RequestBody Conductores conductor) {   
        conductorService.guardar(conductor);     
        return conductor;
    }

    
    @PutMapping("/conductores/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody Conductores conductor) {
    
    try {
        conductor.setId_conductor(id); // Asegura que use el ID de la URL
        Conductores actualizado = conductorService.modificar(conductor);
        return ResponseEntity.ok(actualizado);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/conductores/{id}")
    public Optional<Conductores> buscarId(@PathVariable("id") Integer id) {
        return conductorService.buscarId(id);
    }

    @DeleteMapping("/conductores/eliminar/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        conductorService.eliminar(id);
        return ResponseEntity.noContent().build(); // 204 No Content
    }

    @GetMapping("/conductores/buscarplaca/{placa}")
    public ResponseEntity<String> buscarPorPlaca(@PathVariable String placa) {
        String resultado = placaService.consultarPlaca(placa);
        return ResponseEntity.ok(resultado);
    }
}
