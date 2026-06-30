package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class HabitacionVentasDTO {

private Integer habitacionNumero;
    private Long vecesVendida;
    private Double totalRecaudado;

    public HabitacionVentasDTO(Integer habitacionNumero, Long vecesVendida, Double totalRecaudado) {
        this.habitacionNumero = habitacionNumero;
        this.vecesVendida = vecesVendida;
        this.totalRecaudado = totalRecaudado;
    }

    public Integer getHabitacionNumero() {
        return habitacionNumero;
    }

    public void setHabitacionNumero(Integer habitacionNumero) {
        this.habitacionNumero = habitacionNumero;
    }

    public Long getVecesVendida() {
        return vecesVendida;
    }

    public void setVecesVendida(Long vecesVendida) {
        this.vecesVendida = vecesVendida;
    }

    public Double getTotalRecaudado() {
        return totalRecaudado;
    }

    public void setTotalRecaudado(Double totalRecaudado) {
        this.totalRecaudado = totalRecaudado;
    }
}