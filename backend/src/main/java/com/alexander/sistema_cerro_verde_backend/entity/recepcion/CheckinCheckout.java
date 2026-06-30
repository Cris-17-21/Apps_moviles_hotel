package com.alexander.sistema_cerro_verde_backend.entity.recepcion;

import java.time.LocalDateTime;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table
public class CheckinCheckout {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_check;
    private LocalDateTime fecha_checkin;
    private LocalDateTime fecha_checkout;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    @ManyToOne
    @JoinColumn(name = "id_reserva")
    private Reservas reserva;

    public Integer getId_check() {
        return id_check;
    }
    public void setId_check(Integer id_check) {
        this.id_check = id_check;
    }
    public LocalDateTime getFecha_checkin() {
        return fecha_checkin;
    }
    public void setFecha_checkin(LocalDateTime fecha_checkin) {
        this.fecha_checkin = fecha_checkin;
    }
    public LocalDateTime getFecha_checkout() {
        return fecha_checkout;
    }
    public void setFecha_checkout(LocalDateTime fecha_checkout) {
        this.fecha_checkout = fecha_checkout;
    }
    public Reservas getReserva() {
        return reserva;
    }
    public void setReserva(Reservas reserva) {
        this.reserva = reserva;
    }
    public Integer getEstado() {
        return estado;
    }
    public void setEstado(Integer estado) {
        this.estado = estado;
    }
    public Sucursales getSucursal() {
        return sucursal;
    }
    public void setSucursal(Sucursales sucursal) {
        this.sucursal = sucursal;
    }
    
    
}
