package com.alexander.sistema_cerro_verde_backend.entity.reportes;

public class HabitacionVentasDetalladoDTO {
    private Integer habitacionNumero;
    private Long vecesVendida;
    private Double totalRecaudado;
    private String productos;

    public HabitacionVentasDetalladoDTO(Integer habitacionNumero,
                                        Long vecesVendida,
                                        Double totalRecaudado,
                                        String productos) {
        this.habitacionNumero = habitacionNumero;
        this.vecesVendida     = vecesVendida;
        this.totalRecaudado   = totalRecaudado;
        this.productos        = productos;
    }

    public Integer getHabitacionNumero() { return habitacionNumero; }
    public void    setHabitacionNumero(Integer habitacionNumero) {
        this.habitacionNumero = habitacionNumero;
    }

    public Long    getVecesVendida()     { return vecesVendida; }
    public void    setVecesVendida(Long vecesVendida) {
        this.vecesVendida = vecesVendida;
    }

    public Double  getTotalRecaudado()   { return totalRecaudado; }
    public void    setTotalRecaudado(Double totalRecaudado) {
        this.totalRecaudado = totalRecaudado;
    }

    public String  getProductos()        { return productos; }
    public void    setProductos(String productos) {
        this.productos = productos;
    }
}