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
@Table
public class Conductores {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_conductor;
    private String nombre;
    private String dni;
    private String telefono;
    private String estado_conductor = "Disponible";
    private String placa;
    private String modelo_vehiculo;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    public Integer getId_conductor() {
        return id_conductor;
    }
    public void setId_conductor(Integer id_conductor) {
        this.id_conductor = id_conductor;
    }
    public String getNombre() {
        return nombre;
    }
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    public String getDni() {
        return dni;
    }
    public void setDni(String dni) {
        this.dni = dni;
    }
    public String getPlaca() {
        return placa;
    }
    public void setPlaca(String placa) {
        this.placa = placa;
    }
    public String getModelo_vehiculo() {
        return modelo_vehiculo;
    }
    public void setModelo_vehiculo(String modelo_vehiculo) {
        this.modelo_vehiculo = modelo_vehiculo;
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
    public String getTelefono() {
        return telefono;
    }
    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
    public String getEstado_conductor() {
        return estado_conductor;
    }
    public void setEstado_conductor(String estado_conductor) {
        this.estado_conductor = estado_conductor;
    }

    @Override
    public String toString() {
        return "Conductores [id_conductor=" + id_conductor + ", nombre=" + nombre + ", dni=" + dni + ", nro_telefono="
                + telefono + ", estado_conductor=" + estado_conductor + ", placa=" + placa + ", modelo_vehiculo="
                + modelo_vehiculo + ", estado=" + estado + ", sucursal=" + sucursal + "]";
    }
   
    
   

    

}
