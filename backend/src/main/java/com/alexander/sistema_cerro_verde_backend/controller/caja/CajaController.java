package com.alexander.sistema_cerro_verde_backend.controller.caja;

import java.util.Date;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.UsuariosRepository;
import com.alexander.sistema_cerro_verde_backend.service.caja.CajasService;
import com.alexander.sistema_cerro_verde_backend.service.caja.TransaccionesCajaService;

@CrossOrigin("*")
@RestController
@RequestMapping("/cerro-verde/caja")
public class CajaController {

    @Autowired
    private CajasService serviceCaja;
    
    @Autowired
    private TransaccionesCajaService transaccionesCajaService;

    @Autowired
    private UsuariosRepository usuarioRepository;

    private Usuarios getUsuarioAutenticado() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        return usuarioRepository.findByUsername(username);
    }

    @GetMapping
    public ResponseEntity<?> verificarEstadoCaja() {
        Usuarios usuario = getUsuarioAutenticado();
    
        Optional<Cajas> caja = serviceCaja.buscarCajaPorUsuario(usuario);
        
        // ✅ Si ya tiene caja, la retornamos
        if (caja.isPresent()) {
            return ResponseEntity.ok(caja.get());
        }
    
        // 🔍 Si no tiene caja y es CAJERO, se le crea una automáticamente
        if (usuario.getRol().getNombreRol().equalsIgnoreCase("RECEPCIONISTA") || usuario.getRol().getNombreRol().equalsIgnoreCase("ADMIN")) {
            Cajas nuevaCaja = new Cajas();
            nuevaCaja.setUsuario(usuario);
            nuevaCaja.setEstadoCaja("cerrada");
            nuevaCaja.setSaldoFisico(0.0);
    
            Cajas cajaGuardada = serviceCaja.guardar(nuevaCaja);
    
            return ResponseEntity.status(HttpStatus.CREATED).body(cajaGuardada);
        }
    
        // ⚠️ Si no es CAJERO y no tiene caja
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("no existe ninguna caja para el usuario");
    }
    
    

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerCajaPorId(@PathVariable Integer id) {
        Optional<Cajas> caja = serviceCaja.buscarId(id);
        Usuarios usuario = getUsuarioAutenticado();

        if (caja.isPresent() && caja.get().getUsuario().getIdUsuario().equals(usuario.getIdUsuario())) {
            return ResponseEntity.ok(caja.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Caja no encontrada o no autorizada");
        }
    }

    @PostMapping("/aperturar")
    public ResponseEntity<?> aperturarCaja(@RequestBody(required = false) Cajas cajaRequest) {
        Usuarios usuario = getUsuarioAutenticado();
        if (usuario == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    
        Optional<Cajas> cajaExistenteOpt = serviceCaja.buscarCajaPorUsuario(usuario);
    
        // 🚨 Primera vez: NO hay caja asignada
        if (cajaExistenteOpt.isEmpty()) {
            if (cajaRequest == null || cajaRequest.getMontoApertura() == null) {
                return ResponseEntity.badRequest().body("Se requiere un monto de apertura inicial.");
            }
    
            Cajas nuevaCaja = new Cajas();
            nuevaCaja.setUsuario(usuario);
            nuevaCaja.setEstadoCaja("abierta");
            nuevaCaja.setFechaApertura(new Date());
            nuevaCaja.setMontoApertura(cajaRequest.getMontoApertura());
            nuevaCaja.setSaldoFisico(cajaRequest.getMontoApertura());
            nuevaCaja.setSaldoTotal(cajaRequest.getMontoApertura());
    
            return ResponseEntity.ok(serviceCaja.guardar(nuevaCaja));
        }
    
        // 🧠 Caja ya existe → reapertura
        Cajas caja = cajaExistenteOpt.get();
    
        if ("abierta".equalsIgnoreCase(caja.getEstadoCaja())) {
            return ResponseEntity.badRequest().body("La caja ya está aperturada.");
        }
    
        if (caja.getSaldoFisico() == null) {
            return ResponseEntity.badRequest().body("No se puede reaperturar porque el saldo físico anterior es nulo.");
        }
    
        // ✅ Si se mandó un nuevo monto, úsalo
        Double nuevoMonto = (cajaRequest != null && cajaRequest.getMontoApertura() != null)
            ? cajaRequest.getMontoApertura()
            : caja.getSaldoFisico();
    
        caja.setEstadoCaja("abierta");
        caja.setFechaApertura(new Date());
        caja.setMontoApertura(nuevoMonto);
        caja.setSaldoFisico(nuevoMonto);
        caja.setSaldoTotal(nuevoMonto);

        TransaccionesCaja transaccion = new TransaccionesCaja();
        transaccion.setCaja(caja);
        transaccion.setFechaHoraTransaccion(new Date());
        transaccion.setMontoTransaccion(caja.getMontoApertura());

        transaccion.setTipo(transaccionesCajaService.obtenerTipoPorId(3));

        transaccionesCajaService.guardar(transaccion);
    
        return ResponseEntity.ok(serviceCaja.guardar(caja));
    }
    
    
    

    @PostMapping("/cerrar")
    public ResponseEntity<?> cerrarCajaActual(@RequestBody Map<String, Object> body) {
        Usuarios usuario = getUsuarioAutenticado();
        Optional<Cajas> cajaAbierta = serviceCaja.buscarCajaAperturadaPorUsuario(usuario);
    
        if (cajaAbierta.isEmpty()) {
            return ResponseEntity.badRequest().body("No hay una caja aperturada.");
        }
    
        Cajas caja = cajaAbierta.get();
    
        Object montoObj = body.get("montoCierre");
        if (montoObj == null) {
            return ResponseEntity.badRequest().body("El campo 'montoCierre' es requerido.");
        }
        Double montoCierre = ((Number) montoObj).doubleValue();
    
        TransaccionesCaja transaccion = new TransaccionesCaja();
        transaccion.setCaja(caja);
        transaccion.setFechaHoraTransaccion(new Date());
        transaccion.setMontoTransaccion(montoCierre);

        transaccion.setTipo(transaccionesCajaService.obtenerTipoPorId(4));

        transaccionesCajaService.guardar(transaccion);

        caja.setMontoCierre(montoCierre);
        caja.setSaldoFisico(montoCierre);
        caja.setFechaCierre(new Date());
        caja.setEstadoCaja("cerrada");
        caja.setUsuarioCierre(usuario);

        return ResponseEntity.ok(serviceCaja.guardar(caja));
    }

    @GetMapping("/admin/listar")
    public ResponseEntity<?> listarTodasLasCajas() {
    Usuarios usuario = getUsuarioAutenticado();
    
    if (!usuario.getRol().getNombreRol().equalsIgnoreCase("ADMIN")) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No autorizado");
    }

    return ResponseEntity.ok(serviceCaja.buscarTodos());
}

    
}
