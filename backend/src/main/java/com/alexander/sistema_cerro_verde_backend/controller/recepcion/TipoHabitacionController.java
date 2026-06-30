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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.TipoHabitacion;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.TipoHabitacionService;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class TipoHabitacionController {

    @Autowired
    private TipoHabitacionService tipoHabitacionService;

    @GetMapping("/habitaciones/tipo")
    public List<TipoHabitacion> buscarTodos() {
        return tipoHabitacionService.buscarTodos();
    }

    @PostMapping("/habitaciones/tipo")
    public TipoHabitacion guardar(@RequestBody TipoHabitacion tipo) {   
        tipoHabitacionService.guardar(tipo);     
        return tipo;
    }
    
    @PutMapping("/habitaciones/tipo/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody TipoHabitacion tipo) {
    
    try {
        tipo.setId_tipo_habitacion(id); // Asegura que use el ID de la URL
        TipoHabitacion actualizada = tipoHabitacionService.modificar(tipo);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/habitaciones/tipo/{id}")
    public Optional<TipoHabitacion> buscarId(@PathVariable("id") Integer id) {
        return tipoHabitacionService.buscarId(id);
    }

    @DeleteMapping("/habitaciones/tipo/{id}")
    public String eliminar(@PathVariable Integer id){
        tipoHabitacionService.eliminar(id);
        return "Tipo de habitacion eliminada";
    }
}
