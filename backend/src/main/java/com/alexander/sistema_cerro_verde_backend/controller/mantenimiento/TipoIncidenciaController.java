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

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.TipoIncidencia;
import com.alexander.sistema_cerro_verde_backend.repository.mantenimiento.IncidenciasRepository;
import com.alexander.sistema_cerro_verde_backend.service.mantenimiento.jpa.TipoIncidenciaService;



@RestController
@RequestMapping("/cerro-verde/tipoincidencia")
@CrossOrigin("*")
public class TipoIncidenciaController {
    @Autowired
    private TipoIncidenciaService serviceTipoIncidencia;
    
    @Autowired
    private IncidenciasRepository incidenciasRepository;

    @GetMapping("/ver") //Ver
    public List<TipoIncidencia> buscarTodos() {
        return serviceTipoIncidencia.buscarTodos();
    }

    @GetMapping("/tipoincidencia/{id}") //Ver por Id
    public Optional<TipoIncidencia> buscarPorId(@PathVariable Integer id){
        return serviceTipoIncidencia.buscarPorId(id);
    }

    @PostMapping("/registrar") //Registrar
    public TipoIncidencia registrar(@RequestBody TipoIncidencia tipoincidencia) {
        serviceTipoIncidencia.registrar(tipoincidencia);
        return tipoincidencia;
    }

    @PutMapping("/actualizar/{id}") //Actualizar
    public void actualizar (@PathVariable Integer id, @RequestBody TipoIncidencia tipoincidencia){
        serviceTipoIncidencia.actualizar(id, tipoincidencia);
    }

    @DeleteMapping("/eliminar/{id}")
    public ResponseEntity<?> eliminarTipoIncidencia(@PathVariable Integer id) {
        Optional<TipoIncidencia> tipoOpt = serviceTipoIncidencia.buscarPorId(id);
        if (tipoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        TipoIncidencia tipo = tipoOpt.get();
        if (incidenciasRepository.existsByTipoIncidencia(tipo)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                .body("No se puede eliminar este tipo de incidencia porque tiene incidencias asociadas.");
        }

        serviceTipoIncidencia.eliminarPorId(id); // o eliminación lógica si usás @SQLDelete
        return ResponseEntity.ok().build();
    }

}