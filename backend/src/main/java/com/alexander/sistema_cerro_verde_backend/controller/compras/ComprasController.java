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

import com.alexander.sistema_cerro_verde_backend.entity.compras.Compras;
import com.alexander.sistema_cerro_verde_backend.service.compras.IComprasService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class ComprasController {

    @Autowired
    private IComprasService serviceCompras;

    @GetMapping("/compras")
    public List<Compras> buscarTodos() {
        return serviceCompras.buscarTodos(); //findAll
    }

    @PostMapping("/compras")
    public Compras guardar(@RequestBody Compras compra) {
        serviceCompras.guardar(compra);
        return compra;
    }

    @PutMapping("/compras")
    public Compras modificar(@RequestBody Compras compra) {
        serviceCompras.modificar(compra);
        return compra;
    }

    @GetMapping("/compras/{id}")
    public Optional<Compras> buscarId(@PathVariable("id") Integer id_compra) {
        return serviceCompras.buscarId(id_compra);
    }

    @DeleteMapping("/compras/{id}")
    public ResponseEntity<Map<String, String>> eliminar(@PathVariable("id") Integer id_compra) {
        serviceCompras.eliminar(id_compra);
        return ResponseEntity.ok(Collections.singletonMap("mensaje", "Categoria eliminado"));
    }

    @GetMapping("/datos-nuevacompra")
    public Map<String, String> obtenerDatosNuevaCompra() {
        Map<String, String> datos = new HashMap<>();
        datos.put("correlativo", serviceCompras.obtenerProximoCorrelativo());
        return datos;
    }
}
