package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class VentaResumenDTO {
private String nombre;
    private Long cantidad;
    private Double total;

    // Constructor que coincida exactamente con los aliases de tus queries
    public VentaResumenDTO(String nombre, Number cantidad, Number total) {
        this.nombre = nombre;
        this.cantidad = cantidad != null ? cantidad.longValue() : 0L;
    this.total = total != null ? total.doubleValue() : 0.0;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Long getCantidad() {
        return cantidad;
    }

    public void setCantidad(Long cantidad) {
        this.cantidad = cantidad;
    }

    public Double getTotal() {
        return total;
    }

    public void setTotal(Double total) {
        this.total = total;
    }

    // Getters y setters
    
}