package com.alexander.sistema_cerro_verde_backend.entity.reportes;

import java.math.BigDecimal;

public class ProductoReporteDTO {

    private String productoNombre;
    private Double cantidadComprada;
    private BigDecimal totalGastado;

    // Constructor: String, Double, BigDecimal
    public ProductoReporteDTO(String productoNombre, Double cantidadComprada, BigDecimal totalGastado) {
        this.productoNombre    = productoNombre;
        this.cantidadComprada  = cantidadComprada;
        this.totalGastado      = totalGastado;
    }

    // Getters y setters
    public String getProductoNombre() {
        return productoNombre;
    }

    public void setProductoNombre(String productoNombre) {
        this.productoNombre = productoNombre;
    }

    public Double getCantidadComprada() {
        return cantidadComprada;
    }

    public void setCantidadComprada(Double cantidadComprada) {
        this.cantidadComprada = cantidadComprada;
    }

    public BigDecimal getTotalGastado() {
        return totalGastado;
    }

    public void setTotalGastado(BigDecimal totalGastado) {
        this.totalGastado = totalGastado;
    }
}
