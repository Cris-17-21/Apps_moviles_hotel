package com.alexander.sistema_cerro_verde_backend.controller.reportes;

import java.io.ByteArrayInputStream;
import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.ClienteFrecuenteDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.HabitacionVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.HabitacionVentasDetalladoDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.PagoVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.PagoVentasDetalladoDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProductoVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ReservasPorMesDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.SalonVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.SalonVentasDetalladoDTO;
import com.alexander.sistema_cerro_verde_backend.service.reportes.jpa.ReportesVentasService;

@RestController
@RequestMapping("/cerro-verde/reportes/ventas")
public class ReportesVentasController {

    private final ReportesVentasService service;

    public ReportesVentasController(ReportesVentasService service) {
        this.service = service;
    }

    // ----- Endpoints Resumen (JSON) -----
    @GetMapping("/productos")
    public ResponseEntity<List<ProductoVentasDTO>> getProductos(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerProductosMasVendidos(desde, hasta));
    }

    @GetMapping("/clientes")
    public ResponseEntity<List<ClienteFrecuenteDTO>> getClientes(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerClientesFrecuentes(desde, hasta));
    }

    @GetMapping("/habitaciones")
    public ResponseEntity<List<HabitacionVentasDTO>> getHabitaciones(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerHabitacionesMasVendidas(desde, hasta));
    }

    @GetMapping("/salones")
    public ResponseEntity<List<SalonVentasDTO>> getSalones(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerSalonesMasVendidos(desde, hasta));
    }

    @GetMapping("/metodos-pago")
    public ResponseEntity<List<PagoVentasDTO>> getMetodosPago(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerMetodosPago(desde, hasta));
    }

    // ----- Endpoints Detallado (JSON) -----
    @GetMapping("/salones/detallado")
    public ResponseEntity<List<SalonVentasDetalladoDTO>> getSalonesDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerSalonesDetallado(desde, hasta));
    }

    @GetMapping("/habitaciones/detallado")
    public ResponseEntity<List<HabitacionVentasDetalladoDTO>> getHabitacionesDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerHabitacionesDetallado(desde, hasta));
    }

    @GetMapping("/metodos-pago/detallado")
    public ResponseEntity<List<PagoVentasDetalladoDTO>> getMetodosPagoDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        return ResponseEntity.ok(service.obtenerMetodosPagoDetallado(desde, hasta));
    }

    // ----- Endpoints Resumen (PDF / Excel) -----
    @GetMapping(path = "/{tipo}/pdf")
    public ResponseEntity<byte[]> downloadPdfResumen(
            @PathVariable String tipo,
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarPdfResumen(tipo, desde, hasta);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData(
                "attachment",
                String.format("reporte_%s_%s_a_%s.pdf", tipo, desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    @GetMapping(path = "/{tipo}/excel")
    public ResponseEntity<byte[]> downloadExcelResumen(
            @PathVariable String tipo,
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarExcelResumen(tipo, desde, hasta);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDispositionFormData(
                "attachment",
                String.format("reporte_%s_%s_a_%s.xlsx", tipo, desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    // ----- Endpoints Detallado (PDF / Excel) -----
    @GetMapping("/salones/detallado/pdf")
    public ResponseEntity<byte[]> downloadPdfSalonesDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarPdfSalonesDetallado(
                service.obtenerSalonesDetallado(desde, hasta))
                .readAllBytes(); // ByteArrayInputStream to bytes
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData(
                "attachment",
                String.format("salones_detallado_%s_a_%s.pdf", desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    @GetMapping("/salones/detallado/excel")
    public ResponseEntity<byte[]> downloadExcelSalonesDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarExcelSalonesDetallado(
                service.obtenerSalonesDetallado(desde, hasta));
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDispositionFormData(
                "attachment",
                String.format("salones_detallado_%s_a_%s.xlsx", desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    @GetMapping("/habitaciones/detallado/pdf")
    public ResponseEntity<byte[]> downloadPdfHabitacionesDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarPdfHabitacionesDetallado(
                service.obtenerHabitacionesDetallado(desde, hasta))
                .readAllBytes();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData(
                "attachment",
                String.format("habitaciones_detallado_%s_a_%s.pdf", desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    @GetMapping("/habitaciones/detallado/excel")
    public ResponseEntity<byte[]> downloadExcelHabitacionesDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarExcelHabitacionesDetallado(
                service.obtenerHabitacionesDetallado(desde, hasta));
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDispositionFormData(
                "attachment",
                String.format("habitaciones_detallado_%s_a_%s.xlsx", desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    @GetMapping("/metodos-pago/detallado/pdf")
    public ResponseEntity<byte[]> downloadPdfMetodosPagoDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarPdfMetodosPagoDetallado(
                service.obtenerMetodosPagoDetallado(desde, hasta))
                .readAllBytes();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData(
                "attachment",
                String.format("metodos_pago_detallado_%s_a_%s.pdf", desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    @GetMapping("/metodos-pago/detallado/excel")
    public ResponseEntity<byte[]> downloadExcelMetodosPagoDetallado(
            @RequestParam String desde,
            @RequestParam String hasta) {
        byte[] content = service.generarExcelMetodosPagoDetallado(
                service.obtenerMetodosPagoDetallado(desde, hasta));
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDispositionFormData(
                "attachment",
                String.format("metodos_pago_detallado_%s_a_%s.xlsx", desde, hasta)
        );
        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    // ----- Endpoints Reservas por mes (PDF / Excel) -----
    @GetMapping("/reservas-por-mes")
        public ResponseEntity<List<ReservasPorMesDTO>> getReservasPorMesJson(
        @RequestParam String tipo,      // "habitaciones" o "salones"
        @RequestParam String desde,
        @RequestParam String hasta) {

        List<ReservasPorMesDTO> datos = service.obtenerReservasPorMes(tipo, desde, hasta);
        return ResponseEntity.ok(datos);
        }
        
    @GetMapping("/reservas-por-mes/pdf")
        public ResponseEntity<byte[]> downloadPdfReservasPorMes(
                @RequestParam String tipo,     // "habitaciones" o "salones"
                @RequestParam String desde,
                @RequestParam String hasta) {

        // 1) obtener los datos
        List<ReservasPorMesDTO> datos = service.obtenerReservasPorMes(tipo, desde, hasta);

        // 2) armar título
        String titulo = tipo.equalsIgnoreCase("habitaciones")
                ? "Reservas por Mes - Habitaciones"
                : "Reservas por Mes - Salones";

        // 3) generar PDF
        ByteArrayInputStream pdfStream = service.generarPdfReservasPorMes(datos, titulo);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDispositionFormData(
                "attachment",
                String.format("reservas_por_mes_%s_%s_a_%s.pdf", tipo, desde, hasta)
        );

        return new ResponseEntity<>(pdfStream.readAllBytes(), headers, HttpStatus.OK);
        }

     @GetMapping("/reservas-por-mes/excel")
        public ResponseEntity<byte[]> downloadExcelReservasPorMes(
                @RequestParam String tipo,
                @RequestParam String desde,
                @RequestParam String hasta) {

        // 1) obtener los datos
        List<ReservasPorMesDTO> datos = service.obtenerReservasPorMes(tipo, desde, hasta);

        // 2) armar título
        String titulo = tipo.equalsIgnoreCase("habitaciones")
                ? "Reservas por Mes - Habitaciones"
                : "Reservas por Mes - Salones";

        // 3) generar Excel
        byte[] excel = service.generarExcelReservasPorMes(datos, titulo);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDispositionFormData(
                "attachment",
                String.format("reservas_por_mes_%s_%s_a_%s.xlsx", tipo, desde, hasta)
        );

        return new ResponseEntity<>(excel, headers, HttpStatus.OK);
        }

        // Cuenta todas las reservas de habitación hechas HOY
  @GetMapping("/reservas/hoy/habitaciones")
public ResponseEntity<Long> countHoyHabitaciones() {
  long total = service.contarReservasHoyHabitaciones();
  return ResponseEntity.ok(total);
}

@GetMapping("/reservas/hoy/salones")
public ResponseEntity<Long> countHoySalones() {
  long total = service.contarReservasHoySalones();
  return ResponseEntity.ok(total);
}


}