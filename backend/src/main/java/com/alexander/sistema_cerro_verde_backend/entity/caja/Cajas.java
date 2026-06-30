package com.alexander.sistema_cerro_verde_backend.entity.caja;

import java.util.Date;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "cajas")
public class Cajas {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_caja")
    private Integer id;
    @Column(name = "monto_apertura")
    private Double montoApertura;
    @Column(name = "monto_cierre")
    private Double montoCierre;
    private Double saldoFisico;
    private Double saldoTotal;
    @Column(name = "fecha_apertura")
    private Date fechaApertura;
    @Column(name = "fecha_cierre")
    private Date fechaCierre;
    @Column(name = "estado_caja")
    private String estadoCaja;

    @OneToOne
    @JoinColumn(name = "id_usuario")
    private Usuarios usuario;

    @ManyToOne
    @JoinColumn(name = "id_usuario_cierre")
    private Usuarios usuarioCierre;

    @ManyToOne
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    private Integer estado = 1;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Double getMontoApertura() {
        return montoApertura;
    }

    public void setMontoApertura(Double montoApertura) {
        this.montoApertura = montoApertura;
    }

    public Double getMontoCierre() {
        return montoCierre;
    }

    public void setMontoCierre(Double montoCierre) {
        this.montoCierre = montoCierre;
    }

    public Date getFechaApertura() {
        return fechaApertura;
    }

    public void setFechaApertura(Date fechaApertura) {
        this.fechaApertura = fechaApertura;
    }

    public Date getFechaCierre() {
        return fechaCierre;
    }

    public void setFechaCierre(Date fechaCierre) {
        this.fechaCierre = fechaCierre;
    }

    public String getEstadoCaja() {
        return estadoCaja;
    }

    public void setEstadoCaja(String estadoCaja) {
        this.estadoCaja = estadoCaja;
    }

    public Usuarios getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuarios usuario) {
        this.usuario = usuario;
    }

    public Sucursales getSucursal() {
        return sucursal;
    }

    public void setSucursal(Sucursales sucursal) {
        this.sucursal = sucursal;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public Double getSaldoFisico() {
        return saldoFisico;
    }

    public void setSaldoFisico(Double saldoFisico) {
        this.saldoFisico = saldoFisico;
    }

    public Double getSaldoTotal() {
        return saldoTotal;
    }

    public void setSaldoTotal(Double saldoTotal) {
        this.saldoTotal = saldoTotal;
    }

    public Usuarios getUsuarioCierre() {
        return usuarioCierre;
    }

    public void setUsuarioCierre(Usuarios usuarioCierre) {
        this.usuarioCierre = usuarioCierre;
    }

    @Override
    public String toString() {
        return "Cajas [id=" + id + ", montoApertura=" + montoApertura + ", montoCierre=" + montoCierre + ", saldoFisico="
                + saldoFisico + ", saldoTotal="
                + saldoTotal + ", fechaApertura=" + fechaApertura + ", fechaCierre=" + fechaCierre + ", estadoCaja="
                + estadoCaja + ", usuario=" + usuario + ", usuarioCierre=" + usuarioCierre + ", sucursal=" + sucursal
                + ", estado=" + estado + "]";
    }
    
}
