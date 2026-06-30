package com.alexander.sistema_cerro_verde_backend.service.compras.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.dto.compras.MovimientoInventarioDTO;
import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;
import com.alexander.sistema_cerro_verde_backend.repository.compras.MovimientosInventarioRepository;
import com.alexander.sistema_cerro_verde_backend.service.compras.IMovimientosInventarioService;

@Service
public class MovimientosInventariosService implements IMovimientosInventarioService {

    @Autowired
    private MovimientosInventarioRepository repoMovimientosInventario;

    @Override
    public List<MovimientoInventarioDTO> buscarTodos() {
        return repoMovimientosInventario.findAll().stream().map(this::convertirDTO).toList();
    }

    @Override
    public void guardar(MovimientosInventario movimientoinventario) {
        repoMovimientosInventario.save(movimientoinventario);
    }

    @Override
    public MovimientoInventarioDTO convertirDTO(MovimientosInventario movimiento) {
        MovimientoInventarioDTO dto = new MovimientoInventarioDTO();
        dto.setIdMovimiento(movimiento.getId_movimiento_inventario());
        dto.setProducto(movimiento.getProducto().getNombre()); // o getDescripcion(), etc.
        dto.setTipoMovimiento(movimiento.getTipo_movimiento());
        dto.setCantidad(String.valueOf(movimiento.getCantidad()));
        dto.setFecha(movimiento.getFecha());

        return dto;
    }

    @Override
    public void modificar(MovimientosInventario movimientoinventario) {
        repoMovimientosInventario.save(movimientoinventario);
    }

    @Override
    public Optional<MovimientoInventarioDTO> buscarId(Integer id_movimiento_inventario) {
        return repoMovimientosInventario.findById(id_movimiento_inventario).map(movimiento -> convertirDTO(movimiento));
    }

    @Override
    public void eliminar(Integer id_movimiento_inventario) {
        repoMovimientosInventario.deleteById(id_movimiento_inventario);
    }
}
