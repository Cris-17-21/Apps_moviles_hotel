package com.alexander.sistema_cerro_verde_backend.service.seguridad;

public interface  IPasswordResetService {
    public void enviarLinkRecuperacion(String email);
}
