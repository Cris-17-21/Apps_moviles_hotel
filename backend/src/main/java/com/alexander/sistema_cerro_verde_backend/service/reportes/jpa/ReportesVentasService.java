package com.alexander.sistema_cerro_verde_backend.service.reportes.jpa;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

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
import org.jfree.data.category.DefaultCategoryDataset;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.ClienteFrecuenteDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.HabitacionVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.HabitacionVentasDetalladoDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.PagoVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.PagoVentasDetalladoDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProductoVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ReservasPorMesDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.SalonVentasDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.SalonVentasDetalladoDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.VentaResumenDTO;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.VentasRepository;
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
public class ReportesVentasService {

    private final VentasRepository ventasRepo;

    public ReportesVentasService(VentasRepository ventasRepo) {
        this.ventasRepo = ventasRepo;
    }
    public long contarReservasHoyHabitaciones() {
        String hoy = LocalDate.now().toString();  // "2025-07-10"
        return ventasRepo.countReservasHoyHabitaciones(hoy);
    }

    /**
     * Cuenta todas las reservas de salón hechas HOY,
     * comparando únicamente la fecha (sin hora).
     */
    public long contarReservasHoySalones() {
        String hoy = LocalDate.now().toString();
        return ventasRepo.countReservasHoySalones(hoy);
    }

    /** Carga el logo desde el classpath */
    private byte[] loadLogoBytes() {
        try {
            ClassPathResource res = new ClassPathResource("static/img/logo-cerroverde2.png");
            if (!res.exists()) return null;
            return IOUtils.toByteArray(res.getInputStream());
        } catch (Exception e) {
            return null;
        }
    }

    // ----- Métodos de obtención de datos -----
    public List<ProductoVentasDTO> obtenerProductosMasVendidos(String desde, String hasta) {
        return ventasRepo.findProductosMasVendidos(desde, hasta);
    }
    public List<ClienteFrecuenteDTO> obtenerClientesFrecuentes(String desde, String hasta) {
        return ventasRepo.findClientesFrecuentes(desde, hasta);
    }
    public List<HabitacionVentasDTO> obtenerHabitacionesMasVendidas(String desde, String hasta) {
        return ventasRepo.findHabitacionesMasVendidas(desde, hasta);
    }
    public List<SalonVentasDTO> obtenerSalonesMasVendidos(String desde, String hasta) {
        return ventasRepo.findSalonesMasVendidos(desde, hasta);
    }
    public List<PagoVentasDTO> obtenerMetodosPago(String desde, String hasta) {
        return ventasRepo.findMetodosPago(desde, hasta);
    }

    // ----- Métodos detallados -----
    public List<SalonVentasDetalladoDTO> obtenerSalonesDetallado(String desde, String hasta) {
        return ventasRepo.findSalonesDetallado(desde, hasta);
    }
    public List<HabitacionVentasDetalladoDTO> obtenerHabitacionesDetallado(String desde, String hasta) {
        return ventasRepo.findHabitacionesDetallado(desde, hasta);
    }
    public List<PagoVentasDetalladoDTO> obtenerMetodosPagoDetallado(String desde, String hasta) {
        return ventasRepo.findMetodosPagoDetallado(desde, hasta);
    }
    public List<ReservasPorMesDTO> obtenerReservasPorMes(String tipo, String desde, String hasta) {
    List<Object[]> raw;

    if ("habitaciones".equalsIgnoreCase(tipo)) {
        raw = ventasRepo.findRawReservasHabitacionesPorMes(desde, hasta);
    } else if ("salones".equalsIgnoreCase(tipo)) {
        raw = ventasRepo.findRawReservasSalonesPorMes(desde, hasta);
    } else {
        return Collections.emptyList();
    }

    return raw.stream()
        .map(row -> {
            String mes       = (String) row[0];
            Number cntNum    = (Number) row[1];    // COUNT(*) → Number
            Number totalNum  = (Number) row[2];    // SUM(...)   → Number
            return new ReservasPorMesDTO(
                mes,
                cntNum.longValue(),               // cantidad
                totalNum.doubleValue()            // total
            );
        })
        .collect(Collectors.toList());
}


