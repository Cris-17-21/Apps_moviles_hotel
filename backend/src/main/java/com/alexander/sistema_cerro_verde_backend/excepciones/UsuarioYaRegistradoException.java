package com.alexander.sistema_cerro_verde_backend.excepciones;

public class UsuarioYaRegistradoException extends RuntimeException {
    public UsuarioYaRegistradoException() {
        super("El nombre de usuario ya está en uso");
    }
}