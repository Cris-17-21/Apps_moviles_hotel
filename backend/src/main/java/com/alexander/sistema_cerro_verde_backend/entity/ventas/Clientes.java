package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import java.util.List;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name="clientes")
@SQLDelete(sql="UPDATE Clientes SET estado = 0 WHERE id_cliente=?")
@SQLRestriction("estado = 1")
public class Clientes {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Integer idCliente;
    private String dniRuc;
    private String nombre;
    private String telefono;
    private String correo;
    private String pais;
    private Integer estado = 1;

    //Relación de Uno a Muchos con Reserva

    //Relación de Uno a Muchos con Ventas
    @OneToMany(mappedBy="cliente")
    @JsonIgnore
    private List<Ventas> venta;

    public Integer getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(Integer idCliente) {
        this.idCliente = idCliente;
    }

    public String getDniRuc() {
        return dniRuc;
    }

    public void setDniRuc(String dniRuc) {
        this.dniRuc = dniRuc;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getPais() {
        return pais;
    }

    public void setPais(String pais) {
        this.pais = pais;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public List<Ventas> getVenta() {
        return venta;
    }

    public void setVenta(List<Ventas> venta) {
        this.venta = venta;
    }
}
