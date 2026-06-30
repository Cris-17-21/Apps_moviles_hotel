package com.alexander.sistema_cerro_verde_backend.controller.ventas;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
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

import com.alexander.sistema_cerro_verde_backend.entity.ventas.MetodosPago;
import com.alexander.sistema_cerro_verde_backend.service.ventas.IMetodoPagoService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class MetodoPagoController {

    @Autowired
    private IMetodoPagoService metodoService;

    @GetMapping("/metodopago")
    public List<MetodosPago> buscarTodos() { //Listar todos los métodos de pago
        return metodoService.buscarTodos();
    }

    @GetMapping("/metodopago/{id}")
    public Optional<MetodosPago> buscarPorId(@PathVariable Integer id) { //Buscar método de pago por el ID
        return metodoService.buscarPorId(id);
    }

    @PostMapping("/metodopago")
    public MetodosPago registrar(@RequestBody MetodosPago metodo) { //Registrar método de pago
        metodoService.registrar(metodo);
        return metodo;
    }

    @PutMapping("/metodopago")
    public MetodosPago modificar(@RequestBody MetodosPago metodo) { //Modificar el método de pago
        metodoService.registrar(metodo);
        return metodo;
    }

    @DeleteMapping("/metodopago/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Integer id) { //Eliminar el método de pago por el ID
        try {
            metodoService.eliminar(id);
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Método de Pago eliminado correctamente");
            return ResponseEntity.ok(response);
        } catch (DataIntegrityViolationException e) {
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
        } 
        catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Ocurrió un problema. Vuelva a intentarlo");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
