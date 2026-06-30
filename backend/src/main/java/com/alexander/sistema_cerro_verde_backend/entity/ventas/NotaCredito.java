package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import jakarta.persistence.*;
import java.util.Date;

@Entity
public class NotaCredito {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Date fechaEmision;

    private double monto;

    private String motivo;

    @ManyToOne
    @JoinColumn(name = "id_venta")
    private Ventas venta;

    @Lob
    @Column(name = "pdf_bytes", columnDefinition = "LONGBLOB")
    private byte[] pdfBytes;


    public Integer getId() {
        return id;
    }

    

    public void setId(Integer id) {
        this.id = id;
    }

    public Date getFechaEmision() {
        return fechaEmision;
    }

    public void setFechaEmision(Date fechaEmision) {
        this.fechaEmision = fechaEmision;
    }

    public double getMonto() {
        return monto;
    }

    public void setMonto(double monto) {
        this.monto = monto;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public Ventas getVenta() {
        return venta;
    }

    public void setVenta(Ventas venta) {
        this.venta = venta;
    }



    public byte[] getPdfBytes() {
        return pdfBytes;
    }



    public void setPdfBytes(byte[] pdfBytes) {
        this.pdfBytes = pdfBytes;
    }

    // Getters y setters

 
    
}
