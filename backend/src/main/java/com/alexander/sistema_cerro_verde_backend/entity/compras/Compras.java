package com.alexander.sistema_cerro_verde_backend.entity.compras;

import java.util.List;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "compras")
@SQLDelete(sql = "UPDATE compras SET estado = 0 WHERE id_compra=?")
@SQLRestriction("estado = 1")
public class Compras {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_compra;
    private String numeroDoc;
    private String correlativo;
    private Double total;
    private Double flete;
    private Double descuento;
    private String fecha_compra;
    private Double igv;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;
    private Integer id_usuario;
    @ManyToOne
    @JoinColumn(name = "ruc_proveedor")
    private Proveedores proveedor;
    @OneToMany(mappedBy = "compra", cascade=CascadeType.ALL, orphanRemoval=true)
    @JsonManagedReference
    private List<DetallesCompra> detallecompra;
    @OneToMany(mappedBy = "compra")
    @JsonIgnore
    private List<MovimientosInventario> movimientoinventario;

    public Integer getId_compra() {
        return this.id_compra;
    }

    public void setId_compra(Integer id_compra) {
        this.id_compra = id_compra;
    }

    public String getFecha_compra() {
        return this.fecha_compra;
    }

    public void setFecha_compra(String fecha_compra) {
        this.fecha_compra = fecha_compra;
    }

    public Integer getEstado() {
        return this.estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public Integer getId_usuario() {
        return this.id_usuario;
    }

    public void setId_usuario(Integer id_usuario) {
        this.id_usuario = id_usuario;
    }

    

    public Proveedores getProveedor() {
        return this.proveedor;
    }

    public void setProveedor(Proveedores proveedor) {
        this.proveedor = proveedor;
    }

    public List<DetallesCompra> getDetallecompra() {
        return this.detallecompra;
    }

    public void setDetallecompra(List<DetallesCompra> detallecompra) {
        this.detallecompra = detallecompra;
    }

    public List<MovimientosInventario> getMovimientoinventario() {
        return this.movimientoinventario;
    }

    public void setMovimientoinventario(List<MovimientosInventario> movimientoinventario) {
        this.movimientoinventario = movimientoinventario;
    }

    public String getNumeroDoc() {
        return numeroDoc;
    }

    public void setNumeroDoc(String numeroDoc) {
        this.numeroDoc = numeroDoc;
    }

    public Double getTotal() {
        return total;
    }

    public void setTotal(Double total) {
        this.total = total;
    }

    public Double getFlete() {
        return flete;
    }

    public void setFlete(Double flete) {
        this.flete = flete;
    }

    public Double getDescuento() {
        return descuento;
    }

    public void setDescuento(Double descuento) {
        this.descuento = descuento;
    }

    public Double getIgv() {
        return igv;
    }

    public void setIgv(Double igv) {
        this.igv = igv;
    }

    public String getCorrelativo() {
        return correlativo;
    }

    public void setCorrelativo(String correlativo) {
        this.correlativo = correlativo;
    }

    public Sucursales getSucursal() {
        return sucursal;
    }

    public void setSucursal(Sucursales sucursal) {
        this.sucursal = sucursal;
    }
}