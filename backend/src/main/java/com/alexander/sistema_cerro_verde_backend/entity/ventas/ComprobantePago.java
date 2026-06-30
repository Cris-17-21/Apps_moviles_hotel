package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="comprobante_pago")
public class ComprobantePago {
    @Id
    private Integer idVenta;
    private String numSerieBoleta;
    private String numSerieFactura;
    private String pdfUrl;
    private String numComprobante;
    private String fechaEmision;

    //Relación de Uno a Uno con Venta
    @OneToOne
    @MapsId
    @JoinColumn(name="id_venta")
    @JsonIgnore
    private Ventas venta;

    public String getPdfUrl() {
        return pdfUrl;
    }

    public void setPdfUrl(String pdfUrl) {
        this.pdfUrl = pdfUrl;
    }

    public String getNumComprobante() {
        return numComprobante;
    }

    public void setNumComprobante(String numComprobante) {
        this.numComprobante = numComprobante;
    }

    public String getFechaEmision() {
        return fechaEmision;
    }

    public void setFechaEmision(String fechaEmision) {
        this.fechaEmision = fechaEmision;
    }

    public Ventas getVenta() {
        return venta;
    }

    public void setVenta(Ventas venta) {
        this.venta = venta;
    }

    public Integer getIdVenta() {
        return idVenta;
    }

    public void setIdVenta(Integer idVenta) {
        this.idVenta = idVenta;
    }

    public String getNumSerieBoleta() {
        return numSerieBoleta;
    }

    public void setNumSerieBoleta(String numSerieBoleta) {
        this.numSerieBoleta = numSerieBoleta;
    }

    public String getNumSerieFactura() {
        return numSerieFactura;
    }

    public void setNumSerieFactura(String numSerieFactura) {
        this.numSerieFactura = numSerieFactura;
    }

}
