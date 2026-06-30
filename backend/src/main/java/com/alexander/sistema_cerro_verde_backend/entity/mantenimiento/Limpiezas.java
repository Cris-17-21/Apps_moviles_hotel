package com.alexander.sistema_cerro_verde_backend.entity.mantenimiento;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.util.Date;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;

import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Habitaciones;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;

@Entity
@Table(name = "limpiezas")
@SQLDelete(sql = "UPDATE limpiezas SET estado = 0 WHERE id_limpieza = ?")
@Where(clause = "estado = 1")
public class Limpiezas {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_limpieza;
    private Date fecha_registro;
    private Date fecha_solucion;
    private String observaciones;
    private String estado_limpieza;
    private Integer estado = 1;

    @ManyToOne
    @JoinColumn(name ="id_personal_limpieza")
    private PersonalLimpieza personal;

    @ManyToOne
    @JoinColumn(name = "id_habitacion")
    private Habitaciones habitacion;

    @ManyToOne
    @JoinColumn(name = "id_salon")
    private Salones salon;

    public Integer getId_limpieza() {
        return id_limpieza;
    }

    public void setId_limpieza(Integer id_limpieza) {
        this.id_limpieza = id_limpieza;
    }

    public Date getFecha_registro() {
        return fecha_registro;
    }

    public void setFecha_registro(Date fecha_registro) {
        this.fecha_registro = fecha_registro;
    }

    public Date getFecha_solucion() {
        return fecha_solucion;
    }

    public void setFecha_solucion(Date fecha_solucion) {
        this.fecha_solucion = fecha_solucion;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getEstado_limpieza() {
        return estado_limpieza;
    }

    public void setEstado_limpieza(String estado_limpieza) {
        this.estado_limpieza = estado_limpieza;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public PersonalLimpieza getPersonal() {
        return personal;
    }

    public void setPersonal(PersonalLimpieza personal) {
        this.personal = personal;
    }

    public Habitaciones getHabitacion() {
        return habitacion;
    }

    public void setHabitacion(Habitaciones habitacion) {
        this.habitacion = habitacion;
    }

    public Salones getSalon() {
        return salon;
    }

    public void setSalon(Salones salon) {
        this.salon = salon;
    }

    @Override
    public String toString() {
        return "Limpiezas [id_limpieza=" + id_limpieza + ", fecha_registro=" + fecha_registro + ", fecha_solucion="
                + fecha_solucion + ", observaciones=" + observaciones + ", estado_limpieza=" + estado_limpieza
                + ", estado=" + estado + ", personal=" + personal + ", habitacion=" + habitacion + ", salon=" + salon
                + "]";
    }
    
}
