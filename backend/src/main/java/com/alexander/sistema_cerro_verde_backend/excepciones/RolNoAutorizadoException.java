package com.alexander.sistema_cerro_verde_backend.excepciones;

public class RolNoAutorizadoException  extends Exception{
    public RolNoAutorizadoException(){
        super("El usuario ingreaado no tiene los permsiso necesarios para ingresar a este modulo");
    }
    public RolNoAutorizadoException(String mensaje){
        super(mensaje);
    }
    

}
