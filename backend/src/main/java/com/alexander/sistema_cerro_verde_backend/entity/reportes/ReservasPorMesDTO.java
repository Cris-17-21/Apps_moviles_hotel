package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class ReservasPorMesDTO {
    private String mes;
    private Long cantidad;
    private Double total;      // <— nuevo campo

    public ReservasPorMesDTO(String mes, Long cantidad, Double total) {
        this.mes = mes;
        this.cantidad = cantidad;
        this.total = total;
    }

    // getters y setters...
    public String getMes() { return mes; }
    public void setMes(String mes) { this.mes = mes; }

    public Long getCantidad() { return cantidad; }
    public void setCantidad(Long cantidad) { this.cantidad = cantidad; }

    public Double getTotal() { return total; }
    public void setTotal(Double total) { this.total = total; }
}
    

