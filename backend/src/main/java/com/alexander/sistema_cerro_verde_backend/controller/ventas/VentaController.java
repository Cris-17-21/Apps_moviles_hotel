package com.alexander.sistema_cerro_verde_backend.controller.ventas;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
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

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;
import com.alexander.sistema_cerro_verde_backend.service.ventas.IVentaService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class VentaController {

    @Autowired
    private IVentaService ventaService;

    @RequestMapping("/venta")
    public List<Ventas> buscarTodos() {
        return ventaService.buscarTodos();
    }

    @RequestMapping("/venta/{id}")
    public Optional<Ventas> buscarPorId(@PathVariable Integer id) {
        return ventaService.buscarPorId(id);
    }

    // Endpoint para registrar pago de hospedaje
    @PostMapping("/venta/hospedaje")
    public ResponseEntity<Map<String, Object>> registrarPagoHospedaje(@RequestBody Ventas venta) {
        Map<String, Object> response = new HashMap<>();
        try {
            ventaService.registrarPagoHospedaje(venta);
            response.put("success", true);
            response.put("mensaje", "Pago de hospedaje registrado exitosamente");
            response.put("ventaId", venta.getIdVenta());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Endpoint para registrar venta de productos
    @PostMapping("/venta/productos")
    public ResponseEntity<Map<String, Object>> registrarVentaProductos(@RequestBody Ventas venta) {
        Map<String, Object> response = new HashMap<>();
        try {
            ventaService.registrarVentaProductos(venta);
            response.put("success", true);
            response.put("mensaje", "Venta de productos registrada exitosamente");
            response.put("ventaId", venta.getIdVenta());
            response.put("estado", "pendiente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Endpoint para editar venta de productos (solo pendientes)
    @PutMapping("/venta/productos")
    public ResponseEntity<Map<String, Object>> editarVentaProductos(@RequestBody Ventas venta) {
        Map<String, Object> response = new HashMap<>();
        try {
            ventaService.editarVentaProductos(venta);
            response.put("success", true);
            response.put("mensaje", "Venta de productos editada exitosamente");
            response.put("ventaId", venta.getIdVenta());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    // Endpoint para confirmar venta de productos (generar comprobante)
    @PutMapping("/venta/productos/{id}/confirmar")
    public ResponseEntity<Map<String, Object>> confirmarVentaProductos(
            @PathVariable Integer id,
            @RequestParam String tipoComprobante) {
        Map<String, Object> response = new HashMap<>();
        try {
            ventaService.confirmarVentaProductos(id, tipoComprobante);
            response.put("success", true);
            response.put("mensaje", "Venta confirmada y comprobante generado exitosamente");
            response.put("ventaId", id);
            response.put("estado", "completada");
            response.put("tipoComprobante", tipoComprobante);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @DeleteMapping("/venta/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Integer id) {
        try {
            ventaService.eliminar(id);
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "Venta eliminado correctamente");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("mensaje", "No se pudo eliminar la venta");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/pdf/{id}")
    public ResponseEntity<byte[]> descargarComprobante(@PathVariable Integer id) {
        // Generar el PDF como arreglo de bytes
        byte[] pdfBytes = ventaService.generarPdf(id);

        // Configurar cabeceras HTTP
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);

        // Nombre del archivo dinámico según tipo
        String nombreArchivo = "comprobante_" + id + ".pdf";

        headers.setContentDisposition(ContentDisposition.attachment().filename(nombreArchivo).build());

        return ResponseEntity.ok()
                .headers(headers)
                .body(pdfBytes);
    }

}
