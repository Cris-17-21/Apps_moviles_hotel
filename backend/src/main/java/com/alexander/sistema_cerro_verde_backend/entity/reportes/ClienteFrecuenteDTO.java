package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class ClienteFrecuenteDTO {
    private String clienteNombre;
    private Long cantidadCompras;
    private Double totalGastado;

    public ClienteFrecuenteDTO(String clienteNombre,
                               Long cantidadCompras,
                               Double totalGastado) {
        this.clienteNombre   = clienteNombre;
        this.cantidadCompras = cantidadCompras;
        this.totalGastado    = totalGastado;
    }

    public String getClienteNombre() {
        return clienteNombre;
    }

    public void setClienteNombre(String clienteNombre) {
        this.clienteNombre = clienteNombre;
    }

    public Long getCantidadCompras() {
        return cantidadCompras;
    }

    public void setCantidadCompras(Long cantidadCompras) {
        this.cantidadCompras = cantidadCompras;
    }

    public Double getTotalGastado() {
        return totalGastado;
    }

    public void setTotalGastado(Double totalGastado) {
        this.totalGastado = totalGastado;
    }
}