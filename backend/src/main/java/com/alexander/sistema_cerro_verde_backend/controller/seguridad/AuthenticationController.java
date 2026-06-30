package com.alexander.sistema_cerro_verde_backend.controller.seguridad;

import java.security.Principal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.config.JwtUtils;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.JwtRequest;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.JwtResponse;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.excepciones.UsuarioDeshabilitadoException;
import com.alexander.sistema_cerro_verde_backend.excepciones.UsuarioFoundException;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.UserDetailsServiceImpl;
import com.alexander.sistema_cerro_verde_backend.service.seguridad.jpa.UsuariosService;

@RestController
@CrossOrigin("*")
@RequestMapping("/cerro-verde")
public class AuthenticationController {
    @Autowired
    private AuthenticationManager authenticationManager;
    @Autowired
    private UserDetailsServiceImpl userxDetailsServiceImpl; 
    @Autowired
    private UsuariosService serviceUsuario;

    @Autowired
    private JwtUtils jwtUtils; 
    
    @PostMapping("/generar-token")
    public ResponseEntity<?> generarToken(@RequestBody JwtRequest jwtRequest) throws Exception {
        System.out.println("Intentando autenticar al usuario: " + jwtRequest.getUsername());
    
        try {
            autenticar(jwtRequest.getUsername(), jwtRequest.getPassword());
        } catch (UsuarioFoundException exception) {
            exception.printStackTrace();
            throw new Exception("Usuario no encontrado");
        }
    
        UserDetails userDetails = this.userxDetailsServiceImpl.loadUserByUsername(jwtRequest.getUsername());
        String token = this.jwtUtils.generateToken(userDetails);
        System.out.println("Token generado: " + token); // <-- Esto te dirá si el token realmente se generó

        Usuarios usuario = serviceUsuario.obtenerUsuario(jwtRequest.getUsername());
        usuario.setToken(token);
        serviceUsuario.actualizarUsuario(usuario);
        
        return ResponseEntity.ok(new JwtResponse(token));
    }
    
    
  
    private void autenticar(String username, String password) throws Exception {
        try {
            authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(username, password));
        } catch (DisabledException exception) {
            throw new UsuarioDeshabilitadoException("El usuario está deshabilitado.");
        } catch (BadCredentialsException e) {
            throw new Exception("Credenciales inválidas " + e.getMessage());
        }
    }
    
    

    @GetMapping("/usuario-actual")
    public Usuarios  obtenerUsuarioActual(Principal principal){
        return (Usuarios) this.userxDetailsServiceImpl.loadUserByUsername(principal.getName());
    }
}