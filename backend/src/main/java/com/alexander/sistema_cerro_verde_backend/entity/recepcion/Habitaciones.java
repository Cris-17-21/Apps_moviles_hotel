package com.alexander.sistema_cerro_verde_backend.entity.recepcion;

import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Incidencias;
import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.Limpiezas;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaHabitacion;
import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table
public class Habitaciones {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_habitacion;
    private Integer numero;
    private String estado_habitacion;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_piso")
    private Pisos piso;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_tipo_habitacion")
    private TipoHabitacion tipo_habitacion;

    //Relacion de Uno a Muchos con VenntaHabitacion
    @OneToMany(mappedBy="habitacion", cascade=CascadeType.ALL)
    @JsonIgnore
    private List<VentaHabitacion> ventaHabitacion;

    @OneToMany(mappedBy = "habitacion")
    @JsonIgnore
    private List<Incidencias> incidencias;

    @OneToMany(mappedBy = "habitacion")
    @JsonIgnore
    private List<Limpiezas> limpiezas;
    
    public Integer getId_habitacion() {
        return id_habitacion;
    }

    public void setId_habitacion(Integer id_habitacion) {
        this.id_habitacion = id_habitacion;
    }

    public Integer getNumero() {
        return numero;
    }

    public void setNumero(Integer numero) {
        this.numero = numero;
    }

    

    public String getEstado_habitacion() {
        return estado_habitacion;
    }

    public void setEstado_habitacion(String estado_habitacion) {
        this.estado_habitacion = estado_habitacion;
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

    public TipoHabitacion getTipo_habitacion() {
        return tipo_habitacion;
    }

    public void setTipo_habitacion(TipoHabitacion tipo_habitacion) {
        this.tipo_habitacion = tipo_habitacion;
    }

    public Pisos getPiso() {
        return piso;
    }

    public void setPiso(Pisos piso) {
        this.piso = piso;
    }

    public List<VentaHabitacion> getVentaHabitacion() {
        return ventaHabitacion;
    }

    public void setVentaHabitacion(List<VentaHabitacion> ventaHabitacion) {
        this.ventaHabitacion = ventaHabitacion;
    }

    public List<Incidencias> getIncidencias() {
        return incidencias;
    }

    public void setIncidencias(List<Incidencias> incidencias) {
        this.incidencias = incidencias;
    }

    public List<Limpiezas> getLimpiezas() {
        return limpiezas;
    }

    public void setLimpiezas(List<Limpiezas> limpiezas) {
        this.limpiezas = limpiezas;
    }
    
} 



