package com.alexander.sistema_cerro_verde_backend.entity.ventas;

import java.util.List;

import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import com.alexander.sistema_cerro_verde_backend.entity.Sucursales;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;
import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
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
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "ventas")
@SQLDelete(sql = "UPDATE ventas SET estado = 0 WHERE id_venta = ?")
@SQLRestriction("estado = 1")
public class Ventas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer idVenta;
    private String fecha;
    private Double total;
    private Double descuento;
    private Double cargo;
    private Double igv;
    private Integer estado = 1;
    private String estadoVenta;
    private String tipoVenta;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_sucursal")
    private Sucursales sucursal;

    //Relación de muchos a uno con Usuario
    @ManyToOne
    @JoinColumn(name = "id_usuario")
    private Usuarios usuario;

    //Relación de muchos a uno con Cliente
    @ManyToOne
    @JoinColumn(name = "id_cliente")
    private Clientes cliente;

    //Relación de Uno a Muchos con MovimientosInventario
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL)
    private List<MovimientosInventario> movimientoInventario;

    //Relación de Uno a Muchos con DetalleVenta
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference(value="venta")
    private List<DetalleVenta> detalleVenta;

    //Relación de Uno a Uno con ComprobantePago
    @OneToOne(mappedBy = "venta", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private ComprobantePago comprobantePago;

    //Relación de Uno a Muchos con VentasXReservas
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference(value="venta")
    private List<VentasXReservas> ventaXReserva;

    //Relación de Uno a Muchos con VentaHabitacion
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference(value="venta")
    private List<VentaHabitacion> ventaHabitacion;

    //Relación de Uno a Muchos con VentaSalon
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference(value="venta")
    private List<VentaSalon> ventaSalon;

    //Relación de Uno a Muchos con VentaMetodoPago
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference(value="venta")
    private List<VentaMetodoPago> ventaMetodoPago;

    //Relación de Uno a Muchos con TransaccionesCaja
    @OneToMany(mappedBy = "venta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference(value="venta")
    private List<TransaccionesCaja> transaccionCaja;

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public Double getTotal() {
        return total;
    }

    public void setTotal(Double total) {
        this.total = total;
    }

    public Double getDescuento() {
        return descuento;
    }

    public void setDescuento(Double descuento) {
        this.descuento = descuento;
    }

    public Double getCargo() {
        return cargo;
    }

    public void setCargo(Double cargo) {
        this.cargo = cargo;
    }

    public Clientes getCliente() {
        return cliente;
    }

    public void setCliente(Clientes cliente) {
        this.cliente = cliente;
    }

    public Integer getIdVenta() {
        return idVenta;
    }

    public void setIdVenta(Integer idVenta) {
        this.idVenta = idVenta;
    }

    public List<DetalleVenta> getDetalleVenta() {
        return detalleVenta;
    }

    public void setDetalleVenta(List<DetalleVenta> detalleVenta) {
        this.detalleVenta = detalleVenta;
    }

    public Usuarios getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuarios usuario) {
        this.usuario = usuario;
    }

    public Integer getEstado() {
        return estado;
    }

    public void setEstado(Integer estado) {
        this.estado = estado;
    }

    public ComprobantePago getComprobantePago() {
        return comprobantePago;
    }

    public void setComprobantePago(ComprobantePago comprobantePago) {
        this.comprobantePago = comprobantePago;
        comprobantePago.setVenta(this);
    }

    public Double getIgv() {
        return igv;
    }

    public void setIgv(Double igv) {
        this.igv = igv;
    }

    public List<VentasXReservas> getVentaXReserva() {
        return ventaXReserva;
    }

    public void setVentaXReserva(List<VentasXReservas> ventaXReserva) {
        this.ventaXReserva = ventaXReserva;
    }

    public List<VentaHabitacion> getVentaHabitacion() {
        return ventaHabitacion;
    }

    public void setVentaHabitacion(List<VentaHabitacion> ventaHabitacion) {
        this.ventaHabitacion = ventaHabitacion;
    }

    public List<VentaSalon> getVentaSalon() {
        return ventaSalon;
    }

    public void setVentaSalon(List<VentaSalon> ventaSalon) {
        this.ventaSalon = ventaSalon;
    }

    public List<VentaMetodoPago> getVentaMetodoPago() {
        return ventaMetodoPago;
    }

    public void setVentaMetodoPago(List<VentaMetodoPago> ventaMetodoPago) {
        this.ventaMetodoPago = ventaMetodoPago;
    }

    public Sucursales getSucursal() {
        return sucursal;
    }

    public void setSucursal(Sucursales sucursal) {
        this.sucursal = sucursal;
    }

    public List<MovimientosInventario> getMovimientoInventario() {
        return movimientoInventario;
    }

    public void setMovimientoInventario(List<MovimientosInventario> movimientoInventario) {
        this.movimientoInventario = movimientoInventario;
    }

    public String getEstadoVenta() {
        return estadoVenta;
    }

    public void setEstadoVenta(String estadoVenta) {
        this.estadoVenta = estadoVenta;
    }

    public List<TransaccionesCaja> getTransaccionCaja() {
        return transaccionCaja;
    }

    public void setTransaccionCaja(List<TransaccionesCaja> transaccionCaja) {
        this.transaccionCaja = transaccionCaja;
    }

    public String getTipoVenta() {
        return tipoVenta;
    }

    public void setTipoVenta(String tipoVenta) {
        this.tipoVenta = tipoVenta;
    }
}
