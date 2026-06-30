package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class PagoVentasDetalladoDTO {
    private String metodoPago;
    private Long vecesUsado;
    private Double totalRecibido;
    private String productos;
    private String salones;
    private String habitaciones;

    public PagoVentasDetalladoDTO(String metodoPago, Number vecesUsado, Number totalRecibido,
                                  String productos, String salones, String habitaciones) {
        this.metodoPago = metodoPago;
        this.vecesUsado = vecesUsado != null ? vecesUsado.longValue() : 0L;
        this.totalRecibido = totalRecibido != null ? totalRecibido.doubleValue() : 0.0;
        this.productos = productos;
        this.salones = salones;
        this.habitaciones = habitaciones;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public Long getVecesUsado() {
        return vecesUsado;
    }

    public void setVecesUsado(Long vecesUsado) {
        this.vecesUsado = vecesUsado;
    }

    public Double getTotalRecibido() {
        return totalRecibido;
    }

    public void setTotalRecibido(Double totalRecibido) {
        this.totalRecibido = totalRecibido;
    }

    public String getProductos() {
        return productos;
    }

    public void setProductos(String productos) {
        this.productos = productos;
    }

    public String getSalones() {
        return salones;
    }

    public void setSalones(String salones) {
        this.salones = salones;
    }

    public String getHabitaciones() {
        return habitaciones;
    }

    public void setHabitaciones(String habitaciones) {
        this.habitaciones = habitaciones;
    }

    
}
