package com.alexander.sistema_cerro_verde_backend.entity.mantenimiento;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;


import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;


@Entity
@Table(name = "tipo_incidencia")
@SQLDelete(sql = "UPDATE tipo_incidencia SET estado = 0 WHERE id_tipo_incidencia = ?")
@Where(clause = "estado = 1")
public class TipoIncidencia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_tipo_incidencia;
    private String nombre;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    public Integer getId_tipo_incidencia() {
        return id_tipo_incidencia;
    }

    public void setId_tipo_incidencia(Integer id_tipo_incidencia) {
        this.id_tipo_incidencia = id_tipo_incidencia;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
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

    @Override
    public String toString() {
        return "TipoIncidencia [id_tipo_incidencia=" + id_tipo_incidencia + ", nombre=" + nombre + ", estado=" + estado
                + ", sucursal=" + sucursal + "]";
    }
    
}