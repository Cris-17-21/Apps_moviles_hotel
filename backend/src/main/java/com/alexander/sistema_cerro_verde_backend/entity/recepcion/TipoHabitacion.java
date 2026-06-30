package com.alexander.sistema_cerro_verde_backend.entity.recepcion;

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
@Table(name="tipo_habitacion")
public class TipoHabitacion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_tipo_habitacion;
    private String nombre;
    private Double precio;
    private Integer cantidadtipo;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;
    
    public Integer getId_tipo_habitacion() {
        return id_tipo_habitacion;
    }
    public void setId_tipo_habitacion(Integer id_tipo_habitacion) {
        this.id_tipo_habitacion = id_tipo_habitacion;
    }
    public String getNombre() {
        return nombre;
    }
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    public Double getPrecio() {
        return precio;
    }
    public void setPrecio(Double precio) {
        this.precio = precio;
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
    public Integer getCantidadtipo() {
        return cantidadtipo;
    }
    public void setCantidadtipo(Integer cantidadtipo) {
        this.cantidadtipo = cantidadtipo;
    }
    @Override
    public String toString() {
        return "TipoHabitacion [id_tipo_habitacion=" + id_tipo_habitacion + ", nombre=" + nombre + ", precio=" + precio
                + ", cantidadtipo=" + cantidadtipo + ", estado=" + estado + ", sucursal=" + sucursal + "]";
    }

    
}
