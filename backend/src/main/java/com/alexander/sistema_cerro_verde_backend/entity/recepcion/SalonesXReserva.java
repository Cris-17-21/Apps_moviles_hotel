package com.alexander.sistema_cerro_verde_backend.entity.recepcion;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="salones_x_reserva")
public class SalonesXReserva {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_salon_reserv;
    private Integer precioreserva;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_salon")
    private Salones salon;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_reserva")
    @JsonBackReference
    private Reservas reserva;

    private Integer estado = 1;


    public Integer getId_salon_reserv() {
        return id_salon_reserv;
    }

    public void setId_salon_reserv(Integer id_salon_reserv) {
        this.id_salon_reserv = id_salon_reserv;
    }

    public Salones getSalon() {
        return salon;
    }

    public void setSalon(Salones salon) {
        this.salon = salon;
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

    public Integer getPrecioreserva() {
        return precioreserva;
    }

    public void setPrecioreserva(Integer precioreserva) {
        this.precioreserva = precioreserva;
    }

    @Override
    public String toString() {
        return "SalonesXReserva [id_salon_reserv=" + id_salon_reserv + ", precioreserva=" + precioreserva + ", salon="
                + salon + ", reserva=" + reserva + ", estado=" + estado + "]";
    }
    
}
