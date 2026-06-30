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

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.SalonesXReserva;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.jpa.SalonesReservaServiceImpl;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class SalonesReservaController {

    @Autowired
    private SalonesReservaServiceImpl salreservaService;

    @GetMapping("/salonreservas")
    public List<SalonesXReserva> buscarTodos() {
        return salreservaService.buscarTodos();
    }

    @PostMapping("/salonreservas")
    public SalonesXReserva guardar(@RequestBody SalonesXReserva salreserva) {   
        salreservaService.guardar(salreserva);     
        return salreserva;
    }

    
    @PutMapping("/salonreservas/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody SalonesXReserva salreserva) {
    
    try {
        salreserva.getId_salon_reserv(); // Asegura que use el ID de la URL
        SalonesXReserva actualizada = salreservaService.modificar(salreserva);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/salonreservas/{id}")
    public Optional<SalonesXReserva> buscarId(@PathVariable("id") Integer id) {
        return salreservaService.buscarId(id);
    }

    @DeleteMapping("/salonreservas/eliminar/{id}")
    public String eliminar(@PathVariable Integer id){
        salreservaService.eliminar(id);
        return "Salón relacionado a la reserva eliminada";
    }
    
}
