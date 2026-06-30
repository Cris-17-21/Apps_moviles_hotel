package com.alexander.sistema_cerro_verde_backend.controller.reportes;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.CajaResumenDTO;
import com.alexander.sistema_cerro_verde_backend.service.reportes.jpa.CajaReporteService;
import com.itextpdf.io.exceptions.IOException;

@RestController
@RequestMapping("/cerro-verde/reportes/caja")
public class CajaReporteController {

    private static final Logger log = LoggerFactory.getLogger(CajaReporteController.class);

    private final CajaReporteService service;

    public CajaReporteController(CajaReporteService service) {
        this.service = service;
    }

    @GetMapping(path = "/resumen", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<CajaResumenDTO> getResumen(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam("tipos") String tiposCsv
    ) {
        List<String> tipos = Arrays.asList(tiposCsv.split(","));
        LocalDateTime from = desde.atStartOfDay();
        LocalDateTime to   = hasta.atTime(LocalTime.MAX);
        return service.obtenerResumenCaja(from, to, tipos);
    }

    @GetMapping("/resumen/pdf")
    public ResponseEntity<byte[]> getResumenPdf(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam("tipos") String tiposCsv
    ) throws IOException {
        List<String> tipos = Arrays.asList(tiposCsv.split(","));
        LocalDateTime from = desde.atStartOfDay();
        LocalDateTime to   = hasta.atTime(LocalTime.MAX);

        ByteArrayInputStream bis = service.generarPdfResumenCaja(from, to, tipos);
        byte[] pdf = bis.readAllBytes();

        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"resumen_caja.pdf\"")
            .contentType(MediaType.APPLICATION_PDF)
            .body(pdf);
    }

    @GetMapping(
      path = "/resumen/excel",
      produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
    public ResponseEntity<ByteArrayResource> getResumenExcel(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam("tipos") String tiposCsv
    ) {
        try {
            List<String> tipos = Arrays.asList(tiposCsv.split(","));
            LocalDateTime from = desde.atStartOfDay();
            LocalDateTime to   = hasta.atTime(LocalTime.MAX);

            byte[] xlsx = service.generarExcelResumenCaja(from, to, tipos);
            ByteArrayResource resource = new ByteArrayResource(xlsx);

            return ResponseEntity.ok()
              .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"resumen_caja.xlsx\"")
              .contentType(MediaType.parseMediaType(
                  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
              .contentLength(xlsx.length)
              .body(resource);

        } catch (Exception e) {
            log.error("Error generando Excel resumen de caja", e);
            String msg = "Error al generar Excel: " + e.getMessage();
            ByteArrayResource error = new ByteArrayResource(msg.getBytes(StandardCharsets.UTF_8));
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
              .header(HttpHeaders.CONTENT_TYPE, MediaType.TEXT_PLAIN_VALUE)
              .body(error);
        }
    }

}