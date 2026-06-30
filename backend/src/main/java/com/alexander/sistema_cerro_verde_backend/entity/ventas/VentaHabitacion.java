package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Habitaciones;
import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="venta_habitacion")
public class VentaHabitacion {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Integer idVentaHabitacion;
    private Integer dias;
    private Double subTotal;

    //Relacion de Muchos a Uno con Venta
    @ManyToOne
    @JoinColumn(name="id_venta")
    @JsonBackReference(value="venta")
    private Ventas venta;

    //Relación de Muchos a Uno con Habitaciones
    @ManyToOne
    @JoinColumn(name="id_habitacion")
    private Habitaciones habitacion;

    public Integer getIdVentaHabitacion() {
        return idVentaHabitacion;
    }

    public void setIdVentaHabitacion(Integer idVentaHabitacion) {
        this.idVentaHabitacion = idVentaHabitacion;
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

    public Habitaciones getHabitacion() {
        return habitacion;
    }

    public void setHabitacion(Habitaciones habitacion) {
        this.habitacion = habitacion;
    }

    public Double getSubTotal() {
        return subTotal;
    }

    public void setSubTotal(Double subTotal) {
        this.subTotal = subTotal;
    }
}
