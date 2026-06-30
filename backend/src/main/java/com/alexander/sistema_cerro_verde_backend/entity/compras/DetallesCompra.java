package com.alexander.sistema_cerro_verde_backend.entity.compras;

import java.math.BigDecimal;

import org.hibernate.annotations.SQLDelete;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "detalles_compra", uniqueConstraints = @UniqueConstraint(columnNames = {"id_compra","id_producto"}))
@SQLDelete(sql = "UPDATE detalles_compra SET estado = 0 WHERE id_detalle_compra=?")
public class DetallesCompra {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_detalle_compra;
    private Double cantidad;
    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal precio;
    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal subtotal;
    private Integer estado = 1;
    @ManyToOne
    @JoinColumn(name = "id_compra")
    @JsonBackReference
    private Compras compra;
    @ManyToOne
    @JoinColumn(name = "id_producto")
    private Productos producto;

    public Integer getId_detalle_compra() {
        return this.id_detalle_compra;
    }

    public void setId_detalle_compra(Integer id_detalle_compra) {
        this.id_detalle_compra = id_detalle_compra;
    }

    public Double getCantidad() {
        return this.cantidad;
    }

    public void setCantidad(Double cantidad) {
        this.cantidad = cantidad;
    }

    public BigDecimal getPrecio() {
        return this.precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
    }

    public BigDecimal getSubtotal() {
        return this.subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public Integer getEstado() {
        return this.estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public Compras getCompra() {
        return this.compra;
    }

    public void setCompra(Compras compra) {
        this.compra = compra;
    }

    public Productos getProducto() {
        return this.producto;
    }

    public void setProducto(Productos producto) {
        this.producto = producto;
    }

    @Override
    public String toString() {
        return "{" +
            " id_detalle_compra='" + getId_detalle_compra() + "'" +
            ", cantidad='" + getCantidad() + "'" +
            ", precio='" + getPrecio() + "'" +
            ", subtotal='" + getSubtotal() + "'" +
            ", estado='" + getEstado() + "'" +
            ", producto=" + (producto != null ? producto.getId_producto() : "null") +
            ", compra_id=" + (compra != null ? compra.getId_compra() : "null") +
            "}";
    }

}