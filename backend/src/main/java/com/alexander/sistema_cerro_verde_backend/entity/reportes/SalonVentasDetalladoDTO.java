package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class SalonVentasDetalladoDTO {
private String salonNombre;
    private Long vecesAlquilado;
    private Double totalRecaudado;
    private String productos;

    public SalonVentasDetalladoDTO(String salonNombre, Number vecesAlquilado, Number totalRecaudado, String productos) {
        this.salonNombre = salonNombre;
        this.vecesAlquilado = vecesAlquilado != null ? vecesAlquilado.longValue() : 0L;
        this.totalRecaudado = totalRecaudado != null ? totalRecaudado.doubleValue() : 0.0;
        this.productos = productos;
    }

    public String getSalonNombre() {
        return salonNombre;
    }

    public void setSalonNombre(String salonNombre) {
        this.salonNombre = salonNombre;
    }

    public Long getVecesAlquilado() {
        return vecesAlquilado;
    }

    public void setVecesAlquilado(Long vecesAlquilado) {
        this.vecesAlquilado = vecesAlquilado;
    }

    public Double getTotalRecaudado() {
        return totalRecaudado;
    }

    public void setTotalRecaudado(Double totalRecaudado) {
        this.totalRecaudado = totalRecaudado;
    }

    public String getProductos() {
        return productos;
    }

    public void setProductos(String productos) {
        this.productos = productos;
    }

    
}