package com.alexander.sistema_cerro_verde_backend.dto.ventas;

import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.DetalleVenta;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaHabitacion;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaMetodoPago;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaSalon;

public class VentaRequestDTO {

    private Integer idVenta;
    private String numComprobante;
    private String numSerieBoleta;
    private String numSerieFactura;
    private String dniRucCliente;
    private String cliente;
    private String fecha;
    private Double total;
    private Double descuento;
    private Double cargo;
    private Double igv;
    private String estadoVenta;

    // IDs de reserva asociada (si aplica)
    private List<Integer> idsReservas;

    // Detalle de productos
    private List<DetalleVenta> detalleVenta;

    // Habitaciones
    private List<VentaHabitacion> detalleHabitacion;

    // Salones
    private List<VentaSalon> detalleSalon;

    // Métodos de pago
    private List<VentaMetodoPago> metodosPago;

    // Getters y Setters

    public Integer getIdVenta() {
        return idVenta;
    }

    public void setIdVenta(Integer idVenta) {
        this.idVenta = idVenta;
    }

    public String getNumComprobante() {
        return numComprobante;
    }

    public void setNumComprobante(String numComprobante) {
        this.numComprobante = numComprobante;
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

    public String getDniRucCliente() {
        return dniRucCliente;
    }

    public void setDniRucCliente(String dniRucCliente) {
        this.dniRucCliente = dniRucCliente;
    }

    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

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

    public Double getIgv() {
        return igv;
    }

    public void setIgv(Double igv) {
        this.igv = igv;
    }

    public String getEstadoVenta() {
        return estadoVenta;
    }

    public void setEstadoVenta(String estadoVenta) {
        this.estadoVenta = estadoVenta;
    }

    public List<DetalleVenta> getDetalleVenta() {
        return detalleVenta;
    }

    public void setDetalleVenta(List<DetalleVenta> detalleVenta) {
        this.detalleVenta = detalleVenta;
    }

    public List<VentaHabitacion> getDetalleHabitacion() {
        return detalleHabitacion;
    }

    public void setDetalleHabitacion(List<VentaHabitacion> detalleHabitacion) {
        this.detalleHabitacion = detalleHabitacion;
    }

    public List<VentaSalon> getDetalleSalon() {
        return detalleSalon;
    }

    public void setDetalleSalon(List<VentaSalon> detalleSalon) {
        this.detalleSalon = detalleSalon;
    }

    public List<VentaMetodoPago> getMetodosPago() {
        return metodosPago;
    }

    public void setMetodosPago(List<VentaMetodoPago> metodosPago) {
        this.metodosPago = metodosPago;
    }

    public List<Integer> getIdsReservas() {
        return idsReservas;
    }

    public void setIdsReservas(List<Integer> idsReservas) {
        this.idsReservas = idsReservas;
    }
}
