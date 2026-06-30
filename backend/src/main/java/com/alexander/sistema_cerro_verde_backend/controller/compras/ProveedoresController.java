package com.alexander.sistema_cerro_verde_backend.controller.compras;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

import com.alexander.sistema_cerro_verde_backend.entity.compras.Proveedores;
import com.alexander.sistema_cerro_verde_backend.service.compras.ApiService;
import com.alexander.sistema_cerro_verde_backend.service.compras.jpa.ProveedoresService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class ProveedoresController {

    @Autowired
    private ProveedoresService serviceProveedores;
    @Autowired
    private ApiService api;

    @GetMapping("/proveedores")
    public List<Proveedores> buscarTodos() { //Listar todos los proveedores
        return serviceProveedores.buscarTodos(); 
    }

    @PostMapping("/proveedores")
    public Proveedores guardar(@RequestBody Proveedores proveedor) {
        serviceProveedores.guardar(proveedor);
        return proveedor;
    }
    @PutMapping("/proveedores")
    public Proveedores modificar(@RequestBody Proveedores proveedor) {
        serviceProveedores.modificar(proveedor);
        return proveedor;
    }
    @GetMapping("/proveedores/{id}")
    public Optional<Proveedores> buscarId(@PathVariable("id") String ruc_proveedor) {
        return serviceProveedores.buscarId(ruc_proveedor);
    }
    @DeleteMapping("/proveedores/{id}")
    public ResponseEntity<Map<String, String>> eliminar(@PathVariable("id") String ruc_proveedor){
        serviceProveedores.eliminar(ruc_proveedor);
        return ResponseEntity.ok(Collections.singletonMap("mensaje", "Proveedor eliminado"));
    }
    @GetMapping("/ruc/{id}")
    public ResponseEntity<Map<String, String>> buscarRuc(@PathVariable("id") String ruc) {
        String resultado = api.consumirApi(ruc);
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("datos", resultado);
        return ResponseEntity.ok(respuesta);
    } 
}