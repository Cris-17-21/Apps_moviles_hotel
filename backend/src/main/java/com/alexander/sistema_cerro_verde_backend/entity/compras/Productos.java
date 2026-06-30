package com.alexander.sistema_cerro_verde_backend.entity.compras;

import java.util.List;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.DetalleVenta;
import com.fasterxml.jackson.annotation.JsonIgnore;

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
@Table(name = "productos")
@SQLDelete(sql = "UPDATE productos SET estado = 0 WHERE id_producto=?")
@SQLRestriction("estado=1")
public class Productos {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_producto;
    private String nombre;
    private String descripcion;
    private Integer stock;
    private Double precioVenta;
    private Integer estado = 1;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;
    @ManyToOne
    @JoinColumn(name = "id_categoria")
    private CategoriasProductos categoriaproducto;
    @OneToMany(mappedBy = "producto")
    @JsonIgnore
    private List<DetallesCompra> detallecompra;
    @OneToMany(mappedBy = "producto")
    @JsonIgnore
    private List<MovimientosInventario> movimientoinventario;
    @ManyToOne
    @JoinColumn(name="id_unidad")
    private UnidadMedida unidad;
    @OneToMany(mappedBy="producto", cascade=CascadeType.ALL)
    @JsonIgnore
    private List<DetalleVenta> detalleVenta;

    public Integer getId_producto() {
        return this.id_producto;
    }

    public void setId_producto(Integer id_producto) {
        this.id_producto = id_producto;
    }

    public String getNombre() {
        return this.nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return this.descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Integer getEstado() {
        return this.estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public CategoriasProductos getCategoriaproducto() {
        return this.categoriaproducto;
    }

    public void setCategoriaproducto(CategoriasProductos categoriaproducto) {
        this.categoriaproducto = categoriaproducto;
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

    @Override
    public String toString() {
        return "{" +
            " id_producto='" + getId_producto() + "'" +
            ", nombre='" + getNombre() + "'" +
            ", descripcion='" + getDescripcion() + "'" +
            ", estado='" + getEstado() + "'" +
            ", categoriaproducto='" + getCategoriaproducto() + "'" +
            ", detallecompra='" + getDetallecompra() + "'" +
            ", movimientoinventario='" + getMovimientoinventario() + "'" +
            "}";
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public Double getPrecioVenta() {
        return precioVenta;
    }

    public void setPrecioVenta(Double precioVenta) {
        this.precioVenta = precioVenta;
    }

    public UnidadMedida getUnidad() {
        return unidad;
    }

    public void setUnidad(UnidadMedida unidad) {
        this.unidad = unidad;
    }

    public List<DetalleVenta> getDetalleVenta() {
        return detalleVenta;
    }

    public void setDetalleVenta(List<DetalleVenta> detalleVenta) {
        this.detalleVenta = detalleVenta;
    }
    public Sucursales getSucursal() {
        return sucursal;
    }

    public void setSucursal(Sucursales sucursal) {
        this.sucursal = sucursal;
    }
}