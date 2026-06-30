package com.alexander.sistema_cerro_verde_backend.service.caja.resumen;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.dto.cajaresumen.ResumenPagosDTO;
import com.alexander.sistema_cerro_verde_backend.dto.cajaresumen.VentaCajaDTO;
import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaMetodoPago;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;
import com.alexander.sistema_cerro_verde_backend.repository.caja.CajasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.VentasRepository;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;

import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.*;
import java.io.*;

@Service
public class CajaPdfService {

    @Autowired
    private CajasRepository cajasRepository;

    @Autowired
    private VentasRepository ventasRepository;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public List<VentaCajaDTO> obtenerVentasDesdeCaja(Integer idCaja) {
        Cajas caja = cajasRepository.findById(idCaja)
            .orElseThrow(() -> new RuntimeException("Caja no encontrada"));

        LocalDateTime fechaApertura = caja.getFechaApertura()
            .toInstant()
            .atZone(ZoneId.systemDefault())
            .toLocalDateTime();

        LocalDateTime fechaCierre = LocalDateTime.now(); // o usa caja.getFechaCierre() si lo tienes

        List<Ventas> ventas = ventasRepository.findAll().stream()
            .filter(v -> {
                try {
                    if (v.getFecha() == null) return false;
                    LocalDateTime fechaVenta = LocalDateTime.parse(v.getFecha(), FORMATTER);
                    return !fechaVenta.isBefore(fechaApertura) && !fechaVenta.isAfter(fechaCierre);
                } catch (Exception e) {
                    System.out.println("❌ Error al parsear fecha de venta: " + v.getFecha());
                    return false;
                }
            })
            .collect(Collectors.toList());

        return mapearVentas(ventas);
    }

    public byte[] generarPdfCaja(List<VentaCajaDTO> ventas) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdf = new PdfDocument(writer);
        Document doc = new Document(pdf);

        Paragraph title = new Paragraph("CIERRE DE CAJA (TODAS LAS VENTAS)")
            .setBold()
            .setFontSize(16)
            .setTextAlignment(TextAlignment.CENTER);
        doc.add(title);

        String fechaActual = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
        doc.add(new Paragraph("Fecha de arqueo: " + fechaActual).setFontSize(10));
        doc.add(new Paragraph("\n"));

        float[] columnWidths = {4, 2, 2, 2, 2, 2};
        Table table = new Table(UnitValue.createPercentArray(columnWidths));
        table.setWidth(UnitValue.createPercentValue(100));

        String[] headers = {"Código Boleta", "Efectivo", "Yape", "Plin", "Tarjeta", "Total"};
        for (String header : headers) {
            table.addHeaderCell(new Cell().add(new Paragraph(header).setBold()));
        }

        double totalEfectivo = 0, totalYape = 0, totalPlin = 0, totalTarjeta = 0, totalGeneral = 0;

        for (VentaCajaDTO v : ventas) {
            table.addCell(new Cell().add(new Paragraph(v.getCodigoBoleta())));
            table.addCell(new Cell().add(new Paragraph(String.format("%.2f", v.getEfectivo()))));
            table.addCell(new Cell().add(new Paragraph(String.format("%.2f", v.getYape()))));
            table.addCell(new Cell().add(new Paragraph(String.format("%.2f", v.getPlin()))));
            table.addCell(new Cell().add(new Paragraph(String.format("%.2f", v.getTarjeta()))));
            table.addCell(new Cell().add(new Paragraph(String.format("%.2f", v.getTotal()))));

            totalEfectivo += v.getEfectivo();
            totalYape += v.getYape();
            totalPlin += v.getPlin();
            totalTarjeta += v.getTarjeta();
            totalGeneral += v.getTotal();
        }

        table.addCell(new Cell().add(new Paragraph("TOTALES").setBold()));
        table.addCell(new Cell().add(new Paragraph(String.format("%.2f", totalEfectivo))).setBold());
        table.addCell(new Cell().add(new Paragraph(String.format("%.2f", totalYape))).setBold());
        table.addCell(new Cell().add(new Paragraph(String.format("%.2f", totalPlin))).setBold());
        table.addCell(new Cell().add(new Paragraph(String.format("%.2f", totalTarjeta))).setBold());
        table.addCell(new Cell().add(new Paragraph(String.format("%.2f", totalGeneral))).setBold());

        doc.add(table);
        doc.close();

        return baos.toByteArray();
    }

    public ResumenPagosDTO resumenPorTipoDePago(Integer idCaja) {
        Cajas caja = cajasRepository.findById(idCaja)
            .orElseThrow(() -> new RuntimeException("Caja no encontrada"));

        LocalDateTime fechaApertura = caja.getFechaApertura()
            .toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();

        LocalDateTime fechaCierre = LocalDateTime.now();

        List<Ventas> ventas = ventasRepository.findAll().stream()
            .filter(v -> {
                try {
                    if (v.getFecha() == null) return false;
                    LocalDateTime fechaVenta = LocalDateTime.parse(v.getFecha(), FORMATTER);
                    return !fechaVenta.isBefore(fechaApertura) && !fechaVenta.isAfter(fechaCierre);
                } catch (Exception e) {
                    return false;
                }
            }).collect(Collectors.toList());

        ResumenPagosDTO resumen = new ResumenPagosDTO();

        for (Ventas venta : ventas) {
            if (venta.getVentaMetodoPago() == null) continue;

            for (VentaMetodoPago vmp : venta.getVentaMetodoPago()) {
                if (vmp.getMetodoPago() == null) continue;

                String metodo = vmp.getMetodoPago().getNombre().toLowerCase().trim();
                double pago = vmp.getPago();

                if (metodo.contains("efectivo")) resumen.setEfectivo(resumen.getEfectivo() + pago);
                else if (metodo.contains("yape")) resumen.setYape(resumen.getYape() + pago);
                else if (metodo.contains("plin")) resumen.setPlin(resumen.getPlin() + pago);
                else if (metodo.contains("tarjeta")) resumen.setTarjeta(resumen.getTarjeta() + pago);
            }
        }

        return resumen;
    }

    private List<VentaCajaDTO> mapearVentas(List<Ventas> ventas) {
        return ventas.stream().map(venta -> {
            VentaCajaDTO dto = new VentaCajaDTO();
            if (venta.getComprobantePago() != null) {
                String num = venta.getComprobantePago().getNumComprobante();
                String serie = venta.getComprobantePago().getNumSerieBoleta();

                if (serie == null || serie.isEmpty()) {
                    serie = venta.getComprobantePago().getNumSerieFactura();
                }

                if (serie == null || serie.isEmpty()) {
                    dto.setCodigoBoleta(num); // fallback
                } else {
                    dto.setCodigoBoleta(num + " - " + serie);
                }
            } else {
                dto.setCodigoBoleta("SIN COMPROBANTE");
            }

            dto.setTotal(venta.getTotal());

            if (venta.getVentaMetodoPago() != null) {
                for (VentaMetodoPago vmp : venta.getVentaMetodoPago()) {
                    if (vmp.getMetodoPago() == null) continue;
                    String metodo = vmp.getMetodoPago().getNombre().toLowerCase().trim();
                    switch (metodo) {
                        case "efectivo": dto.setEfectivo(vmp.getPago()); break;
                        case "yape": dto.setYape(vmp.getPago()); break;
                        case "plin": dto.setPlin(vmp.getPago()); break;
                        case "tarjeta": dto.setTarjeta(vmp.getPago()); break;
                    }
                }
            }

            return dto;
        }).collect(Collectors.toList());
    }

}