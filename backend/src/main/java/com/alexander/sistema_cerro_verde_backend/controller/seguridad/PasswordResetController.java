package com.alexander.sistema_cerro_verde_backend.controller.seguridad;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.PasswordResetToken;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.PasswordResetTokenRepository;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.UsuariosRepository;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.jpa.PasswordResetService;


@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class PasswordResetController {

    @Autowired
    private PasswordResetTokenRepository tokenRepository;

    @Autowired
    private UsuariosRepository usuarioRepository;

    @Autowired
    private PasswordResetService passwordResetService ;
    
    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        String nuevaClave = request.get("nuevaClave");
    
        PasswordResetToken resetToken = tokenRepository.findByToken(token);
        if (resetToken == null || resetToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("Token inválido o expirado");
        }
    
        Usuarios usuario = resetToken.getUsuario();
        usuario.setPassword(new BCryptPasswordEncoder().encode(nuevaClave));
        usuarioRepository.save(usuario);
        tokenRepository.delete(resetToken);
        return ResponseEntity.ok("Contraseña actualizada con éxito");
    }
    


    @PostMapping("/enviar-link-recuperacion")
    public ResponseEntity<Map<String, String>> enviarLink(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        Map<String, String> response = new HashMap<>();
        try {
            passwordResetService.enviarLinkRecuperacion(email);
            response.put("mensaje", "Se envió un enlace de recuperación al correo proporcionado.");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            response.put("mensaje", e.getMessage()); // Aquí se captura el mensaje de la excepción lanzada
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response); // Status 400 para errores de cliente
        } catch (Exception e) {
            response.put("mensaje", "No se pudo enviar el correo: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    


}