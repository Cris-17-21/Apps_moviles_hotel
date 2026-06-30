package com.alexander.sistema_cerro_verde_backend.controller.caja;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.dto.cajaresumen.ResumenPagosDTO;
import com.alexander.sistema_cerro_verde_backend.dto.cajaresumen.VentaCajaDTO;
import com.alexander.sistema_cerro_verde_backend.service.caja.resumen.CajaPdfService;

@CrossOrigin("*")
@RestController
@RequestMapping("/cerro-verde/resumencaja")
public class CajaPdfController {

    @Autowired
    private CajaPdfService cajaPdfService;

    @GetMapping("/reporte-pdf")
    public ResponseEntity<byte[]> generarReportePdf(@RequestParam Integer idCaja) throws IOException {
        List<VentaCajaDTO> ventas = cajaPdfService.obtenerVentasDesdeCaja(idCaja);
        byte[] pdf = cajaPdfService.generarPdfCaja(ventas);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=cierre_caja_" + idCaja + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    @GetMapping("/resumen-ventas-tipo-pago")
    public ResponseEntity<ResumenPagosDTO> resumenPorTipoPago(@RequestParam Integer idCaja) {
        return ResponseEntity.ok(cajaPdfService.resumenPorTipoDePago(idCaja));
    }

}
