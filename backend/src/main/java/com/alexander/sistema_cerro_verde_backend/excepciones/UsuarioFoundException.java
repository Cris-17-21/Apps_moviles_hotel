package com.alexander.sistema_cerro_verde_backend.excepciones;


public class UsuarioFoundException extends Exception {
    public UsuarioFoundException(){
        super("El usuario con ese username ya exite en la abse de datos, vuelva a intentar");
    }
    public UsuarioFoundException(String mensaje){
        super(mensaje);
    }
}
