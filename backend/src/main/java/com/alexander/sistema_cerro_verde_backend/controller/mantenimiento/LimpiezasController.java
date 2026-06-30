package com.alexander.sistema_cerro_verde_backend.controller.mantenimiento;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;
import com.alexander.sistema_cerro_verde_backend.service.mantenimiento.jpa.LimpiezasService;



@RestController
@RequestMapping("/cerro-verde/limpiezas")
@CrossOrigin("*")
public class LimpiezasController {
    @Autowired
    private LimpiezasService serviceLimpiezas;
    
    @GetMapping("/ver") //Ver
    public List<Limpiezas> buscarTodos() {
        return serviceLimpiezas.buscarTodos();
    }

    @GetMapping("/limpiezas/{id}") //Ver por Id
    public Optional<Limpiezas> buscarPorId(@PathVariable Integer id){
        return serviceLimpiezas.buscarPorId(id);
    }

    @PostMapping("/registrar") //Registrar
    public Limpiezas registrar(@RequestBody Limpiezas limpiezas) {
        serviceLimpiezas.registrar(limpiezas);
        return limpiezas;
    }

    @PutMapping("/actualizar/{id}") //Actualizar
    public void actualizar (@PathVariable Integer id, @RequestBody Limpiezas limpiezas){
        serviceLimpiezas.actualizar(id, limpiezas);
    }

    @DeleteMapping("/eliminar/{id}") //Eliminar
    public void eliminarPorId (@PathVariable Integer id){
        serviceLimpiezas.eliminarPorId(id);
    }

}