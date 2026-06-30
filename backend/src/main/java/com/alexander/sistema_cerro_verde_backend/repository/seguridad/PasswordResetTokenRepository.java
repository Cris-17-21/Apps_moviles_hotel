package com.alexander.sistema_cerro_verde_backend.repository.seguridad;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.PasswordResetToken;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;

@Repository
public interface  PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Integer> {
    PasswordResetToken findByToken(String token);

    void deleteByUsuario(Usuarios usuario);

}
