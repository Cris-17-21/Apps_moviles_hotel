package com.alexander.sistema_cerro_verde_backend.entity.recepcion;

import java.time.LocalDateTime;
import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Clientes;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentasXReservas;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

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
public class Reservas {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_reserva;
    private LocalDateTime fecha_inicio;
    private LocalDateTime fecha_fin;
    private String estado_reserva;
    private String comentarios;
    private Integer nro_persona;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;;
    private String tipo;

    @ManyToOne
    @JoinColumn(name="id_cliente")
    private Clientes cliente;

    @OneToMany(mappedBy = "reserva", cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<HabitacionesXReserva> habitacionesXReserva;

    @OneToMany(mappedBy = "reserva", cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<SalonesXReserva> salonesXReserva;

    @OneToMany(mappedBy="reserva", cascade=CascadeType.ALL)
    @JsonIgnore
    private List<VentasXReservas> ventaXReserva;


    public Integer getId_reserva() {
        return id_reserva;
    }

    public void setId_reserva(Integer id_reserva) {
        this.id_reserva = id_reserva;
    }
    
    public LocalDateTime getFecha_inicio() {
        return fecha_inicio;
    }

    public void setFecha_inicio(LocalDateTime fecha_inicio) {
        this.fecha_inicio = fecha_inicio;
    }

    public LocalDateTime getFecha_fin() {
        return fecha_fin;
    }

    public void setFecha_fin(LocalDateTime fecha_fin) {
        this.fecha_fin = fecha_fin;
    }

    public String getEstado_reserva() {
        return estado_reserva;
    }

    public void setEstado_reserva(String estado_reserva) {
        this.estado_reserva = estado_reserva;
    }

    public String getComentarios() {
        return comentarios;
    }

    public void setComentarios(String comentarios) {
        this.comentarios = comentarios;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public Clientes getCliente() {
        return cliente;
    }

    public void setCliente(Clientes cliente) {
        this.cliente = cliente;
    }

    public List<HabitacionesXReserva> getHabitacionesXReserva() {
        return habitacionesXReserva;
    }

    public void setHabitacionesXReserva(List<HabitacionesXReserva> habitacionesXReserva) {
        this.habitacionesXReserva = habitacionesXReserva;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public List<SalonesXReserva> getSalonesXReserva() {
        return salonesXReserva;
    }

    public void setSalonesXReserva(List<SalonesXReserva> salonesXReserva) {
        this.salonesXReserva = salonesXReserva;
    }

    public List<VentasXReservas> getVentaXReserva() {
        return ventaXReserva;
    }

    public void setVentaXReserva(List<VentasXReservas> ventaXReserva) {
        this.ventaXReserva = ventaXReserva;
    }

    public Integer getNro_persona() {
        return nro_persona;
    }

    public void setNro_persona(Integer nro_persona) {
        this.nro_persona = nro_persona;
    }
    public Sucursales getSucursal() {
        return sucursal;
    }
    public void setSucursal(Sucursales sucursal) {
        this.sucursal = sucursal;
    }
    
    
    

}
