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

import com.alexander.sistema_cerro_verde_backend.entity.compras.UnidadMedida;
import com.alexander.sistema_cerro_verde_backend.service.compras.jpa.UnidadMedidaService;


@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class UnidadMedidaController {
@Autowired
    private UnidadMedidaService serviceUnidad;

    @GetMapping("/unidadmedida")
    public List<UnidadMedida> buscarTodos() {
        return serviceUnidad.buscarTodos(); //findAll
    }

    @PostMapping("/unidadmedida")
    public UnidadMedida guardar(@RequestBody UnidadMedida unidad) {
        serviceUnidad.guardar(unidad);
        return unidad;
    }

    @PutMapping("/unidadmedida")
    public UnidadMedida modificar(@RequestBody UnidadMedida unidad) {
        serviceUnidad.modificar(unidad);
        return unidad;
    }

    @GetMapping("/unidadmedida/{id}")
    public Optional<UnidadMedida> buscarId(@PathVariable("id") Integer id_unidad) {
        return serviceUnidad.buscarId(id_unidad);
    }

    @DeleteMapping("/unidadmedida/{id}")
    public ResponseEntity<Map<String, String>> eliminar(@PathVariable("id") Integer id_unidad){
        serviceUnidad.eliminar(id_unidad);
        return ResponseEntity.ok(Collections.singletonMap("mensaje", "Unidad de Medida eliminado"));
    }
}
