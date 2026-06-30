package com.alexander.sistema_cerro_verde_backend.controller.seguridad;
import java.util.List;

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

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Modulos;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Permisos;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.IModulosService;

    @RestController
    @RequestMapping("/cerro-verde")
    @CrossOrigin("*") 
    public class ModuloController {

        @Autowired
        private IModulosService moduloService;

        @PostMapping("/modulos/")
        public Modulos guardarModulo(@RequestBody Modulos modulo) throws Exception{
            return moduloService.crearModulo(modulo);
        }
    
        @PutMapping("/modulos/{id}")
        public ResponseEntity<Modulos> actualizarModulo(@PathVariable Integer id, @RequestBody Modulos modulo) {
            modulo.setIdModulo(id); 
            Modulos actualizado = moduloService.editarModulo(modulo);
            return ResponseEntity.ok(actualizado);
        }  

        @GetMapping("/modulos/")
        public List<Modulos> listarUsuarios(){
            return moduloService.obtenerTodosLooModulos();
        }
        
        @GetMapping("/modulos/{idModulo}")
        public Modulos obtenerModulo(@PathVariable("idModulo") Integer idModulo) {
            return moduloService.obtenerModuloId(idModulo);
        }

        @DeleteMapping("/modulos/{id}")
        public void eliminarPermiso(@PathVariable("id") Integer id) {
            moduloService.eliminarModulo(id);
        }
        
        @GetMapping("/modulos/{idModulo}/permisos")
        public List<Permisos> obtenerPermisosPorModulo(@PathVariable Integer idModulo) {
            return moduloService.obtenerPermisosPorModulo(idModulo);
        }
    }
