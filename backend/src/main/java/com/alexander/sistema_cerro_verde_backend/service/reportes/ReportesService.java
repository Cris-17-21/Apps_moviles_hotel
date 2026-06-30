package com.alexander.sistema_cerro_verde_backend.service.reportes;

import java.util.List;

import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProductoReporteDTO;
import com.alexander.sistema_cerro_verde_backend.entity.reportes.ProveedorReporteDTO;
import com.alexander.sistema_cerro_verde_backend.repository.compras.ComprasRepository;

@Service
public class ReportesService {
private final ComprasRepository compraRepository;

    public ReportesService(ComprasRepository compraRepository) {
        this.compraRepository = compraRepository;
    }

    // ← Ahora con stockFilter
    public List<ProductoReporteDTO> obtenerProductosMasComprados(
            String desde,
            String hasta,
            String stockFilter   // ← nuevo parámetro
    ) {
        return compraRepository.findProductosMasCompradosNative(
            desde,
            hasta,
            stockFilter        // ← lo pasamos al repo
        );
    }

    public List<ProveedorReporteDTO> obtenerProveedoresMasComprados(String desde, String hasta) {
        return compraRepository.findProveedoresMasCompradosNative(desde, hasta);
    }
}