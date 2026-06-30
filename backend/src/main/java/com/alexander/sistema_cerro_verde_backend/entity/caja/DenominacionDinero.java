package com.alexander.sistema_cerro_verde_backend.entity.caja;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "denominacion_dinero")
public class DenominacionDinero {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_denominacion_dinero")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_tipo_denominacion")
    private TipoDenominacion tipo; //los tipos son moneda o billete
    
    private Double valor;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public TipoDenominacion getTipo() {
        return tipo;
    }

    public void setTipo(TipoDenominacion tipo) {
        this.tipo = tipo;
    }

    public Double getValor() {
        return valor;
    }

    public void setValor(Double valor) {
        this.valor = valor;
    }

    @Override
    public String toString() {
        return "PresentacionDinero [id=" + id + ", tipo=" + tipo + ", valor=" + valor + "]";
    }

    
}