    // Generación de PDF resumen con logo, gráfico y tabla
    public byte[] generarPdfResumen(String tipo, String desde, String hasta) {
        List<VentaResumenDTO> lista;
        switch (tipo) {
            case "productos": lista = ventasRepo.findProductosMasVendidosResumen(desde, hasta); break;
            case "clientes": lista = ventasRepo.findClientesFrecuentesResumen(desde, hasta); break;
            case "habitaciones": lista = ventasRepo.findHabitacionesMasVendidasResumen(desde, hasta); break;
            case "salones": lista = ventasRepo.findSalonesMasVendidosResumen(desde, hasta); break;
            default: lista = ventasRepo.findMetodosPagoResumen(desde, hasta); break;
        }
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(baos);
            PdfDocument pdfDoc = new PdfDocument(writer);
            Document document = new Document(pdfDoc);
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                Image img = new Image(ImageDataFactory.create(logo))
                    .scaleToFit(100,50)
                    .setFixedPosition(36, pdfDoc.getDefaultPageSize().getTop() - 60);
                document.add(img);
            }
            Style headerFont = new Style().setFont(PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD));
            String titulo = switch (tipo) {
                case "productos" -> "Productos Más Vendidos";
                case "clientes" -> "Clientes Más Frecuentes";
                case "habitaciones" -> "Habitaciones Más Vendidas";
                case "salones" -> "Salones Más Vendidos";
                default -> "Métodos de Pago Más Usados";
            };
            document.add(new Paragraph(titulo)
                .addStyle(headerFont).setFontSize(16).setTextAlignment(TextAlignment.CENTER));
            document.add(new Paragraph("\n"));
            // Gráfico
            DefaultCategoryDataset ds = new DefaultCategoryDataset();
            lista.stream().limit(10).forEach(d -> ds.addValue(d.getCantidad(), "Cantidad", d.getNombre()));
            JFreeChart chart = ChartFactory.createBarChart("Top " + titulo, "", "", ds);
            ByteArrayOutputStream chartOut = new ByteArrayOutputStream();
            ChartUtils.writeChartAsPNG(chartOut, chart, 500,300);
            document.add(new Image(ImageDataFactory.create(chartOut.toByteArray())).setAutoScale(true));
            document.add(new Paragraph("\n"));
            // Tabla
            float[] widths = {200F,100F,100F};
            Table table = new Table(UnitValue.createPercentArray(widths)).useAllAvailableWidth();
            Style hs = new Style().setFont(PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD))
                .setBackgroundColor(ColorConstants.LIGHT_GRAY).setTextAlignment(TextAlignment.CENTER);
            String[] headers = {"Nombre","Cantidad","Total (S/.)"};
            for (String h: headers) table.addHeaderCell(new Cell().add(new Paragraph(h)).addStyle(hs));
            for (VentaResumenDTO d: lista) {
                table.addCell(d.getNombre());
                table.addCell(d.getCantidad().toString());
                table.addCell(String.format("%.2f", d.getTotal()));
            }
            document.add(table);
            document.close();
            return baos.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error PDF resumen", e);
        }
    }

    // Generación de Excel resumen con logo, gráfico y tabla
    public byte[] generarExcelResumen(String tipo, String desde, String hasta) {
        List<VentaResumenDTO> lista;
        switch (tipo) {
            case "productos": lista = ventasRepo.findProductosMasVendidosResumen(desde, hasta); break;
            case "clientes": lista = ventasRepo.findClientesFrecuentesResumen(desde, hasta); break;
            case "habitaciones": lista = ventasRepo.findHabitacionesMasVendidasResumen(desde, hasta); break;
            case "salones": lista = ventasRepo.findSalonesMasVendidosResumen(desde, hasta); break;
            default: lista = ventasRepo.findMetodosPagoResumen(desde, hasta); break;
        }
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sh = wb.createSheet("Reporte");
            CreationHelper helper = wb.getCreationHelper();
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                int idx = wb.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
                Drawing<?> dr = sh.createDrawingPatriarch();
                ClientAnchor anc = helper.createClientAnchor(); anc.setCol1(0); anc.setRow1(0);
                dr.createPicture(anc, idx).resize(1.5);
            }
            org.apache.poi.ss.usermodel.Font f = wb.createFont(); f.setBold(true);
            var cs = wb.createCellStyle(); cs.setFont(f);
            cs.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            cs.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            cs.setAlignment(HorizontalAlignment.CENTER);
            Row hr = sh.createRow(4);
            String[] hdrs = {"Nombre","Cantidad","Total (S/.)"};
            for (int i=0;i<hdrs.length;i++){ var c=hr.createCell(i); c.setCellValue(hdrs[i]); c.setCellStyle(cs);} 
            int r=5;
            for (VentaResumenDTO d:lista){ var row=sh.createRow(r++); row.createCell(0).setCellValue(d.getNombre()); row.createCell(1).setCellValue(d.getCantidad()); row.createCell(2).setCellValue(d.getTotal());}
            for(int i=0;i<hdrs.length;i++) sh.autoSizeColumn(i);
            DefaultCategoryDataset ds = new DefaultCategoryDataset(); lista.stream().limit(10).forEach(d->ds.addValue(d.getCantidad(),"Cantidad",d.getNombre()));
            JFreeChart chart = ChartFactory.createBarChart("Top " + tipo, "", "", ds);
            ByteArrayOutputStream chartOut = new ByteArrayOutputStream(); ChartUtils.writeChartAsPNG(chartOut, chart,500,300);
            int cid = wb.addPicture(chartOut.toByteArray(), Workbook.PICTURE_TYPE_PNG);
            var csheet = wb.createSheet("Gráfico");
            var dr2 = csheet.createDrawingPatriarch();
            var anc2 = helper.createClientAnchor(); anc2.setCol1(0); anc2.setRow1(1);
            dr2.createPicture(anc2, cid).resize();
            wb.write(out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error Excel resumen", e);
        }
    }

    // ----- Métodos detallados PDF y Excel -----
    // ----- Generación de PDF Detallado para Salones -----
    public ByteArrayInputStream generarPdfSalonesDetallado(List<SalonVentasDetalladoDTO> datos) {
        try {
            var baos = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(baos);
            PdfDocument pdfDoc = new PdfDocument(writer);
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
            var font = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
            document.add(new Paragraph("Ventas Detalladas por Salón")
                .setFont(font).setFontSize(16)
                .setTextAlignment(TextAlignment.CENTER));
            document.add(new Paragraph("\n"));

            // Gráfico
            var dataset = new DefaultCategoryDataset();
            datos.stream().limit(10).forEach(d ->
                dataset.addValue(d.getVecesAlquilado(), "Veces", d.getSalonNombre())
            );
            JFreeChart chart = ChartFactory.createBarChart(
                "Top Salones (Veces Alquilado)", "Salón", "Veces", dataset
            );
            var chartOut = new ByteArrayOutputStream();
            ChartUtils.writeChartAsPNG(chartOut, chart, 500, 300);
            Image chartImg = new Image(ImageDataFactory.create(chartOut.toByteArray()))
                .setAutoScale(true);
            document.add(chartImg);
            document.add(new Paragraph("\n"));

            // Tabla
            float[] widths = {150F, 80F, 80F, 200F};
            Table table = new Table(UnitValue.createPercentArray(widths)).useAllAvailableWidth();
            var headerStyle = new Style().setFont(font).setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER);
            String[] headers = {"Salón","Veces","Total (S/.)","Productos"};
            for (String h : headers) table.addHeaderCell(new Cell().add(new Paragraph(h)).addStyle(headerStyle));
            for (var d : datos) {
                table.addCell(d.getSalonNombre());
                table.addCell(String.valueOf(d.getVecesAlquilado()));
                table.addCell(String.format("%.2f", d.getTotalRecaudado()));
                table.addCell(d.getProductos());
            }
            document.add(table);
            document.close();
            return new ByteArrayInputStream(baos.toByteArray());
        } catch (Exception e) {
            throw new RuntimeException("Error PDF Salones Detallado", e);
        }
    }

    // ----- Generación de Excel Detallado para Salones -----
    public byte[] generarExcelSalonesDetallado(List<SalonVentasDetalladoDTO> datos) {
        try (Workbook wb = new XSSFWorkbook(); var out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Salones Detallado");
            CreationHelper helper = wb.getCreationHelper();

            // Logo
            byte[] logo = loadLogoBytes();
            if (logo != null) {
                int idx = wb.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
                Drawing<?> dr = sheet.createDrawingPatriarch();
                ClientAnchor anc = helper.createClientAnchor(); anc.setCol1(0); anc.setRow1(0);
                dr.createPicture(anc, idx).resize(1.5);
            }

            // Encabezados
            int hdrRow = 4;
            Row row = sheet.createRow(hdrRow);
            String[] hdrs = {"Salón","Veces","Total (S/.)","Productos"};
            var hdrFont = wb.createFont(); hdrFont.setBold(true);
            var hdrStyle = wb.createCellStyle(); hdrStyle.setFont(hdrFont);
            hdrStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.index);
            hdrStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            hdrStyle.setAlignment(HorizontalAlignment.CENTER);
            for (int i = 0; i < hdrs.length; i++) {
                var cell = row.createCell(i);
                cell.setCellValue(hdrs[i]); cell.setCellStyle(hdrStyle);
            }

            // Datos
            int r = hdrRow + 1;
            for (var d : datos) {
                var drw = sheet.createRow(r++);
                drw.createCell(0).setCellValue(d.getSalonNombre());
                drw.createCell(1).setCellValue(d.getVecesAlquilado());
                drw.createCell(2).setCellValue(d.getTotalRecaudado());
                drw.createCell(3).setCellValue(d.getProductos());
            }
            for (int i = 0; i < hdrs.length; i++) sheet.autoSizeColumn(i);

            // Gráfico en hoja aparte
            var ds = new DefaultCategoryDataset();
            datos.stream().limit(10).forEach(d -> ds.addValue(d.getVecesAlquilado(), "Veces", d.getSalonNombre()));
            JFreeChart chart = ChartFactory.createBarChart("Top Salones","Salón","Veces", ds);
            var cout = new ByteArrayOutputStream();
            ChartUtils.writeChartAsPNG(cout, chart, 500, 300);
            int chartIdx = wb.addPicture(cout.toByteArray(), Workbook.PICTURE_TYPE_PNG);
            var cs = wb.createSheet("Gráfico");
            var dr2 = cs.createDrawingPatriarch();
            var anc2 = helper.createClientAnchor(); anc2.setCol1(0); anc2.setRow1(1);
            dr2.createPicture(anc2, chartIdx).resize();

            wb.write(out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error Excel Salones Detallado", e);
        }
    }

    // ----- PDF Detallado Habitaciones -----
    public ByteArrayInputStream generarPdfHabitacionesDetallado(List<HabitacionVentasDetalladoDTO> datos) {
        try {
            var baos = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(baos);
            PdfDocument pdf = new PdfDocument(writer);
            Document doc = new Document(pdf);
            byte[] logo = loadLogoBytes();
            if (logo!=null) doc.add(new Image(ImageDataFactory.create(logo))
                .scaleToFit(100,50)
                .setFixedPosition(36, pdf.getDefaultPageSize().getTop()-60));

            var font = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
            doc.add(new Paragraph("Ventas Detalladas por Habitación")
                .setFont(font).setFontSize(16)
                .setTextAlignment(TextAlignment.CENTER)); doc.add(new Paragraph("\n"));

            // Chart
            var ds = new DefaultCategoryDataset();
            datos.stream().limit(10).forEach(d -> ds.addValue(d.getVecesVendida(), "Veces", d.getHabitacionNumero().toString()));
            JFreeChart ch = ChartFactory.createBarChart("Top Habitaciones","Habitación","Veces", ds);
            var cout = new ByteArrayOutputStream(); ChartUtils.writeChartAsPNG(cout,ch,500,300);
            doc.add(new Image(ImageDataFactory.create(cout.toByteArray())).setAutoScale(true)); doc.add(new Paragraph("\n"));

            float[] w = {100F,80F,80F,200F};
            Table t = new Table(UnitValue.createPercentArray(w)).useAllAvailableWidth();
            var hs = new Style().setFont(font)
                .setBackgroundColor(ColorConstants.LIGHT_GRAY)
                .setTextAlignment(TextAlignment.CENTER);
            String[] h = {"Habitación","Veces","Total","Productos"};
            for (String hd: h) t.addHeaderCell(new Cell().add(new Paragraph(hd)).addStyle(hs));
            for (var d : datos) {
                t.addCell(d.getHabitacionNumero().toString());
                t.addCell(d.getVecesVendida().toString());
                t.addCell(String.format("%.2f",d.getTotalRecaudado()));
                t.addCell(d.getProductos());
            }
            doc.add(t);
            doc.close(); return new ByteArrayInputStream(baos.toByteArray());
        } catch(Exception e){throw new RuntimeException("Error PDF Habitaciones Detallado",e);}    }

    // ----- Excel Detallado Habitaciones -----
    public byte[] generarExcelHabitacionesDetallado(List<HabitacionVentasDetalladoDTO> datos) {
        try (Workbook wb = new XSSFWorkbook(); var out = new ByteArrayOutputStream()) {
            Sheet sh = wb.createSheet("Habitaciones Detallado");
            CreationHelper ch = wb.getCreationHelper();
            byte[] logo = loadLogoBytes();
            if(logo!=null){int idx=wb.addPicture(logo,Workbook.PICTURE_TYPE_PNG); var dr=sh.createDrawingPatriarch(); var anc=ch.createClientAnchor(); anc.setCol1(0);anc.setRow1(0); dr.createPicture(anc,idx).resize(1.5);} 
            Row hr=sh.createRow(4); String[] hdr={"Habitación","Veces","Total","Productos"}; var hdF=wb.createFont(); hdF.setBold(true); var hdS=wb.createCellStyle(); hdS.setFont(hdF); hdS.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.index); hdS.setFillPattern(FillPatternType.SOLID_FOREGROUND); hdS.setAlignment(HorizontalAlignment.CENTER); for(int i=0;i<hdr.length;i++){var c=hr.createCell(i);c.setCellValue(hdr[i]);c.setCellStyle(hdS);} 
            int r=5; for(var d:datos){var rw=sh.createRow(r++); rw.createCell(0).setCellValue(d.getHabitacionNumero()); rw.createCell(1).setCellValue(d.getVecesVendida()); rw.createCell(2).setCellValue(d.getTotalRecaudado()); rw.createCell(3).setCellValue(d.getProductos());} for(int i=0;i<hdr.length;i++)sh.autoSizeColumn(i);
            var ds2=new DefaultCategoryDataset(); datos.stream().limit(10).forEach(d->ds2.addValue(d.getVecesVendida(),"Veces",d.getHabitacionNumero().toString()));
            var ch2=ChartFactory.createBarChart("Top Habitaciones","Habitación","Veces",ds2); var cout2=new ByteArrayOutputStream(); ChartUtils.writeChartAsPNG(cout2,ch2,500,300); int cidx=wb.addPicture(cout2.toByteArray(),Workbook.PICTURE_TYPE_PNG); var cs=wb.createSheet("Gráfico"); var dr2=cs.createDrawingPatriarch(); var anc2=ch.createClientAnchor(); anc2.setCol1(0);anc2.setRow1(1); dr2.createPicture(anc2,cidx).resize(); wb.write(out); return out.toByteArray();
        } catch(Exception e){throw new RuntimeException("Error Excel Habitaciones Detallado",e);}    }

    // ----- PDF Detallado Métodos de Pago -----
    public ByteArrayInputStream generarPdfMetodosPagoDetallado(List<PagoVentasDetalladoDTO> datos) {
    try {
        var baos = new ByteArrayOutputStream();
        var writer = new PdfWriter(baos);
        var pdf = new PdfDocument(writer);
        var doc = new Document(pdf);

        byte[] logo = loadLogoBytes();
        if (logo != null) {
            doc.add(new Image(ImageDataFactory.create(logo))
                    .scaleToFit(100, 50)
                    .setFixedPosition(36, pdf.getDefaultPageSize().getTop() - 60));
        }

        var font = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
        doc.add(new Paragraph("Ventas Detalladas por Método de Pago")
                .setFont(font).setFontSize(16).setTextAlignment(TextAlignment.CENTER));
        doc.add(new Paragraph("\n"));

        var ds3 = new DefaultCategoryDataset();
        datos.stream().limit(10)
                .forEach(d -> ds3.addValue(d.getVecesUsado(), "Veces", d.getMetodoPago()));

        var ch3 = ChartFactory.createBarChart("Top Métodos de Pago", "Método", "Veces", ds3);
        var cout3 = new ByteArrayOutputStream();
        ChartUtils.writeChartAsPNG(cout3, ch3, 500, 300);
        doc.add(new Image(ImageDataFactory.create(cout3.toByteArray())).setAutoScale(true));
        doc.add(new Paragraph("\n"));

        float[] w3 = {120F, 50F, 70F, 130F, 100F, 100F};
        var table = new Table(UnitValue.createPercentArray(w3)).useAllAvailableWidth();
        var hs3 = new Style().setFont(font).setBackgroundColor(ColorConstants.LIGHT_GRAY).setTextAlignment(TextAlignment.CENTER);

        String[] headers = {"Método", "Veces", "Total", "Productos", "Salones", "Habitaciones"};
        for (String h : headers) table.addHeaderCell(new Cell().add(new Paragraph(h)).addStyle(hs3));

        for (var d : datos) {
            table.addCell(d.getMetodoPago());
            table.addCell(String.valueOf(d.getVecesUsado()));
            table.addCell(String.format("%.2f", d.getTotalRecibido()));
            table.addCell(d.getProductos() != null ? d.getProductos() : "—");
            table.addCell(d.getSalones() != null ? d.getSalones() : "—");
            table.addCell(d.getHabitaciones() != null ? d.getHabitaciones() : "—");
        }

        doc.add(table);
        doc.close();
        return new ByteArrayInputStream(baos.toByteArray());

    } catch (Exception e) {
        throw new RuntimeException("Error PDF Métodos Pago Detallado", e);
    }
}

    // ----- Excel Detallado Métodos de Pago -----
    public byte[] generarExcelMetodosPagoDetallado(List<PagoVentasDetalladoDTO> datos) {
    try (Workbook wb = new XSSFWorkbook(); var out = new ByteArrayOutputStream()) {

        Sheet sh = wb.createSheet("Métodos Pago Detallado");
        CreationHelper ch = wb.getCreationHelper();

        byte[] logo = loadLogoBytes();
        if (logo != null) {
            int idx = wb.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
            var dr = sh.createDrawingPatriarch();
            var anc = ch.createClientAnchor();
            anc.setCol1(0);
            anc.setRow1(0);
            dr.createPicture(anc, idx).resize(1.5);
        }

        Row hr = sh.createRow(4);
        String[] hdr = {"Método", "Veces", "Total", "Productos", "Salones", "Habitaciones"};
        var f = wb.createFont();
        f.setBold(true);

        var s = wb.createCellStyle();
        s.setFont(f);
        s.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.index);
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setAlignment(HorizontalAlignment.CENTER);

        for (int i = 0; i < hdr.length; i++) {
            var c = hr.createCell(i);
            c.setCellValue(hdr[i]);
            c.setCellStyle(s);
        }

        int r = 5;
        for (var d : datos) {
            var rw = sh.createRow(r++);
            rw.createCell(0).setCellValue(d.getMetodoPago());
            rw.createCell(1).setCellValue(d.getVecesUsado());
            rw.createCell(2).setCellValue(d.getTotalRecibido());
            rw.createCell(3).setCellValue(d.getProductos() != null ? d.getProductos() : "—");
            rw.createCell(4).setCellValue(d.getSalones() != null ? d.getSalones() : "—");
            rw.createCell(5).setCellValue(d.getHabitaciones() != null ? d.getHabitaciones() : "—");
        }

        for (int i = 0; i < hdr.length; i++) sh.autoSizeColumn(i);

        // Gráfico en hoja separada
        var ds4 = new DefaultCategoryDataset();
        datos.stream().limit(10).forEach(d -> ds4.addValue(d.getVecesUsado(), "Veces", d.getMetodoPago()));
        var ch4 = ChartFactory.createBarChart("Top Métodos Pago", "Método", "Veces", ds4);
        var cout4 = new ByteArrayOutputStream();
        ChartUtils.writeChartAsPNG(cout4, ch4, 500, 300);

        int cid = wb.addPicture(cout4.toByteArray(), Workbook.PICTURE_TYPE_PNG);
        var cs = wb.createSheet("Gráfico");
        var dr2 = cs.createDrawingPatriarch();
        var anc2 = ch.createClientAnchor();
        anc2.setCol1(0);
        anc2.setRow1(1);
        dr2.createPicture(anc2, cid).resize();

        wb.write(out);
        return out.toByteArray();
    } catch (Exception e) {
        throw new RuntimeException("Error Excel Métodos Pago Detallado", e);
    }
}
// ----- Reservas por mes -----
public ByteArrayInputStream generarPdfReservasPorMes(List<ReservasPorMesDTO> datos, String tituloReporte) {
    try {
        var baos = new ByteArrayOutputStream();
        var writer = new PdfWriter(baos);
        var pdf = new PdfDocument(writer);
        var doc = new Document(pdf);

        byte[] logo = loadLogoBytes();
        if (logo != null) {
            doc.add(new Image(ImageDataFactory.create(logo))
                .scaleToFit(100, 50)
                .setFixedPosition(36, pdf.getDefaultPageSize().getTop() - 60));
        }

        var font = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
        doc.add(new Paragraph(tituloReporte)
            .setFont(font).setFontSize(16)
            .setTextAlignment(TextAlignment.CENTER));
        doc.add(new Paragraph("\n"));

        // Gráfico
        var ds = new DefaultCategoryDataset();
        datos.forEach(d -> ds.addValue(d.getCantidad(), "Cantidad", d.getMes()));
        var chart = ChartFactory.createBarChart("Reservas por Mes", "Mes", "Cantidad", ds);
        var chartOut = new ByteArrayOutputStream();
        ChartUtils.writeChartAsPNG(chartOut, chart, 500, 300);
        doc.add(new Image(ImageDataFactory.create(chartOut.toByteArray())).setAutoScale(true));
        doc.add(new Paragraph("\n"));

        // Tabla
        float[] widths = {200F, 100F};
        var table = new Table(UnitValue.createPercentArray(widths)).useAllAvailableWidth();
        var hs = new Style().setFont(font).setBackgroundColor(ColorConstants.LIGHT_GRAY).setTextAlignment(TextAlignment.CENTER);
        table.addHeaderCell(new Cell().add(new Paragraph("Mes")).addStyle(hs));
        table.addHeaderCell(new Cell().add(new Paragraph("Cantidad")).addStyle(hs));
        for (var d : datos) {
            table.addCell(d.getMes());
            table.addCell(String.valueOf(d.getCantidad()));
        }

        doc.add(table);
        doc.close();
        return new ByteArrayInputStream(baos.toByteArray());
    } catch (Exception e) {
        throw new RuntimeException("Error PDF Reservas por Mes", e);
    }
}

