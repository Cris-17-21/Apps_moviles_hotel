package com.alexander.sistema_cerro_verde_backend.service.ventas;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.NotaCredito;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.NotaCreditoRepository;
import com.itextpdf.io.source.ByteArrayOutputStream;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.borders.*;
import com.itextpdf.layout.properties.*;
import com.itextpdf.kernel.colors.ColorConstants;


import jakarta.transaction.Transactional;

@Service
public class NotaCreditoService {

    @Autowired
    private NotaCreditoRepository repo;

    @Transactional
    public Optional<NotaCredito> buscarId(Integer id) {
        Optional<NotaCredito> notaOpt = repo.findById(id);
        notaOpt.ifPresent(nota -> {
            // Forzar carga de relaciones
            nota.getVenta().getCliente().getNombre();
        });
        return notaOpt;
    }

    public Optional<NotaCredito> buscarPorVenta(Integer idVenta) {
        return repo.findByVentaId(idVenta);
    }
    
    

    @Transactional
public NotaCredito emitirNotaCredito(Ventas venta, double monto, String motivo) {
    NotaCredito nota = new NotaCredito();
    nota.setVenta(venta);
    nota.setFechaEmision(new Date());
    nota.setMonto(monto);
    nota.setMotivo(motivo);
    NotaCredito savedNota = repo.save(nota);

    try {
        byte[] pdfBytes = generarNotaCreditoPDF(savedNota);  // Generar el PDF en memoria
        savedNota.setPdfBytes(pdfBytes);  // Asignar PDF
        repo.save(savedNota);            // ← Guardar de nuevo con los bytes
    } catch (Exception e) {
        throw new RuntimeException("Error al generar PDF de la nota de crédito", e);
    }

    return savedNota;
}

    public static byte[] generarNotaCreditoPDF(NotaCredito nota) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdfDoc = new PdfDocument(writer);
        Document document = new Document(pdfDoc);

        // Configura márgenes estándar A4
        document.setMargins(20, 20, 20, 20);

        // Cabecera SUNAT con borde inferior
        Table header = new Table(new float[]{70, 30});
        header.setWidth(UnitValue.createPercentValue(100));

        Cell empresaCell = new Cell()
                .add(new Paragraph("CERRO VERDE TARAPOTO HOTEL S.A.C.")
                        .setBold().setFontSize(14))
                .add(new Paragraph("RUC: 20531481233"))
                .add(new Paragraph("Jr. Augusto B. Leguia Nro. 596"))
                .setBorder(Border.NO_BORDER);
        header.addCell(empresaCell);

        // Celda de "NOTA DE CRÉDITO" con diseño de caja
        Cell notaCell = new Cell()
                .add(new Paragraph("NOTA DE CRÉDITO").setBold().setFontSize(16))
                .add(new Paragraph("Serie: NC01 - N° " + nota.getId()))
                .setTextAlignment(TextAlignment.CENTER)
                .setVerticalAlignment(VerticalAlignment.MIDDLE)
                .setBorder(new SolidBorder(ColorConstants.BLUE, 1)) // Borde azul
                .setBackgroundColor(ColorConstants.WHITE); // Fondo blanco
        header.addCell(notaCell);

        // Línea separadora
        header.setBorderBottom(new SolidBorder(1));
        document.add(header);

        document.add(new Paragraph("\n"));

        // Datos del documento que modifica (adaptado al nuevo diseño)
        document.add(new Paragraph("Documento que modifica:").setBold().setFontSize(12));
        Table docModificaTable = new Table(new float[]{50, 50});
        docModificaTable.setWidth(UnitValue.createPercentValue(100));

        // Boleta Electrónica
        docModificaTable.addCell(new Cell().add(new Paragraph("Boleta Electrónica: " + nota.getVenta().getComprobantePago().getNumComprobante() + "-" + nota.getVenta().getComprobantePago().getNumSerieBoleta())).setBorder(Border.NO_BORDER));
        // Tipo de Moneda
        docModificaTable.addCell(new Cell().add(new Paragraph("Tipo de Moneda: NUEVOS SOLES")).setBorder(Border.NO_BORDER));
        docModificaTable.addCell(new Cell().add(new Paragraph("")).setBorder(Border.NO_BORDER)); // Celda vacía para balancear
        // Motivo o Sustento
        docModificaTable.addCell(new Cell().add(new Paragraph("Motivo o Sustento: Cancelación de reserva.")).setBorder(Border.NO_BORDER));
        docModificaTable.addCell(new Cell().add(new Paragraph("")).setBorder(Border.NO_BORDER)); // Celda vacía para balancear

        document.add(docModificaTable);

        document.add(new Paragraph("\n"));

        // Datos cliente y fecha con borde inferior
        Table clienteTable = new Table(new float[]{50, 50});
        clienteTable.setWidth(UnitValue.createPercentValue(100));

