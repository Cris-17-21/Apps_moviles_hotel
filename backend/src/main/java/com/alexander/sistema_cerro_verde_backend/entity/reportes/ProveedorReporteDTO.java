package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class ProveedorReporteDTO {
private String proveedorNombre;
    private Long cantidadFacturas;
    private Double totalGastado;
    private String productosComprados; // ← nuevo campo

    public ProveedorReporteDTO(String proveedorNombre, Long cantidadFacturas, Double totalGastado, String productosComprados) {
        this.proveedorNombre = proveedorNombre;
        this.cantidadFacturas = cantidadFacturas;
        this.totalGastado = totalGastado;
        this.productosComprados = productosComprados;
    }

    // Getters y setters
    public String getProductosComprados() {
        return productosComprados;
    }
    public void setProductosComprados(String productosComprados) {
        this.productosComprados = productosComprados;
    }

    public String getProveedorNombre() {
        return proveedorNombre;
    }

    public void setProveedorNombre(String proveedorNombre) {
        this.proveedorNombre = proveedorNombre;
    }

    public Long getCantidadFacturas() {
        return cantidadFacturas;
    }

    public void setCantidadFacturas(Long cantidadFacturas) {
        this.cantidadFacturas = cantidadFacturas;
    }

    public Double getTotalGastado() {
        return totalGastado;
    }

    public void setTotalGastado(Double totalGastado) {
        this.totalGastado = totalGastado;
    }
}