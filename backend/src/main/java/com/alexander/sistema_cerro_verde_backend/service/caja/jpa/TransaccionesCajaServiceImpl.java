package com.alexander.sistema_cerro_verde_backend.service.caja.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.entity.caja.Cajas;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoTransacciones;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.repository.caja.CajasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.caja.TipoTransaccionesRepository;
import com.alexander.sistema_cerro_verde_backend.repository.caja.TransaccionesCajaRepository;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.UsuariosRepository;
import com.alexander.sistema_cerro_verde_backend.service.caja.TransaccionesCajaService;

@Service
public class TransaccionesCajaServiceImpl implements TransaccionesCajaService {

    @Autowired
    private TransaccionesCajaRepository repository;

    @Autowired
    private TipoTransaccionesRepository transaccionesRepository;

    @Autowired
    private CajasRepository cajaRepository;
    
    @Autowired
    private UsuariosRepository usuarioRepository;

    private Usuarios getUsuarioAutenticado() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        return usuarioRepository.findByUsername(username);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TransaccionesCaja> buscarTodos() {
        return repository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<TransaccionesCaja> encontrarId(Integer id) {
        return repository.findById(id);
    }

    @Override
    @Transactional
    public TransaccionesCaja guardar(TransaccionesCaja transaccion) {
        Usuarios usuario = getUsuarioAutenticado();
        Optional<Cajas> cajaAbierta = cajaRepository.findByUsuarioAndEstadoCaja(usuario, "abierta"); // Suponiendo que 1 significa "abierta"
        
        if (cajaAbierta.isPresent()) {
            return repository.save(transaccion);
        } else {
            throw new RuntimeException("No hay una caja abierta para realizar la transacción.");
        }
    }

    @Override
    @Transactional
    public void eliminarId(Integer id) {
        repository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<TransaccionesCaja> buscarPorCaja(Cajas caja) {
        return repository.findByCaja(caja);
    }

    @Override
    public TipoTransacciones obtenerTipoPorId(Integer id) {
        Optional<TipoTransacciones> opt = transaccionesRepository.findById(id);
        TipoTransacciones tipoTransaccion = opt.get();
        return tipoTransaccion;
    }

}