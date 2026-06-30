package com.alexander.sistema_cerro_verde_backend.service.reportes.jpa;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.jfree.chart.JFreeChart;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProductoReporteDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProveedorReporteDTO;
import com.alexander.sistema_cerro_verde_backend.service.reportes.IReportesExportService;
import com.itextpdf.io.image.ImageDataFactory;
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
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.io.font.constants.StandardFonts;

import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Picture;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@Service
public class ReportesExportService implements IReportesExportService {

    private static final org.slf4j.Logger log =
        org.slf4j.LoggerFactory.getLogger(ReportesExportService.class);

    // ---------------------------------------------------
    // Helper para cargar logo desde classpath
    // ---------------------------------------------------
    private byte[] loadLogoBytes() {
        try {
            ClassPathResource res = new ClassPathResource("static/img/logo-cerroverde2.png");
            if (!res.exists()) {
                log.warn("⚠️ Logo no encontrado en /static/img/logo-cerroverde2.png");
                return null;
            }
            return IOUtils.toByteArray(res.getInputStream());
        } catch (IOException e) {
            log.error("❌ Error leyendo logo", e);
            return null;
        }
    }

    // ---------------------------------------------------
    // PDF Productos
    // ---------------------------------------------------
    @Override
    public ByteArrayInputStream generarPdfProductos(List<ProductoReporteDTO> productos) {
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            PdfDocument pdfDoc = new PdfDocument(new PdfWriter(baos));
            Document document = new Document(pdfDoc);

            // Logo
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                Image img = new Image(ImageDataFactory.create(logo))
                    .scaleToFit(100, 50)
                    .setFixedPosition(36, pdfDoc.getDefaultPageSize().getTop() - 60);
                document.add(img);
            }

