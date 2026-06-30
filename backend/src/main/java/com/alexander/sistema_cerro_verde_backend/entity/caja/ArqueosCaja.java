package com.alexander.sistema_cerro_verde_backend.entity.caja;

import java.util.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "arqueos_caja")
public class ArqueosCaja {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_arqueo")
    private Integer id;

    private String observaciones;

    @ManyToOne
    @JoinColumn(name = "id_caja")
    private Cajas caja;

    @OneToMany(mappedBy = "arqueo", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private List<DetalleArqueo> detalles;

    @Column(name = "fecha_arqueo")
    private Date fechaArqueo;

    private Double totalArqueo;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public Cajas getCaja() {
        return caja;
    }

    public void setCaja(Cajas caja) {
        this.caja = caja;
    }

    public List<DetalleArqueo> getDetalles() {
        return detalles;
    }

    public void setDetalles(List<DetalleArqueo> detalles) {
        this.detalles = detalles;
    }

    public Date getFechaArqueo() {
        return fechaArqueo;
    }

    public void setFechaArqueo(Date fechaArqueo) {
        this.fechaArqueo = fechaArqueo;
    }

    public Double getTotalArqueo() {
        return totalArqueo;
    }

    public void setTotalArqueo(Double totalArqueo) {
        this.totalArqueo = totalArqueo;
    }

    @Override
    public String toString() {
        return "ArqueosCaja [id=" + id + ", observaciones=" + observaciones + ", caja=" + caja + ", detalles="
                + detalles + ", fechaArqueo=" + fechaArqueo + ", totalArqueo=" + totalArqueo + "]";
    }
    
}
