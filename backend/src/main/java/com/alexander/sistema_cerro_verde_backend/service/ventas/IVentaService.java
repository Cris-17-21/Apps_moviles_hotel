package com.alexander.sistema_cerro_verde_backend.service.ventas;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.alexander.sistema_cerro_verde_backend.dto.ventas.VentaDTO;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;

public interface IVentaService {

    Page<Ventas> buscarTodos (Pageable pageable); //Listar todas las ventas con paginación
    
    Optional<Ventas> buscarPorId (Integer id); //Buscar venta por ID

    VentaDTO convertirDTO(Ventas venta);

    void registrarPagoHospedaje (Ventas venta); //Guardar venta de hospedaje

    void registrarVentaProductos (Ventas venta); //Guardar venta de productos

    void editarVentaProductos(Ventas venta); //Editar venta de productos

    void confirmarVentaProductos (Integer id, String tipoComprobante); //Confirmar venta de productos

    void eliminar (Integer id); //Eliminar venta

    String generarComprobante(Integer id); //Generar comprobante

    byte[] generarPdf(Integer id);
}
