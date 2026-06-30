package com.alexander.sistema_cerro_verde_backend.excepciones;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(CorreoYaRegistradoException.class)
    public ResponseEntity<Map<String, String>> handleCorreoYaRegistrado(CorreoYaRegistradoException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(UsuarioYaRegistradoException.class)
    public ResponseEntity<Map<String, String>> handleUsuarioYaRegistrado(UsuarioYaRegistradoException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(NombreRolYaExisteException.class)
    public ResponseEntity<Map<String, String>> handleNombreRolYaExiste(NombreRolYaExisteException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(UsuarioDeshabilitadoException.class)
    public ResponseEntity<Map<String, String>> handleUsuarioDeshabilitadoException(UsuarioDeshabilitadoException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(createErrorResponse("USUARIO DESHABILITADO"));
    }
    
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<Map<String, String>> handleBadCredentialsException(BadCredentialsException exception) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(createErrorResponse("Credenciales inválidas"));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception exception) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createErrorResponse("Error interno del servidor"));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegalArgumentException(IllegalArgumentException ex) {
        return new ResponseEntity<>(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    // Método auxiliar para crear la respuesta de error como un Map
    private Map<String, String> createErrorResponse(String message) {
        Map<String, String> errorResponse = new HashMap<>();
        errorResponse.put("error", message);
        return errorResponse;
    }
}
