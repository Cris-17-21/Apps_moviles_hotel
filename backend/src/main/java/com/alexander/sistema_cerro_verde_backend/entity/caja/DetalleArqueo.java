package com.alexander.sistema_cerro_verde_backend.entity.caja;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "detalle_arqueo")
public class DetalleArqueo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_detalle_arqueo")
    private Integer id;

    private Integer cantidad;
    
    @ManyToOne
    @JoinColumn(name = "id_arqueo")
    @JsonBackReference
    private ArqueosCaja arqueo;
    
    @ManyToOne
    @JoinColumn(name = "id_denominacion_dinero")
    private DenominacionDinero denominacion;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public ArqueosCaja getArqueo() {
        return arqueo;
    }

    public void setArqueo(ArqueosCaja arqueo) {
        this.arqueo = arqueo;
    }

    public DenominacionDinero getDenominacion() {
        return denominacion;
    }

    public void setDenominacion(DenominacionDinero denominacion) {
        this.denominacion = denominacion;
    }

    @Override
    public String toString() {
        return "DetalleArqueo [id=" + id + ", cantidad=" + cantidad + ", arqueo=" + arqueo + ", denominacion="
                + denominacion + "]";
    }

    
}
