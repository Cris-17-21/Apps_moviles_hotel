package com.alexander.sistema_cerro_verde_backend.service.reportes;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProductoReporteDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProveedorReporteDTO;

public interface IReportesExportService {

    ByteArrayInputStream generarPdfProductos(List<ProductoReporteDTO> productos);

    ByteArrayOutputStream generarExcelProductos(List<ProductoReporteDTO> productos);

    ByteArrayInputStream generarPdfProveedores(List<ProveedorReporteDTO> proveedores);

    ByteArrayOutputStream generarExcelProveedores(List<ProveedorReporteDTO> proveedores);
}