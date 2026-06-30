package com.alexander.sistema_cerro_verde_backend.entity.mantenimiento;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.util.Date;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Habitaciones;
import com.alexander.sistema_cerro_verde_backend.entity.recepcion.Salones;

@Entity
@Table(name = "incidencias")
@SQLDelete(sql = "UPDATE incidencias SET estado = 0 WHERE id_incidencia = ?")
@Where(clause = "estado = 1")
public class Incidencias {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_incidencia;

    private Date fecha_registro;
    private Date fecha_solucion;
    private String estado_incidencia;
    private String descripcion;

    private String gravedad;

    // NUEVO CAMPO: Observaciones cuando se completa la incidencia ✅
    private String observaciones_solucion;

    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    @ManyToOne
    @JoinColumn(name = "id_habitacion")
    private Habitaciones habitacion;

    @ManyToOne
    @JoinColumn(name = "id_tipo_incidencia")
    private TipoIncidencia tipoIncidencia;

    @ManyToOne
    @JoinColumn(name = "id_area")
    private AreasHotel area;

    @ManyToOne
    @JoinColumn(name = "id_salon")
    private Salones salon;

    // === GETTERS & SETTERS ===

    public Integer getId_incidencia() {
        return id_incidencia;
    }

    public void setId_incidencia(Integer id_incidencia) {
        this.id_incidencia = id_incidencia;
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

    public String getEstado_incidencia() {
        return estado_incidencia;
    }

    public void setEstado_incidencia(String estado_incidencia) {
        this.estado_incidencia = estado_incidencia;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getObservaciones_solucion() {
        return observaciones_solucion;
    }

    public void setObservaciones_solucion(String observaciones_solucion) {
        this.observaciones_solucion = observaciones_solucion;
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

    public Habitaciones getHabitacion() {
        return habitacion;
    }

    public void setHabitacion(Habitaciones habitacion) {
        this.habitacion = habitacion;
    }

    public TipoIncidencia getTipoIncidencia() {
        return tipoIncidencia;
    }

    public void setTipoIncidencia(TipoIncidencia tipoIncidencia) {
        this.tipoIncidencia = tipoIncidencia;
    }

    public AreasHotel getArea() {
        return area;
    }

    public void setArea(AreasHotel area) {
        this.area = area;
    }

    public Salones getSalon() {
        return salon;
    }

    public void setSalon(Salones salon) {
        this.salon = salon;
    }

    public String getGravedad() {
        return gravedad;
    }

    public void setGravedad(String gravedad) {
        this.gravedad = gravedad;
    }

    @Override
    public String toString() {
        return "Incidencias [id_incidencia=" + id_incidencia + ", fecha_registro=" + fecha_registro
                + ", fecha_solucion=" + fecha_solucion + ", estado_incidencia=" + estado_incidencia + ", descripcion="
                + descripcion + ", gravedad=" + gravedad + ", observaciones_solucion=" + observaciones_solucion
                + ", estado=" + estado + ", sucursal=" + sucursal + ", habitacion=" + habitacion + ", tipoIncidencia="
                + tipoIncidencia + ", area=" + area + ", salon=" + salon + "]";
    }

}
