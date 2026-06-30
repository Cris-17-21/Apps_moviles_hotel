package com.alexander.sistema_cerro_verde_backend.entity.recepcion;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;

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
public class Huespedes {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_huesped;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_habres")
    private HabitacionesXReserva habres;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_cliente")
    private Clientes cliente;

    private Integer estado=1;

    
    public Integer getId_huesped() {
        return id_huesped;
    }


    public void setId_huesped(Integer id_huesped) {
        this.id_huesped = id_huesped;
    }


    public HabitacionesXReserva getHabres() {
        return habres;
    }


    public void setHabres(HabitacionesXReserva habres) {
        this.habres = habres;
    }


    public Clientes getCliente() {
        return cliente;
    }


    public void setCliente(Clientes cliente) {
        this.cliente = cliente;
    }

    public Integer getEstado() {
        return estado;
    }


    public void setEstado(Integer estado) {
        this.estado = estado;
    }


    @Override
    public String toString() {
        return "Huespedes [id_huesped=" + id_huesped + ", habres=" + habres + ", cliente=" + cliente + ", estado="
                + estado + "]";
    }

    
}