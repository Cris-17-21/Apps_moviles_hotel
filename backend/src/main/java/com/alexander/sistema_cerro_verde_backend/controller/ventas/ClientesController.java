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

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;
import com.alexander.sistema_cerro_verde_backend.service.ventas.ApiCliente;
import com.alexander.sistema_cerro_verde_backend.service.ventas.ClientesService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class ClientesController {

    @Autowired
    private ClientesService serviceClientes;
    @Autowired
    private ApiCliente api;

    @GetMapping("/clientes")
    public List<Clientes> buscarTodos() {
        return serviceClientes.buscarTodos();
    }

    @GetMapping("/clientes/{id}")
    public Optional<Clientes> buscarPorId(@PathVariable("id") Integer id) {
        return serviceClientes.buscarPorId(id);
    }

    @PostMapping("/clientes")
    public Clientes guardar(@RequestBody Clientes cliente) {
        serviceClientes.guardar(cliente);
        return cliente;
    }

    @PutMapping("/clientes")
    public Clientes modificar(@RequestBody Clientes cliente) {
        serviceClientes.modificar(cliente);
        return cliente;
    }

    @DeleteMapping("/clientes/{id}")
    public ResponseEntity<?> eliminar(@PathVariable("id") Integer id) {
        try {
            serviceClientes.eliminar(id);
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Cliente eliminado correctamente");
            return ResponseEntity.ok(response);
        } catch (DataIntegrityViolationException e) {
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Ocurrió un problema. Vuelva a intentarlo");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/dni/{id}")
    public ResponseEntity<Map<String, String>> buscarDni(@PathVariable("id") String dni) {
        String resultado = api.consumirApi(dni);
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("datos", resultado);
        System.out.println(resultado);
        return ResponseEntity.ok(respuesta);
    }
}
