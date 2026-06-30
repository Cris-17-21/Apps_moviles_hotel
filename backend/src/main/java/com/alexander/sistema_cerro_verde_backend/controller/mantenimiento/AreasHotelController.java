package com.alexander.sistema_cerro_verde_backend.controller.mantenimiento;

import java.util.List;
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

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.AreasHotel;
import com.alexander.sistema_cerro_verde_backend.repository.mantenimiento.IncidenciasRepository;
import com.alexander.sistema_cerro_verde_backend.service.mantenimiento.jpa.AreasHotelService;



@RestController
@RequestMapping("/cerro-verde/areashotel")
@CrossOrigin("*")
public class AreasHotelController {
    @Autowired
    private AreasHotelService serviceAreasHotel;

    @Autowired
    private IncidenciasRepository incidenciasRepository;
    
    @GetMapping("/ver") //Ver
    public List<AreasHotel> buscarTodos() {
        return serviceAreasHotel.buscarTodos();
    }

    @GetMapping("/areashotel/{id}") //Ver por Id
    public Optional<AreasHotel> buscarPorId(@PathVariable Integer id){
        return serviceAreasHotel.buscarPorId(id);
    }

    @PostMapping("/registrar") //Registrar
    public AreasHotel registrar(@RequestBody AreasHotel areashotel) {
        serviceAreasHotel.registrar(areashotel);
        return areashotel;
    }

    @PutMapping("/actualizar/{id}") //Actualizar
    public void actualizar (@PathVariable Integer id, @RequestBody AreasHotel areashotel){
        serviceAreasHotel.actualizar(id, areashotel);
    }

    @DeleteMapping("/eliminar/{id}") //Eliminar
    public ResponseEntity<?> eliminarPorId (@PathVariable Integer id){
        Optional<AreasHotel> areaOpt = serviceAreasHotel.buscarPorId(id);
        if (areaOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        AreasHotel area = areaOpt.get();

        if (incidenciasRepository.existsByArea(area)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                .body("No se puede eliminar el área, tiene incidencias asociadas.");
        }
        
        serviceAreasHotel.eliminarPorId(id);

        return ResponseEntity.ok().build();
    }

}