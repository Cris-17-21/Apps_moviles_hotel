package com.alexander.sistema_cerro_verde_backend.excepciones;

public class NombreRolYaExisteException extends Exception {

    public NombreRolYaExisteException() {
        super("El nombre del rol ya existe en el sistema");
    }

    public NombreRolYaExisteException(String mensaje) {
        super(mensaje);
    }
}
