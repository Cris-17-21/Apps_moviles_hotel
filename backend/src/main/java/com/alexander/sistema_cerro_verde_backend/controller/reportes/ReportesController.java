package com.alexander.sistema_cerro_verde_backend.controller.reportes;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.springframework.core.io.InputStreamResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProductoReporteDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProveedorReporteDTO;
import com.alexander.sistema_cerro_verde_backend.service.reportes.ReportesService;
import com.alexander.sistema_cerro_verde_backend.service.reportes.jpa.ReportesExportService;

@RestController
@RequestMapping("/cerro-verde/reportes")
@CrossOrigin("*")
public class ReportesController {

    private final ReportesService reportesService;
    private final ReportesExportService reportesExportService;

    public ReportesController(ReportesService reportesService,
                              ReportesExportService reportesExportService) {
        this.reportesService = reportesService;
        this.reportesExportService = reportesExportService;
    }

    // — JSON Productos con filtro de stock —
    @GetMapping("/productos")
    public List<ProductoReporteDTO> getProductosReporte(
            @RequestParam String desde,
            @RequestParam String hasta,
            @RequestParam(required = false) String stockFilter) {
        return reportesService.obtenerProductosMasComprados(desde, hasta, stockFilter);
    }

    // — PDF Productos —
    @GetMapping("/productos/pdf")
    public ResponseEntity<InputStreamResource> downloadPdfProductos(
            @RequestParam String desde,
            @RequestParam String hasta,
            @RequestParam(required = false) String stockFilter) throws IOException {

        List<ProductoReporteDTO> lista =
            reportesService.obtenerProductosMasComprados(desde, hasta, stockFilter);

        ByteArrayInputStream bis = reportesExportService.generarPdfProductos(lista);

        String filename = String.format(
            "productos_reporte_%s_a_%s%s.pdf",
            desde,
            hasta,
            stockFilter != null
                ? "_" + URLEncoder.encode(stockFilter, StandardCharsets.UTF_8)
                : ""
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentDisposition(
            ContentDisposition.attachment().filename(filename).build()
        );
        headers.setContentType(MediaType.APPLICATION_PDF);

        return ResponseEntity.ok()
                .headers(headers)
                .body(new InputStreamResource(bis));
    }

    // — Excel Productos —
    @GetMapping("/productos/excel")
    public ResponseEntity<InputStreamResource> downloadExcelProductos(
            @RequestParam String desde,
            @RequestParam String hasta,
            @RequestParam(required = false) String stockFilter) throws IOException {

        List<ProductoReporteDTO> lista =
            reportesService.obtenerProductosMasComprados(desde, hasta, stockFilter);

        ByteArrayOutputStream baos = reportesExportService.generarExcelProductos(lista);
        ByteArrayInputStream bis = new ByteArrayInputStream(baos.toByteArray());

        String filename = String.format(
            "productos_reporte_%s_a_%s%s.xlsx",
            desde,
            hasta,
            stockFilter != null
                ? "_" + URLEncoder.encode(stockFilter, StandardCharsets.UTF_8)
                : ""
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentDisposition(
            ContentDisposition.attachment().filename(filename).build()
        );
        headers.setContentType(
            MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
        );

        return ResponseEntity.ok()
                .headers(headers)
                .body(new InputStreamResource(bis));
    }

    // — JSON Proveedores —
    @GetMapping("/proveedores")
    public List<ProveedorReporteDTO> getProveedoresReporte(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return reportesService.obtenerProveedoresMasComprados(desde, hasta);
    }

    // — PDF Proveedores —
    @GetMapping("/proveedores/pdf")
    public ResponseEntity<InputStreamResource> downloadPdfProveedores(
            @RequestParam String desde,
            @RequestParam String hasta) throws IOException {

        List<ProveedorReporteDTO> lista =
            reportesService.obtenerProveedoresMasComprados(desde, hasta);

        ByteArrayInputStream bis = reportesExportService.generarPdfProveedores(lista);

        String filename = String.format(
            "proveedores_reporte_%s_a_%s.pdf",
            desde,
            hasta
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentDisposition(
            ContentDisposition.attachment().filename(filename).build()
        );
        headers.setContentType(MediaType.APPLICATION_PDF);

        return ResponseEntity.ok()
                .headers(headers)
                .body(new InputStreamResource(bis));
    }

    // — Excel Proveedores —
    @GetMapping("/proveedores/excel")
    public ResponseEntity<InputStreamResource> downloadExcelProveedores(
            @RequestParam String desde,
            @RequestParam String hasta) throws IOException {

        List<ProveedorReporteDTO> lista =
            reportesService.obtenerProveedoresMasComprados(desde, hasta);

        ByteArrayOutputStream baos = reportesExportService.generarExcelProveedores(lista);
        ByteArrayInputStream bis = new ByteArrayInputStream(baos.toByteArray());

        String filename = String.format(
            "proveedores_reporte_%s_a_%s.xlsx",
            desde,
            hasta
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentDisposition(
            ContentDisposition.attachment().filename(filename).build()
        );
        headers.setContentType(
            MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
        );

        return ResponseEntity.ok()
                .headers(headers)
                .body(new InputStreamResource(bis));
    }
}
