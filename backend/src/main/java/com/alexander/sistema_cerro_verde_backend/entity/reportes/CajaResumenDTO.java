package com.alexander.sistema_cerro_verde_backend.entity.reportes;

import java.math.BigDecimal;

public class CajaResumenDTO {
    private String tipo;
    private BigDecimal total;

    // Constructor que Hibernate puede usar
    public CajaResumenDTO(String tipo, Double total) {
        this.tipo  = tipo;
        this.total = total != null ? BigDecimal.valueOf(total) : BigDecimal.ZERO;
    }

    // Constructor adicional si quieres seguir usándolo tú
    public CajaResumenDTO(String tipo, BigDecimal total) {
        this.tipo = tipo;
        this.total = total;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }
}
