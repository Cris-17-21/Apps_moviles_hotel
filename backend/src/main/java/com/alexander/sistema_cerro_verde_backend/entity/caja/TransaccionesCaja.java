package com.alexander.sistema_cerro_verde_backend.entity.caja;

import java.util.Date;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.MetodosPago;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;
import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "transacciones_caja")
public class TransaccionesCaja {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_transaccion_caja")
    private Integer id;
    private Double montoTransaccion;
    private Date fechaHoraTransaccion;
    private String motivo;

    @ManyToOne
    @JoinColumn(name = "id_caja")
    private Cajas caja;

    @ManyToOne
    @JoinColumn(name = "id_tipo_transacciones")
    private TipoTransacciones tipo;

    @ManyToOne
    @JoinColumn(name = "id_venta")
    @JsonBackReference(value="venta")
    private Ventas venta;

    @ManyToOne
    @JoinColumn(name = "id_metodo_pago")
    private MetodosPago metodoPago;

    private Integer estado = 1;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Double getMontoTransaccion() {
        return montoTransaccion;
    }

    public void setMontoTransaccion(Double montoTransaccion) {
        this.montoTransaccion = montoTransaccion;
    }

    public Date getFechaHoraTransaccion() {
        return fechaHoraTransaccion;
    }

    public void setFechaHoraTransaccion(Date fechaHoraTransaccion) {
        this.fechaHoraTransaccion = fechaHoraTransaccion;
    }

    public Cajas getCaja() {
        return caja;
    }

    public void setCaja(Cajas caja) {
        this.caja = caja;
    }

    public TipoTransacciones getTipo() {
        return tipo;
    }

    public void setTipo(TipoTransacciones tipo) {
        this.tipo = tipo;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public Ventas getVenta() {
        return venta;
    }

    public void setVenta(Ventas venta) {
        this.venta = venta;
    }

    public MetodosPago getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(MetodosPago metodoPago) {
        this.metodoPago = metodoPago;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    @Override
    public String toString() {
        return "TransaccionesCaja [id=" + id + ", montoTransaccion=" + montoTransaccion + ", fechaHoraTransaccion="
                + fechaHoraTransaccion + ", motivo=" + motivo + ", caja=" + caja + ", tipo=" + tipo + ", venta=" + venta
                + ", metodoPago=" + metodoPago + ", estado=" + estado + "]";
    }
}
