package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;
import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="venta_salon")
public class VentaSalon {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Integer idVentaSalon;
    private Integer horas;
    private Integer dias;
    private Integer subTotal;

    //Relación de Muchos a Uno con Venta
    @ManyToOne
    @JoinColumn(name="id_venta")
    @JsonBackReference(value="venta")
    private Ventas venta;

    //Relación de Mucho a Uno con Salones
    @ManyToOne
    @JoinColumn(name="id_salon")
    private Salones salon;

    public Integer getIdVentaSalon() {
        return idVentaSalon;
    }

    public void setIdVentaSalon(Integer idVentaSalon) {
        this.idVentaSalon = idVentaSalon;
    }

    public Integer getHoras() {
        return horas;
    }

    public void setHoras(Integer horas) {
        this.horas = horas;
    }

    public Integer getDias() {
        return dias;
    }

    public void setDias(Integer dias) {
        this.dias = dias;
    }

    public Ventas getVenta() {
        return venta;
    }

    public void setVenta(Ventas venta) {
        this.venta = venta;
    }

    public Salones getSalon() {
        return salon;
    }

    public void setSalon(Salones salon) {
        this.salon = salon;
    }

    public Integer getSubTotal() {
        return subTotal;
    }

    public void setSubTotal(Integer subTotal) {
        this.subTotal = subTotal;
    }
}
