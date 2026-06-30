package com.alexander.sistema_cerro_verde_backend.service.reportes.jpa;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtils;
import org.jfree.chart.JFreeChart;
import org.jfree.data.general.DefaultPieDataset;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.CajaResumenDTO;
import com.alexander.sistema_cerro_verde_backend.repository.caja.CajasRepository;
import com.itextpdf.io.font.constants.StandardFonts;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.Style;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;

@Service
public class CajaReporteService {

    private final CajasRepository repo;

    public CajaReporteService(CajasRepository repo) {
        this.repo = repo;
    }

    private byte[] loadLogoBytes() {
        try {
            ClassPathResource res = new ClassPathResource("static/img/logo-cerroverde2.png");
            if (!res.exists()) return null;
            return IOUtils.toByteArray(res.getInputStream());
        } catch (Exception e) {
            return null;
        }
    }

    /** 1) Resumen global (ingresos vs egresos) **/
    public List<CajaResumenDTO> obtenerResumenCaja(
            LocalDateTime desde,
            LocalDateTime hasta,
            List<String> tipos
    ) {
        return repo.fetchResumenCaja(desde, hasta, tipos);
    }

    

    // --- Generación PDF resumen global ---
    public ByteArrayInputStream generarPdfResumenCaja(
            LocalDateTime desde,
            LocalDateTime hasta,
            List<String> tipos
    ) {
        List<CajaResumenDTO> data = obtenerResumenCaja(desde, hasta, tipos);
        try (var baos = new ByteArrayOutputStream()) {
            var writer = new PdfWriter(baos);
            var pdf    = new PdfDocument(writer);
            var doc    = new Document(pdf);

            // Logo
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                doc.add(new Image(ImageDataFactory.create(logo))
                    .scaleToFit(100,50)
                    .setFixedPosition(36, pdf.getDefaultPageSize().getTop()-60));
            }

            // Título
            var font = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
            doc.add(new Paragraph("Resumen de Caja")
                .setFont(font).setFontSize(16)
                .setTextAlignment(TextAlignment.CENTER));
            doc.add(new Paragraph("\n"));

            // Gráfico circular
            DefaultPieDataset<String> pieDs = new DefaultPieDataset<>();
            data.forEach(d -> pieDs.setValue(d.getTipo(), d.getTotal()));
            JFreeChart pie = ChartFactory.createPieChart("Ingresos vs Egresos", pieDs, true, true, false);
            try (var pieOut = new ByteArrayOutputStream()) {
                ChartUtils.writeChartAsPNG(pieOut, pie, 400, 300);
                doc.add(new Image(ImageDataFactory.create(pieOut.toByteArray())).setAutoScale(true));
            }
            doc.add(new Paragraph("\n"));

            // Tabla
            float[] widths = {200F, 100F};
            var table = new Table(UnitValue.createPercentArray(widths)).useAllAvailableWidth();
            var hdrStyle = new Style()
                .setFont(font)
                .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER);
            table.addHeaderCell(new Cell().add(new Paragraph("Tipo")).addStyle(hdrStyle));
            table.addHeaderCell(new Cell().add(new Paragraph("Total")).addStyle(hdrStyle));
            data.forEach(d -> {
                table.addCell(d.getTipo());
                table.addCell(d.getTotal().toString());
            });
            doc.add(table);

            doc.close();
            return new ByteArrayInputStream(baos.toByteArray());
        } catch (Exception e) {
            throw new RuntimeException("Error al generar PDF de resumen de caja", e);
        }
    }

    // --- Generación Excel resumen global ---
    public byte[] generarExcelResumenCaja(
            LocalDateTime desde,
            LocalDateTime hasta,
            List<String> tipos
    ) {
        List<CajaResumenDTO> data = obtenerResumenCaja(desde, hasta, tipos);
        try (Workbook wb = new XSSFWorkbook(); var out = new ByteArrayOutputStream()) {
            Sheet sh = wb.createSheet("ResumenCaja");
            CreationHelper ch = wb.getCreationHelper();

            // Logo
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                int idx = wb.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
                Drawing<?> dr = sh.createDrawingPatriarch();
                ClientAnchor anc = ch.createClientAnchor();
                anc.setCol1(0); anc.setRow1(0);
                dr.createPicture(anc, idx).resize(1.5);
            }

            // Encabezados
            Row hdr = sh.createRow(4);
            String[] cols = { "Tipo", "Total" };
            var f = wb.createFont(); f.setBold(true);
            var cs = wb.createCellStyle();
            cs.setFont(f);
            cs.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            cs.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cs.setAlignment(HorizontalAlignment.CENTER);
            for (int i = 0; i < cols.length; i++) {
                var c = hdr.createCell(i);
                c.setCellValue(cols[i]);
                c.setCellStyle(cs);
            }

            // Datos
            int r = 5;
            for (var d : data) {
                var row = sh.createRow(r++);
                row.createCell(0).setCellValue(d.getTipo());
                row.createCell(1).setCellValue(d.getTotal().doubleValue());
            }
            for (int i = 0; i < cols.length; i++) sh.autoSizeColumn(i);

            // Gráfico circular
            DefaultPieDataset<String> pieDs = new DefaultPieDataset<>();
            data.forEach(d -> pieDs.setValue(d.getTipo(), d.getTotal()));
            JFreeChart pie = ChartFactory.createPieChart("Ingresos vs Egresos", pieDs, true, true, false);
            try (var picOut = new ByteArrayOutputStream()) {
                ChartUtils.writeChartAsPNG(picOut, pie, 400, 300);
                int picIdx = wb.addPicture(picOut.toByteArray(), Workbook.PICTURE_TYPE_PNG);
                Sheet gfx = wb.createSheet("Gráfico");
                Drawing<?> dr2 = gfx.createDrawingPatriarch();
                ClientAnchor anc2 = ch.createClientAnchor();
                anc2.setCol1(0); anc2.setRow1(1);
                dr2.createPicture(anc2, picIdx).resize();
            }

            wb.write(out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error al generar Excel de resumen de caja", e);
        }
    }

    // --- Generación PDF desglose mensual ---
    
}