public byte[] generarExcelReservasPorMes(List<ReservasPorMesDTO> datos, String tituloReporte) {
    try (Workbook wb = new XSSFWorkbook(); var out = new ByteArrayOutputStream()) {
        Sheet sh = wb.createSheet("Reservas por Mes");
        CreationHelper ch = wb.getCreationHelper();

        byte[] logo = loadLogoBytes();
        if (logo != null) {
            int idx = wb.addPicture(logo, Workbook.PICTURE_TYPE_PNG);
            var dr = sh.createDrawingPatriarch();
            var anc = ch.createClientAnchor(); anc.setCol1(0); anc.setRow1(0);
            dr.createPicture(anc, idx).resize(1.5);
        }

        // Encabezado
        Row hr = sh.createRow(4);
        String[] headers = {"Mes", "Cantidad"};
        var f = wb.createFont(); f.setBold(true);
        var s = wb.createCellStyle(); s.setFont(f);
        s.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.index);
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setAlignment(HorizontalAlignment.CENTER);
        for (int i = 0; i < headers.length; i++) {
            var c = hr.createCell(i); c.setCellValue(headers[i]); c.setCellStyle(s);
        }

        int r = 5;
        for (var d : datos) {
            var rw = sh.createRow(r++);
            rw.createCell(0).setCellValue(d.getMes());
            rw.createCell(1).setCellValue(d.getCantidad());
        }
        for (int i = 0; i < headers.length; i++) sh.autoSizeColumn(i);

        // Gráfico
        var ds = new DefaultCategoryDataset();
        datos.forEach(d -> ds.addValue(d.getCantidad(), "Cantidad", d.getMes()));
        var chart = ChartFactory.createBarChart(tituloReporte, "Mes", "Cantidad", ds);
        var cout = new ByteArrayOutputStream();
        ChartUtils.writeChartAsPNG(cout, chart, 500, 300);

        int cid = wb.addPicture(cout.toByteArray(), Workbook.PICTURE_TYPE_PNG);
        var cs = wb.createSheet("Gráfico");
        var dr2 = cs.createDrawingPatriarch();
        var anc2 = ch.createClientAnchor(); anc2.setCol1(0); anc2.setRow1(1);
        dr2.createPicture(anc2, cid).resize();

        wb.write(out);
        return out.toByteArray();
    } catch (Exception e) {
        throw new RuntimeException("Error Excel Reservas por Mes", e);
    }
}
}