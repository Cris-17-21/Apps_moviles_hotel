package com.alexander.sistema_cerro_verde_backend.service.seguridad.jpa;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.PasswordResetToken;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.PasswordResetTokenRepository;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.UsuariosRepository;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.IPasswordResetService;

@Service
public class PasswordResetService implements IPasswordResetService {

    @Autowired
    private UsuariosRepository usuarioRepository;

    @Autowired
    private PasswordResetTokenRepository tokenRepository;

    @Autowired
    private JavaMailSender mailSender;
    @Override
    public void enviarLinkRecuperacion(String email) {
    System.out.println("Intentando enviar correo a: " + email);

    Optional<Usuarios> usuarioOpt = usuarioRepository.findByEmail(email);

    if (usuarioOpt.isPresent()) {
        Usuarios usuario = usuarioOpt.get();
        
        String token = UUID.randomUUID().toString();

        PasswordResetToken resetToken = new PasswordResetToken();
        resetToken.setToken(token);
        resetToken.setUsuario(usuario);
        resetToken.setExpiryDate(LocalDateTime.now().plusMinutes(30));

        tokenRepository.save(resetToken);

        String link = "http://localhost:4200/reset-password?token=" + token;

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(usuario.getEmail());
        message.setSubject("Recuperación de contraseña");
        message.setText("Haz clic aquí para restablecer tu contraseña: " + link);

        try {
            mailSender.send(message);
            System.out.println("Correo enviado correctamente.");
        } catch (Exception e) {
            System.err.println("Error al enviar el correo:");
            e.printStackTrace();
            throw new RuntimeException("No se pudo enviar el correo. Verifica configuración SMTP.", e);
        }
    } else {
        System.err.println("No se encontró el correo: " + email);
        throw new RuntimeException("El correo no está registrado en el sistema."); // Lanzar una excepción
    }
}

}
