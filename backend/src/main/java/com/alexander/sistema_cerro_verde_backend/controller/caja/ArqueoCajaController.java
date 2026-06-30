package com.alexander.sistema_cerro_verde_backend.controller.caja;

import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.caja.ArqueosCaja;
import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.caja.DenominacionDinero;
import com.alexander.sistema_cerro_verde_backend.entity.caja.DetalleArqueo;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.UsuariosRepository;
import com.alexander.sistema_cerro_verde_backend.service.caja.ArqueosCajaService;
import com.alexander.sistema_cerro_verde_backend.service.caja.CajasService;
import com.alexander.sistema_cerro_verde_backend.service.caja.DenominacionDineroService;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;


@CrossOrigin("*")
@RestController
@RequestMapping("/cerro-verde/caja/arqueo")
public class ArqueoCajaController {

    @Autowired
    private CajasService cajasService;

    @Autowired
    private ArqueosCajaService arqueosCajaService;

    @Autowired
    private DenominacionDineroService denominacionDineroService;

    @Autowired
    private UsuariosRepository usuarioRepository;

    private Usuarios getUsuarioAutenticado() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        return usuarioRepository.findByUsername(username);
    }

    @GetMapping("/denominaciones")
    public ResponseEntity<List<DenominacionDinero>> obtenerDenominaciones() {
        List<DenominacionDinero> denominaciones = denominacionDineroService.buscarTodos();
        return ResponseEntity.ok(denominaciones);
    }

    @GetMapping
    public ResponseEntity<?> obtenerArqueosDeCajaActual() {
        Usuarios usuario = getUsuarioAutenticado();
        Optional<Cajas> cajaOpt = cajasService.buscarCajaPorUsuario(usuario);

        if (cajaOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No hay caja asociada al usuario.");
        }

        List<ArqueosCaja> arqueos = arqueosCajaService.buscarTodosPorCaja(cajaOpt.get());
        return ResponseEntity.ok(arqueos);
    }
    
    
    @PostMapping("/crear")
    public ResponseEntity<?> realizarArqueo(@RequestBody ArqueosCaja arqueo) {
        Usuarios usuario = getUsuarioAutenticado();
        Optional<Cajas> cajaAperturadaOpt = cajasService.buscarCajaAperturadaPorUsuario(usuario);
        if (cajaAperturadaOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("No hay una caja aperturada actualmente.");
        }
    
        Cajas cajaAperturada = cajaAperturadaOpt.get();
        arqueo.setCaja(cajaAperturada); // Asociar la caja
    
        // Asociar cada detalle con el arqueo (para la relación bidireccional)
        if (arqueo.getDetalles() != null) {
            for (DetalleArqueo detalle : arqueo.getDetalles()) {
                detalle.setArqueo(arqueo);

                if (detalle.getDenominacion() != null && detalle.getDenominacion().getId() != null) {
                    Optional<DenominacionDinero> denominacionOpt = denominacionDineroService.buscarId(detalle.getDenominacion().getId());
                    DenominacionDinero denominacion = denominacionOpt.get();
                    detalle.setDenominacion(denominacion);
                }
            }
        }

        double montoTotal = 0.0;

        for (DetalleArqueo detalle : arqueo.getDetalles()) {
            montoTotal += detalle.getCantidad() * detalle.getDenominacion().getValor();
        }
        
        arqueo.setTotalArqueo(montoTotal);

        arqueo.setFechaArqueo(new Date());
    
        ArqueosCaja arqueoGuardado = arqueosCajaService.guardar(arqueo);
    
        return ResponseEntity.ok(arqueoGuardado);
    }
    

    @GetMapping("/{id}")
    public ResponseEntity<ArqueosCaja> obtenerArqueoPorId(@PathVariable Integer id) {
        
        Optional<ArqueosCaja> arqueo = arqueosCajaService.buscarId(id);
        
        if (arqueo.isPresent()) {
            ArqueosCaja arqueoExistente = arqueo.get();
            return ResponseEntity.ok(arqueoExistente);
        }

        return ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<ArqueosCaja> actualizarArqueo(@PathVariable Integer id, @RequestBody ArqueosCaja arqueoActualizado) {
        Optional<ArqueosCaja> arqueoOpt = arqueosCajaService.buscarId(id);
    
        if (arqueoOpt.isPresent()) {
            ArqueosCaja arqueoExistente = arqueoOpt.get();
    
            // Actualizar observaciones y caja
            arqueoExistente.setObservaciones(arqueoActualizado.getObservaciones());
    
            // Limpiar detalles antiguos
            arqueoExistente.getDetalles().clear();
    
            // Agregar los nuevos detalles
            for (DetalleArqueo nuevoDetalle : arqueoActualizado.getDetalles()) {
                nuevoDetalle.setArqueo(arqueoExistente); // establecer la relación
                arqueoExistente.getDetalles().add(nuevoDetalle);
            }
    
            ArqueosCaja actualizado = arqueosCajaService.guardar(arqueoExistente);
            return ResponseEntity.ok(actualizado);
        }
    
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/caja/{idCaja}")
    public ResponseEntity<List<ArqueosCaja>> obtenerArqueoPorCaja(@PathVariable Integer idCaja) {
        Optional<Cajas> cajaOpt = cajasService.buscarId(idCaja);
        if (cajaOpt.isPresent()) {
            Cajas caja = cajaOpt.get();
            return ResponseEntity.ok(arqueosCajaService.buscarTodosPorCaja(caja));
        }
        return ResponseEntity.notFound().build();
    }
    
}
    
