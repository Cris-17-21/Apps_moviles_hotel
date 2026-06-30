package com.alexander.sistema_cerro_verde_backend.service.compras;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.dto.compras.MovimientoInventarioDTO;
import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;

public interface IMovimientosInventarioService {
    List<MovimientoInventarioDTO> buscarTodos();

    void guardar(MovimientosInventario movimientoinventario);

    MovimientoInventarioDTO convertirDTO(MovimientosInventario movimiento);

    void modificar(MovimientosInventario movimientoinventario);

    Optional<MovimientoInventarioDTO> buscarId(Integer id_movimiento_inventario);

    void eliminar(Integer id_movimiento_inventario);
}