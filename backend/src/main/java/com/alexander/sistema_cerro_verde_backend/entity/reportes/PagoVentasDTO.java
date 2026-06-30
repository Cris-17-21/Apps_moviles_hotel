package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class PagoVentasDTO {
    private String metodoPago;
    private Long vecesUsado;
    private Double totalRecibido;

    public PagoVentasDTO(String metodoPago, Long vecesUsado, Double totalRecibido) {
        this.metodoPago     = metodoPago;
        this.vecesUsado     = vecesUsado;
        this.totalRecibido  = totalRecibido;
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
}