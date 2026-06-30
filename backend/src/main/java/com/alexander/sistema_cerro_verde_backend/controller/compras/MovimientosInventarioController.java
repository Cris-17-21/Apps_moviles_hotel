package com.alexander.sistema_cerro_verde_backend.controller.compras;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.alexander.sistema_cerro_verde_backend.dto.compras.MovimientoInventarioDTO;
import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;
import com.alexander.sistema_cerro_verde_backend.service.compras.IMovimientosInventarioService;

@RestController
@RequestMapping("/cerro-verde")
@CrossOrigin("*")
public class MovimientosInventarioController {
    @Autowired
    private IMovimientosInventarioService serviceMovimientosInventario;

    @GetMapping("/movimientosinventario")
    public List<MovimientoInventarioDTO> buscarTodos() {
        return serviceMovimientosInventario.buscarTodos(); //findAll
    }
    @PostMapping("/movimientosinventario")
    public MovimientosInventario guardar(@RequestBody MovimientosInventario movimientoinventario) {
        serviceMovimientosInventario.guardar(movimientoinventario);
        return movimientoinventario;
    }
    @PutMapping("/movimientosinventario")
    public MovimientosInventario modificar(@RequestBody MovimientosInventario movimientoinventario) {
        serviceMovimientosInventario.modificar(movimientoinventario);
        return movimientoinventario;
    }
    @GetMapping("/movimientosinventario/{id}")
    public Optional<MovimientoInventarioDTO> buscarId(@PathVariable("id") Integer id_movimiento_inventario) {
        return serviceMovimientosInventario.buscarId(id_movimiento_inventario);
    }
    @DeleteMapping("/movimientosinventario/{id}")
    public String eliminar(@PathVariable("id") Integer id_movimiento_inventario){
        serviceMovimientosInventario.eliminar(id_movimiento_inventario);
        return "Movimiento inventario eliminado";
    }
}