            // Título
            document.add(new Paragraph("Reporte de Productos Más Comprados")
                .setFont(PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD))
                .setFontSize(16)
                .setTextAlignment(TextAlignment.CENTER));
            document.add(new Paragraph("\n"));

            // Gráfico
            ByteArrayOutputStream chartOut = generarChartProductos(productos);
            Image chartImg = new Image(ImageDataFactory.create(chartOut.toByteArray()))
                .setAutoScale(true);
            document.add(chartImg);
            document.add(new Paragraph("\n"));

            // Tabla
            float[] widths = { 200F, 80F, 80F };
            Table table = new Table(UnitValue.createPercentArray(widths))
                .useAllAvailableWidth();
            Style headerStyle = new Style()
                .setFont(PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD))
                .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER);

            table.addHeaderCell(new Cell().add(new Paragraph("Producto")).addStyle(headerStyle));
            table.addHeaderCell(new Cell().add(new Paragraph("Cantidad")).addStyle(headerStyle));
            table.addHeaderCell(new Cell().add(new Paragraph("Total Gastado")).addStyle(headerStyle));

            for (ProductoReporteDTO pr : productos) {
                table.addCell(pr.getProductoNombre());
                table.addCell(pr.getCantidadComprada().toString());
                table.addCell(pr.getTotalGastado().toString());
            }

            document.add(table);
            document.close();

            return new ByteArrayInputStream(baos.toByteArray());
        } catch (Exception e) {
            throw new RuntimeException("Error generando PDF de Productos", e);
        }
    }

    // ---------------------------------------------------
    // Excel Productos
    // ---------------------------------------------------
    @Override
    public ByteArrayOutputStream generarExcelProductos(List<ProductoReporteDTO> productos) {
        try (Workbook workbook = new XSSFWorkbook()) {

            CreationHelper helper = workbook.getCreationHelper();
            var sheet = workbook.createSheet("Productos");

            // Logo
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                int idx = workbook.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
                Drawing<?> drawing = sheet.createDrawingPatriarch();
                ClientAnchor anchor = helper.createClientAnchor();
                anchor.setCol1(0); anchor.setRow1(0);
                drawing.createPicture(anchor, idx).resize(1.5);
            }

            // Encabezados
            Font font = workbook.createFont();
            font.setBold(true);
            var style = workbook.createCellStyle();
            style.setFont(font);
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            style.setAlignment(HorizontalAlignment.CENTER);

            int headerRow = 4;
            var header = sheet.createRow(headerRow);
            String[] headers = { "Producto", "Cantidad", "Total Gastado" };
            for (int i = 0; i < headers.length; i++) {
                var cell = header.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(style);
            }

            // Datos
            int r = headerRow + 1;
            for (ProductoReporteDTO pr : productos) {
                var row = sheet.createRow(r++);
                row.createCell(0).setCellValue(pr.getProductoNombre());
                row.createCell(1).setCellValue(pr.getCantidadComprada());
                row.createCell(2).setCellValue(pr.getTotalGastado().doubleValue());
            }

            // Auto‐size
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // Gráfico en hoja aparte
            ByteArrayOutputStream chartOut = generarChartProductos(productos);
            int chartIdx = workbook.addPicture(chartOut.toByteArray(), Workbook.PICTURE_TYPE_PNG);
            var chartSheet = workbook.createSheet("Gráfico Productos");
            Drawing<?> drawChart = chartSheet.createDrawingPatriarch();
            ClientAnchor chartAnchor = helper.createClientAnchor();
            chartAnchor.setCol1(0); chartAnchor.setRow1(1);
            drawChart.createPicture(chartAnchor, chartIdx).resize();

            // Escribe y devuelve el stream
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            workbook.write(baos);
            return baos;

        } catch (Exception e) {
            throw new RuntimeException("Error generando Excel de Productos", e);
        }
    }

    // ---------------------------------------------------
    // PDF Proveedores
    // ---------------------------------------------------
    @Override
    public ByteArrayInputStream generarPdfProveedores(List<ProveedorReporteDTO> proveedores) {
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            PdfDocument pdfDoc = new PdfDocument(new PdfWriter(baos));
            Document document = new Document(pdfDoc);

            byte[] logo = loadLogoBytes();
            if (logo != null) {
                Image img = new Image(ImageDataFactory.create(logo))
                    .scaleToFit(100, 50)
                    .setFixedPosition(36, pdfDoc.getDefaultPageSize().getTop() - 60);
                document.add(img);
            }

            document.add(new Paragraph("Reporte de Proveedores Más Comprados")
                .setFont(PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD))
                .setFontSize(16)
                .setTextAlignment(TextAlignment.CENTER));
            document.add(new Paragraph("\n"));

            ByteArrayOutputStream chartOut = generarChartProveedores(proveedores);
            document.add(new Image(ImageDataFactory.create(chartOut.toByteArray()))
                .setAutoScale(true));
            document.add(new Paragraph("\n"));

            float[] widths = {150F, 80F, 80F, 200F};
            Table table = new Table(UnitValue.createPercentArray(widths))
                .useAllAvailableWidth();
            Style headerStyle = new Style()
                .setFont(PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD))
                .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER);

            table.addHeaderCell(new Cell().add(new Paragraph("Proveedor")).addStyle(headerStyle));
            table.addHeaderCell(new Cell().add(new Paragraph("Facturas")).addStyle(headerStyle));
            table.addHeaderCell(new Cell().add(new Paragraph("Total Gastado")).addStyle(headerStyle));
            table.addHeaderCell(new Cell().add(new Paragraph("Productos Comprados")).addStyle(headerStyle));

            for (ProveedorReporteDTO pr : proveedores) {
                table.addCell(pr.getProveedorNombre());
                table.addCell(pr.getCantidadFacturas().toString());
                table.addCell(pr.getTotalGastado().toString());
                table.addCell(pr.getProductosComprados());
            }

            document.add(table);
            document.close();
            return new ByteArrayInputStream(baos.toByteArray());
        } catch (Exception e) {
            log.error("Falló generarPdfProveedores", e);
            throw new RuntimeException("Error generando PDF de Proveedores", e);
        }
    }

    // ---------------------------------------------------
    // Excel Proveedores
    // ---------------------------------------------------
    @Override
    public ByteArrayOutputStream generarExcelProveedores(List<ProveedorReporteDTO> proveedores) {
        try (Workbook workbook = new XSSFWorkbook()) {

            CreationHelper helper = workbook.getCreationHelper();
            var sheet = workbook.createSheet("Proveedores");

            byte[] logo = loadLogoBytes();
            if (logo != null) {
                int idx = workbook.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
                Drawing<?> drawing = sheet.createDrawingPatriarch();
                ClientAnchor anchor = helper.createClientAnchor();
                anchor.setCol1(0); anchor.setRow1(0);
                drawing.createPicture(anchor, idx).resize(1.5);
            }

            Font font = workbook.createFont();
            font.setBold(true);
            var style = workbook.createCellStyle();
            style.setFont(font);
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            style.setAlignment(HorizontalAlignment.CENTER);

            int headerRow = 4;
            var row = sheet.createRow(headerRow);
            String[] headers = { "Proveedor", "Facturas", "Total Gastado", "Productos Comprados" };
            for (int i = 0; i < headers.length; i++) {
                var cell = row.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(style);
            }

            int r = headerRow + 1;
            for (ProveedorReporteDTO pr : proveedores) {
                var dataRow = sheet.createRow(r++);
                dataRow.createCell(0).setCellValue(pr.getProveedorNombre());
                dataRow.createCell(1).setCellValue(pr.getCantidadFacturas());
                dataRow.createCell(2).setCellValue(pr.getTotalGastado());
                dataRow.createCell(3).setCellValue(pr.getProductosComprados());
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            ByteArrayOutputStream chartOut = generarChartProveedores(proveedores);
            int chartIdx = workbook.addPicture(chartOut.toByteArray(), Workbook.PICTURE_TYPE_PNG);
            var chartSheet = workbook.createSheet("Gráfico Proveedores");
            Drawing<?> drawChart = chartSheet.createDrawingPatriarch();
            ClientAnchor chartAnchor = helper.createClientAnchor();
            chartAnchor.setCol1(0); chartAnchor.setRow1(1);
            drawChart.createPicture(chartAnchor, chartIdx).resize();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            workbook.write(baos);
            return baos;

        } catch (Exception e) {
            throw new RuntimeException("Error generando Excel de Proveedores", e);
        }
    }

    // ---------------------------------------------------
    // Charts auxiliares
    // ---------------------------------------------------
    private ByteArrayOutputStream generarChartProductos(List<ProductoReporteDTO> productos) throws IOException {
        var dataset = new org.jfree.data.category.DefaultCategoryDataset();
        productos.stream().limit(10)
            .forEach(pr -> dataset.addValue(pr.getCantidadComprada(), "Cantidad", pr.getProductoNombre()));
        JFreeChart chart = org.jfree.chart.ChartFactory.createBarChart(
            "Top 10 Productos", "Producto", "Cantidad", dataset
        );
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        org.jfree.chart.ChartUtils.writeChartAsPNG(out, chart, 500, 300);
        return out;
    }

    private ByteArrayOutputStream generarChartProveedores(List<ProveedorReporteDTO> proveedores) throws IOException {
        var dataset = new org.jfree.data.category.DefaultCategoryDataset();
        proveedores.stream().limit(10)
            .forEach(pr -> dataset.addValue(pr.getCantidadFacturas(), "Facturas", pr.getProveedorNombre()));
        JFreeChart chart = org.jfree.chart.ChartFactory.createBarChart(
            "Top 10 Proveedores", "Proveedor", "Facturas", dataset
        );
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        org.jfree.chart.ChartUtils.writeChartAsPNG(out, chart, 500, 300);
        return out;
    }
}
