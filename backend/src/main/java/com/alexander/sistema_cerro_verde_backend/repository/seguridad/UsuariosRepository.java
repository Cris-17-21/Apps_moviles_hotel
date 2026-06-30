package com.alexander.sistema_cerro_verde_backend.repository.seguridad;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
@Repository
public interface UsuariosRepository extends JpaRepository<Usuarios, Integer> {
    public Usuarios findByUsername(String username);
    public Optional<Usuarios> findByEmail(String email);
    public boolean existsByEmail(String email);
    boolean existsByUsername(String username);
    @Query(value = "SELECT p.nombre_permiso " +
    "FROM usuarios u " +
    "JOIN roles r ON u.id_rol = r.id_rol " +
    "JOIN roles_permisos rp ON r.id_rol = rp.id_rol " +
    "JOIN permisos p ON rp.id_permiso = p.id_permiso " +
    "WHERE u.id_usuario = :idUsuario", 
nativeQuery = true)
List<String> obtenerPermisosPorUsuarioId(@Param("idUsuario") Integer idUsuario);


} 