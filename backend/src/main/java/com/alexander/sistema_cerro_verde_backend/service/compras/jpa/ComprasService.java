package com.alexander.sistema_cerro_verde_backend.service.compras.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.compras.Compras;
import com.alexander.sistema_cerro_verde_backend.entity.compras.DetallesCompra;
import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;
import com.alexander.sistema_cerro_verde_backend.entity.compras.Productos;
import com.alexander.sistema_cerro_verde_backend.repository.compras.ComprasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.compras.DetallesCompraRepository;
import com.alexander.sistema_cerro_verde_backend.repository.compras.MovimientosInventarioRepository;
import com.alexander.sistema_cerro_verde_backend.repository.compras.ProductosRepository;
import com.alexander.sistema_cerro_verde_backend.service.compras.IComprasService;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

@Service
public class ComprasService implements IComprasService {

    @Autowired
    private ComprasRepository repoCompras;

    @Autowired
    private ProductosRepository repoProductos;

    @Autowired
    private DetallesCompraRepository repoDetalle;

    @Autowired
    private MovimientosInventarioRepository repoMovimientosInventario;

    @Override
    public List<Compras> buscarTodos() {
        return repoCompras.findAll();
    }

    @Override
    public void guardar(Compras compra) {
        System.out.println("DETALLES: " + compra.getDetallecompra());
        Compras compraGuardada = repoCompras.save(compra);
        // 2) Recorres cada detalle y ajustas el stock
        compraGuardada.getDetallecompra().forEach(det -> {
            Integer prodId = det.getProducto().getId_producto();
            var producto = repoProductos.findById(prodId)
                    .orElseThrow(() -> new EntityNotFoundException("Producto no existe: " + prodId));
            MovimientosInventario movimiento = new MovimientosInventario();
            movimiento.setProducto(producto);
            movimiento.setTipo_movimiento("Entrada");
            movimiento.setFecha(compra.getFecha_compra());
            movimiento.setCompra(compraGuardada);

            repoMovimientosInventario.save(movimiento);

            // si tu unidad tiene equivalencia:
            int equi = producto.getUnidad().getEquivalencia();
            int incremento = (int) (det.getCantidad() * equi);
            movimiento.setCantidad(incremento);

            producto.setStock(producto.getStock() + incremento);
            repoProductos.save(producto);
        });
    }

    @Override
    @Transactional
    public void modificar(Compras compra) {
        // 1) Carga la compra existente con sus detalles
        Compras antigua = repoCompras.findById(compra.getId_compra())
                .orElseThrow(() -> new EntityNotFoundException("Compra no encontrada"));

        // 2) Revertir en el stock el impacto de los detalles antiguos
        for (DetallesCompra det : antigua.getDetallecompra()) {
            Productos prod = repoProductos.findById(det.getProducto().getId_producto())
                    .orElseThrow(() -> new EntityNotFoundException("Producto no existe"));
            int unidades = (int) (det.getCantidad() * prod.getUnidad().getEquivalencia());
            prod.setStock(prod.getStock() - unidades);
            repoProductos.save(prod);
        }

        // 3) Borra todos los DetalleCompra antiguos (queda por cascade o explícito)
        repoDetalle.eliminarPorIdCompra(antigua.getId_compra());
        repoCompras.save(compra);

        // 4) Ahora guarda la nueva compra + detalles (aprovechando cascade)
        Compras guardada = repoCompras.save(compra);

        // 5) Aplica en stock el impacto de los nuevos detalles
        for (DetallesCompra det : guardada.getDetallecompra()) {
            Productos prod = repoProductos.findById(det.getProducto().getId_producto())
                    .orElseThrow(() -> new EntityNotFoundException("Producto no existe"));
            int unidades = (int) (det.getCantidad() * prod.getUnidad().getEquivalencia());
            prod.setStock(prod.getStock() + unidades);
            repoProductos.save(prod);
        }
    }

    @Override
    public Optional<Compras> buscarId(Integer id_compra) {
        return repoCompras.findById(id_compra);
    }

    @Override
    public void eliminar(Integer id_compra) {
        repoCompras.deleteById(id_compra);
    }

    @Override
    public String obtenerProximoCorrelativo() {
        String ultimoCorrelativo = repoCompras.obtenerUltimaCompra()
                .map(Compras::getCorrelativo)
                .orElse("00000000");  // Si no hay registros

        // Convertir a número, sumar 1
        int correlativoNumero = Integer.parseInt(ultimoCorrelativo);
        correlativoNumero++;

        // Formatear a 8 dígitos con ceros a la izquierda
        return String.format("%08d", correlativoNumero);
    }
}
