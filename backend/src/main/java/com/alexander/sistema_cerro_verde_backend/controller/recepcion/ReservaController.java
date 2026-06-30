package com.alexander.sistema_cerro_verde_backend.controller.recepcion;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
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
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;
import com.alexander.sistema_cerro_verde_backend.service.recepcion.ReservasService;

import jakarta.persistence.EntityNotFoundException;


@CrossOrigin("*") 
@RestController
@RequestMapping("/cerro-verde/recepcion")
public class ReservaController {

    @Autowired
    private ReservasService reservaService;

    @GetMapping("/reservas")
    public List<Reservas> buscarTodos() {
        return reservaService.buscarTodos();
    }

    @PostMapping("/reservas")
    public ResponseEntity<Reservas> guardar(@RequestBody Reservas reserva) {
    Reservas nuevaReserva = reservaService.guardar(reserva);
    return new ResponseEntity<>(nuevaReserva, HttpStatus.CREATED);
    }

    
    @PutMapping("/reservas/{id}")
    public ResponseEntity<?> modificar(
        @PathVariable Integer id,
        @RequestBody Reservas reserva) {
    
    try {
        reserva.setId_reserva(id); // Asegura que use el ID de la URL
        Reservas actualizada = reservaService.modificar(reserva);
        return ResponseEntity.ok(actualizada);
        
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    } catch (Exception e) {
        return ResponseEntity.internalServerError().body("Error al actualizar");
    }
    }

    @GetMapping("/reservas/{id}")
    public Optional<Reservas> buscarId(@PathVariable("id") Integer id) {
        return reservaService.buscarId(id);
    }

    @DeleteMapping("/reservas/eliminar/{id}")
    public ResponseEntity<String> eliminar(@PathVariable Integer id) {
    try {
        // Llamar al servicio para eliminar la reserva (logicamente)
        reservaService.eliminar(id);

        // Respuesta exitosa
        return ResponseEntity.ok("Reserva eliminada lógicamente y relaciones eliminadas.");
    } catch (RuntimeException e) {
        // Si ocurre un error, devolver un mensaje con el detalle del error
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al eliminar la reserva: " + e.getMessage());
    }

    }

    @PutMapping("/cancelar/{id}")
    public ResponseEntity<?> cancelar(@PathVariable Integer id) {
        try {
            reservaService.cancelar(id); // Aquí ya estás cancelando

            return ResponseEntity.ok(Map.of(
                "mensaje", "Reserva cancelada correctamente",
                "reservaId", id
            ));

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", e.getMessage()
            ));
        }
    }
    

}