        clienteTable.addCell(new Cell().add(new Paragraph("Cliente: " + nota.getVenta().getCliente().getNombre())).setBorder(Border.NO_BORDER));
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        clienteTable.addCell(new Cell().add(new Paragraph("Fecha emisión: " + sdf.format(nota.getFechaEmision()))).setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.RIGHT));
        clienteTable.addCell(new Cell().add(new Paragraph("DNI/RUC: " + nota.getVenta().getCliente().getDniRuc())).setBorder(Border.NO_BORDER));
        clienteTable.addCell(new Cell().add(new Paragraph("")).setBorder(Border.NO_BORDER)); // Celda vacía para balancear filas

        clienteTable.setBorderBottom(new SolidBorder(1));
        document.add(clienteTable);

        document.add(new Paragraph("\n"));

        // Tabla detalle productos/habitaciones/salones
        Table detalle = new Table(new float[]{6, 1, 2});
        detalle.setWidth(UnitValue.createPercentValue(100));

        // Cabecera con fondo gris
        detalle.addHeaderCell(new Cell().add(new Paragraph("Descripción").setBold()).setBackgroundColor(ColorConstants.LIGHT_GRAY));
        detalle.addHeaderCell(new Cell().add(new Paragraph("Cant").setBold()).setBackgroundColor(ColorConstants.LIGHT_GRAY).setTextAlignment(TextAlignment.CENTER));
        detalle.addHeaderCell(new Cell().add(new Paragraph("Total").setBold()).setBackgroundColor(ColorConstants.LIGHT_GRAY).setTextAlignment(TextAlignment.RIGHT));

        // Productos
        nota.getVenta().getDetalleVenta().forEach(det -> {
            detalle.addCell(new Cell().add(new Paragraph(det.getProducto().getNombre())));
            detalle.addCell(new Cell().add(new Paragraph(String.valueOf(det.getCantidad()))).setTextAlignment(TextAlignment.CENTER));
            detalle.addCell(new Cell().add(new Paragraph("S/ " + String.format("%.2f", det.getSubTotal()))).setTextAlignment(TextAlignment.RIGHT));
        });

        // Habitaciones
        nota.getVenta().getVentaHabitacion().forEach(vh -> {
            String desc = "Habitación Nro " + vh.getHabitacion().getNumero() + " x " + vh.getDias() + " días";
            detalle.addCell(new Cell().add(new Paragraph(desc)));
            detalle.addCell(new Cell().add(new Paragraph(String.valueOf(vh.getDias()))).setTextAlignment(TextAlignment.CENTER));
            detalle.addCell(new Cell().add(new Paragraph("S/ " + String.format("%.2f", vh.getSubTotal()))).setTextAlignment(TextAlignment.RIGHT));
        });

        // Salones
        nota.getVenta().getVentaSalon().forEach(vs -> {
            String desc = "Salón " + vs.getSalon().getNombre() + " x " + vs.getDias() + " días y " + vs.getHoras() + " horas";
            detalle.addCell(new Cell().add(new Paragraph(desc)));
            detalle.addCell(new Cell().add(new Paragraph(String.valueOf(vs.getDias()))).setTextAlignment(TextAlignment.CENTER));
            detalle.addCell(new Cell().add(new Paragraph("S/ " + String.format("%.2f", vs.getSubTotal()))).setTextAlignment(TextAlignment.RIGHT));
        });

        document.add(detalle);

        document.add(new Paragraph("\n"));

        // Totales con borde superior
        Table totales = new Table(new float[]{4, 2});
        totales.setWidth(UnitValue.createPercentValue(40));
        totales.setHorizontalAlignment(HorizontalAlignment.RIGHT);

        totales.addCell(new Cell().add(new Paragraph("Monto total:").setBold()).setBorder(Border.NO_BORDER));
        totales.addCell(new Cell().add(new Paragraph("S/ " + String.format("%.2f", nota.getMonto())))
                .setTextAlignment(TextAlignment.RIGHT).setBorder(Border.NO_BORDER));

        document.add(totales);

        document.add(new Paragraph("\n"));

        // Leyenda SUNAT
        Paragraph leyenda = new Paragraph("Representación impresa del comprobante electrónico")
                .setItalic().setFontSize(9).setTextAlignment(TextAlignment.CENTER);
        document.add(leyenda);

        Paragraph resolucion = new Paragraph("Autorizado mediante Resolución N° xxx-SUNAT")
                .setItalic().setFontSize(9).setTextAlignment(TextAlignment.CENTER);
        document.add(resolucion);

        document.close();  // Cerrar el documento para finalizar la escritura en el ByteArrayOutputStream
        return baos.toByteArray();  // Retornamos el PDF como bytes
    
    }
}
