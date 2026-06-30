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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.HabitacionesXReserva;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa.HabitacionesReservaServiceImpl;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class HabitacionesReservaController {

    @Autowired
    private HabitacionesReservaServiceImpl habreservaService;

    @GetMapping("/habitacionreservas")
    public List<HabitacionesXReserva> buscarTodos() {
        return habreservaService.buscarTodos();
    }

    @PostMapping("/habitacionreservas")
    public HabitacionesXReserva guardar(@RequestBody HabitacionesXReserva habreserva) {   
        habreservaService.guardar(habreserva);     
        return habreserva;
    }

    
    @PutMapping("/habitacionreservas/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody HabitacionesXReserva habreserva) {
    
    try {
        habreserva.setId_hab_reserv(id); // Asegura que use el ID de la URL
        HabitacionesXReserva actualizada = habreservaService.modificar(habreserva);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/habitacionreservas/{id}")
    public Optional<HabitacionesXReserva> buscarId(@PathVariable("id") Integer id) {
        return habreservaService.buscarId(id);
    }

    @DeleteMapping("/habitacionreservas/eliminar/{id}")
    public String eliminar(@PathVariable Integer id){
        habreservaService.eliminar(id);
        return "Habitación relacionada a la reserva eliminada";
    }

        

}
