package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Reservas;
import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="ventas_x_reservas")
public class VentasXReservas {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Integer idVentaReserva;

    //Relación de Muchos a Uno con Ventas
    @ManyToOne
    @JoinColumn(name="id_venta")
    @JsonBackReference(value="venta")
    private Ventas venta;

    //Relación de Muchos a Uno con Reservas
    @ManyToOne
    @JoinColumn(name="id_reserva")
    private Reservas reserva;

    public Integer getIdVentaReserva() {
        return idVentaReserva;
    }

    public void setIdVentaReserva(Integer idVentaReserva) {
        this.idVentaReserva = idVentaReserva;
    }

    public Ventas getVenta() {
        return venta;
    }

    public void setVenta(Ventas venta) {
        this.venta = venta;
    }

    public Reservas getReserva() {
        return reserva;
    }

    public void setReserva(Reservas reserva) {
        this.reserva = reserva;
    }
}
