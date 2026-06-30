package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name="venta_metodo_pago")
public class VentaMetodoPago {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Integer idVentaMetodoPago;
    private Double pago;

    //Relación de Muchos a Uno con Venta
    @ManyToOne
    @JoinColumn(name="id_venta")
    @JsonBackReference(value="venta")
    private Ventas venta;

    //Relación de Muchos a Uno con MetodoPago
    @ManyToOne
    @JoinColumn(name="id_metodo_pago")
    private MetodosPago metodoPago;

    public MetodosPago getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(MetodosPago metodoPago) {
        this.metodoPago = metodoPago;
    }

    public Ventas getVenta() {
        return venta;
    }

    public void setVenta(Ventas venta) {
        this.venta = venta;
    }

    public Integer getIdVentaMetodoPago() {
        return idVentaMetodoPago;
    }

    public void setIdVentaMetodoPago(Integer idVentaMetodoPago) {
        this.idVentaMetodoPago = idVentaMetodoPago;
    }

    public Double getPago() {
        return pago;
    }

    public void setPago(Double pago) {
        this.pago = pago;
    }
}
