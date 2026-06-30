package com.alexander.sistema_cerro_verde_backend.entity.IA;

import java.util.List;

public class PrecioResponse {
    private String fecha;
    private String evento;
    private String temporada;
    private List<TipoPrecio> precios;

    public static class TipoPrecio {
        private String tipo_habitacion;
        private double precio_predicho;
        
        public String getTipo_habitacion() {
            return tipo_habitacion;
        }
        public void setTipo_habitacion(String tipo_habitacion) {
            this.tipo_habitacion = tipo_habitacion;
        }
        public double getPrecio_predicho() {
            return precio_predicho;
        }
        public void setPrecio_predicho(double precio_predicho) {
            this.precio_predicho = precio_predicho;
        }

        // Getters y setters
    }

    public String getFecha() {
        return fecha;
    }
    public void setFecha(String fecha) {
        this.fecha = fecha;
    }
    public String getEvento() {
        return evento;
    }
    public void setEvento(String evento) {
        this.evento = evento;
    }
    public String getTemporada() {
        return temporada;
    }
    public void setTemporada(String temporada) {
        this.temporada = temporada;
    }
    public List<TipoPrecio> getPrecios() {
        return precios;
    }
    public void setPrecios(List<TipoPrecio> precios) {
        this.precios = precios;
    }
}