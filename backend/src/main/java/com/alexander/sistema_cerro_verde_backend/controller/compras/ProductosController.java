package com.alexander.sistema_cerro_verde_backend.controller.compras;

import java.util.Collections;
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

import com.alexander.sistema_cerro_verde_backend.entity.compras.Productos;
import com.alexander.sistema_cerro_verde_backend.service.compras.IProductosService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class ProductosController {
    @Autowired
    private IProductosService serviceProductos;

    @GetMapping("/productos")
    public List<Productos> buscarTodos(){
        return serviceProductos.buscarTodos();
    }

    @PostMapping("/productos")
    public Productos guardar(@RequestBody Productos producto) {
        serviceProductos.guardar(producto);
        return producto;
    }

    @PutMapping("/productos")
    public Productos modificar(@RequestBody Productos producto) {
        serviceProductos.modificar(producto);
        return producto;
    }

    @GetMapping("/productos/{id}")
    public Optional<Productos> buscarId(@PathVariable("id") Integer id_producto) {
        return serviceProductos.buscarId(id_producto);
    }

    @DeleteMapping("/productos/{id}")
    public ResponseEntity<Map<String, String>> eliminar(@PathVariable("id") Integer id_producto){
        serviceProductos.eliminar(id_producto);
        return ResponseEntity.ok(Collections.singletonMap("mensaje", "Producto eliminado"));
    }
}