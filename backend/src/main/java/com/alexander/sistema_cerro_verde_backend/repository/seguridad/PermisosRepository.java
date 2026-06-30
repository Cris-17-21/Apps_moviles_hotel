package com.alexander.sistema_cerro_verde_backend.repository.seguridad;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Permisos;

@Repository
public interface PermisosRepository extends JpaRepository<Permisos,Integer>{
    Optional<Permisos> findByNombrePermiso(String nombrePermiso);
    List<Permisos> findByModulo_IdModulo(Integer idModulo);

} 