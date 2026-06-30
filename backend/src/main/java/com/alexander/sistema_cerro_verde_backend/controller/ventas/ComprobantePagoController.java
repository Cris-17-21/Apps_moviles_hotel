package com.alexander.sistema_cerro_verde_backend.controller.ventas;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.ComprobantePago;
import com.alexander.sistema_cerro_verde_backend.service.ventas.IComprobantePagoService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class ComprobantePagoController {

    @Autowired
    private IComprobantePagoService comprobantePagoService;

    @GetMapping("/comprobantes")
    public List<ComprobantePago> buscarTodos() {
        return comprobantePagoService.buscarTodos();
    }

    @GetMapping("/comprobantes/{id}")
    public Optional<ComprobantePago> buscarPorId(@PathVariable Integer id) {
        return comprobantePagoService.buscarPorId(id);
    }

    @PostMapping("/comprobante")
    public ComprobantePago guardar(@RequestBody ComprobantePago comprobante) {
        comprobantePagoService.guardar(comprobante);
        return comprobante;
    }

    @PutMapping("/comprobante")
    public ComprobantePago modificar(@RequestBody ComprobantePago comprobante) {
        comprobantePagoService.modificar(comprobante);
        return comprobante;
    }

    @DeleteMapping("/comprobante/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Integer id) {
        try {
            comprobantePagoService.eliminar(id);
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Comprobante de pago eliminado correctamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "No se pudo eliminar el comprobante de pago");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/venta/siguientecorrelativo")
    public ResponseEntity<Map<String, String>> obtenerCorrelativo(@RequestParam String tipo) {
        String correlativo = comprobantePagoService.generarSiguienteCorrelativo(tipo);

        Map<String, String> response = new HashMap<>();
        response.put("correlativo", correlativo); // solo "000123"

        return ResponseEntity.ok(response);
    }
}
