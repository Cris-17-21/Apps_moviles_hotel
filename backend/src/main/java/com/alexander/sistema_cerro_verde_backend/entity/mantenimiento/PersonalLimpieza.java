package com.alexander.sistema_cerro_verde_backend.entity.mantenimiento;

import jakarta.persistence.Entity;
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
@Table(name = "personal_limpieza")
@SQLDelete(sql = "UPDATE personal_limpieza SET estado = 0 WHERE id_personal_limpieza = ?")
@Where(clause = "estado = 1")
public class PersonalLimpieza {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_personal_limpieza;
    private String nombres;
    private Integer estado = 1;// Estado activo por defecto

    @ManyToOne
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    public Integer getId_personal_limpieza() {
        return id_personal_limpieza;
    }

    public void setId_personal_limpieza(Integer id_personal_limpieza) {
        this.id_personal_limpieza = id_personal_limpieza;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
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
        return "PersonalLimpieza [id_personal_limpieza=" + id_personal_limpieza + ", nombres=" + nombres + ", estado="
                + estado + ", sucursal=" + sucursal + "]";
    }
    
}