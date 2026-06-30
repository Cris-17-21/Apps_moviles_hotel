package com.alexander.sistema_cerro_verde_backend.controller.ventas;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.service.ventas.NotaCreditoService;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.NotaCredito;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class NotaCreditoController {

    @Autowired
    private NotaCreditoService notaCreditoService;

    // Suponiendo que estás en NotaCreditoController
    @GetMapping("/notaCredito/porVenta/{idVenta}")
    public ResponseEntity<NotaCredito> obtenerPorVenta(@PathVariable Integer idVenta) {
        return notaCreditoService.buscarPorVenta(idVenta)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    

    @GetMapping("/notaCredito/{id}/descargar")
public ResponseEntity<byte[]> descargarNotaCredito(@PathVariable("id") Integer id) {
    System.out.println("ID recibido en el endpoint: " + id);

    try {
        NotaCredito notaCredito = notaCreditoService.buscarId(id)
                .orElseThrow(() -> new RuntimeException("Nota de crédito no encontrada"));

        byte[] pdfBytes = notaCredito.getPdfBytes();

        System.out.println("¿PDF existe? " + (pdfBytes != null));
        System.out.println("Tamaño del PDF: " + (pdfBytes != null ? pdfBytes.length : 0));

        if (pdfBytes == null || pdfBytes.length == 0) {
            throw new RuntimeException("PDF no generado o vacío");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=nota_credito_" + id + ".pdf");

        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfBytes);

    } catch (Exception e) {
        e.printStackTrace(); // Ver en consola del backend
        return ResponseEntity.internalServerError().body(null);
    }
}

}
