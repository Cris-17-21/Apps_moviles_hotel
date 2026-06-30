package com.alexander.sistema_cerro_verde_backend.controller.seguridad;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.excepciones.CorreoYaRegistradoException;
import com.alexander.sistema_cerro_verde_backend.excepciones.UsuarioYaRegistradoException;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.IUsuariosService;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.jpa.UsuariosService;

@RestController
@RequestMapping("/cerro-verde/usuarios")
@CrossOrigin("*")
public class UsuarioController {

    @Autowired
    private IUsuariosService usuarioService;

    @Autowired
    private UsuariosService usuarioServiceImpl;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @GetMapping("/")
    public List<Usuarios> listarUsuarios(){
        return usuarioServiceImpl.obtenerTodosUsuarios();
    }

    @PostMapping("/")
    public Usuarios guardUsuario(@RequestBody Usuarios usuario) throws Exception {
        usuario.setPassword(this.bCryptPasswordEncoder.encode(usuario.getPassword()));
        return usuarioService.guardarUsuario(usuario);
    }
    
    @GetMapping("/{usuarioId}")
    public Usuarios obtenerUsuarioPorId(@PathVariable("usuarioId") Integer usuarioId) throws Exception {
        return usuarioServiceImpl.obtenerUsuarioPorId(usuarioId);
    }

    @GetMapping("/username/{usuario}")
    public Usuarios obtenerUsuario(@PathVariable("usuario") String usuario) {
        return usuarioServiceImpl.obtenerUsuario(usuario);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> editarUsuario(@PathVariable Integer id, @RequestBody Usuarios usuario) {
        try {
            // Establecer el ID que viene por la URL al objeto usuario
            usuario.setIdUsuario(id);

            Usuarios usuarioActualizado = usuarioServiceImpl.actualizarUsuario(usuario);
            return ResponseEntity.ok(usuarioActualizado);

        } catch (CorreoYaRegistradoException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("El correo ya está registrado.");
        } catch (UsuarioYaRegistradoException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("El nombre de usuario ya está registrado.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al editar el usuario.");
        }
    }
  
    @DeleteMapping("/{usuarioId}")
    public void eliminarUsuario(@PathVariable("usuarioId") Integer usuarioId){
        usuarioServiceImpl.eliminarUsuario(usuarioId);
    }

    @GetMapping("/{id}/permisos")
    public ResponseEntity<List<String>> obtenerPermisosPorUsuario(@PathVariable Integer id) {
        try {
            List<String> permisos = usuarioService.obtenerPermisosPorUsuarioId(id);
            return ResponseEntity.ok(permisos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @PutMapping("/{id}/cambiar-password")
    public ResponseEntity<?> cambiarPassword(@PathVariable Integer id, @RequestBody String nuevaPassword) {
        try {
            Optional<Usuarios> optional = usuarioServiceImpl.getUsuariosRepository().findById(id);
    
            if (optional.isPresent()) {
                Usuarios usuario = optional.get();
                // Si estás recibiendo con comillas, límpialo
                String passwordEncriptada = bCryptPasswordEncoder.encode(nuevaPassword.replace("\"", ""));
                usuario.setPassword(passwordEncriptada);
                usuarioServiceImpl.getUsuariosRepository().save(usuario);
    
                return ResponseEntity.ok("Contraseña actualizada correctamente.");
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuario no encontrado.");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al cambiar la contraseña.");
        }
    }

    
}
