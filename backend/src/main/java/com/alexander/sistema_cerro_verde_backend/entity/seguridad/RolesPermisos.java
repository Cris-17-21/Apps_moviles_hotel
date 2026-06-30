package com.alexander.sistema_cerro_verde_backend.entity.seguridad;
import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "roles_permisos")
public class RolesPermisos {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="id_rol_permiso")
    private Integer rolesPermisosId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_rol")
    @JsonBackReference  // Bien aplicado para evitar ciclo de referencia
    private Roles roles;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_permiso")
    private Permisos permisos;

    public RolesPermisos() {}  // Constructor vacío


    public Integer getRolesPermisosId() {
        return rolesPermisosId;
    }

    public void setRolesPermisosId(Integer rolesPermisosId) {
        this.rolesPermisosId = rolesPermisosId;
    }

    public Roles getRoles() {
        return roles;
    }

    public void setRoles(Roles rol) {
        this.roles = rol;
    }

    public Permisos getPermisos() {
        return permisos;
    }

    public void setPermisos(Permisos permisos) {
        this.permisos = permisos;
    }

    
}
