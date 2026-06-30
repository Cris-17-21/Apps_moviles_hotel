package com.alexander.sistema_cerro_verde_backend.service.seguridad;
import java.util.List;

import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
public interface IUsuariosService {
    public Usuarios guardarUsuario(Usuarios usuario) throws Exception;
    public Usuarios guardarUsuarioConPermisos(Usuarios usuario) throws Exception; 
    public Usuarios obtenerUsuario(String username);
    public void eliminarUsuario(Integer id);
    public Usuarios actualizarUsuario( Usuarios usuarioActualizado) throws Exception;
    public List<Usuarios> obtenerTodosUsuarios();
    public boolean existeUsuario(String username);
    public Usuarios obtenerUsuarioPorId(Integer id) throws Exception;
    public List<String> obtenerPermisosPorUsuarioId(Integer id) throws Exception;

    
    public void cambiarContraseña(Integer id, String nuevaContraseña) throws Exception;
}
    
