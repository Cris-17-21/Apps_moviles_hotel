package com.alexander.sistema_cerro_verde_backend.service.ventas.jpa;

import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alexander.sistema_cerro_verde_backend.dto.ventas.VentaDTO;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TipoTransacciones;
import com.alexander.sistema_cerro_verde_backend.entity.caja.TransaccionesCaja;
import com.alexander.sistema_cerro_verde_backend.entity.compras.MovimientosInventario;
import com.alexander.sistema_cerro_verde_backend.entity.compras.Productos;
import com.alexander.sistema_cerro_verde_backend.entity.seguridad.Usuarios;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.ComprobantePago;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.DetalleVenta;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaHabitacion;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaMetodoPago;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.VentaSalon;
import com.alexander.sistema_cerro_verde_backend.entity.ventas.Ventas;
import com.alexander.sistema_cerro_verde_backend.repository.caja.CajasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.caja.TransaccionesCajaRepository;
import com.alexander.sistema_cerro_verde_backend.repository.compras.MovimientosInventarioRepository;
import com.alexander.sistema_cerro_verde_backend.repository.compras.ProductosRepository;
import com.alexander.sistema_cerro_verde_backend.repository.recepcion.ReservasRepository;
import com.alexander.sistema_cerro_verde_backend.repository.seguridad.UsuariosRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.DetalleVentaRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.MetodoPagoRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.VentaHabitacionRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.VentaMetodoPagoRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.VentaSalonRepository;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.VentasRepository;
import com.alexander.sistema_cerro_verde_backend.service.ventas.IVentaService;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;

import jakarta.persistence.EntityNotFoundException;

@Service
public class VentaService implements IVentaService {

    @Autowired
    private VentasRepository repoVenta;

    @Autowired
    private ProductosRepository repoProductos;

    @Autowired
    private ReservasRepository repoReservas;

    @Autowired
    private MovimientosInventarioRepository repoMovimientosInventario;

    @Autowired
    private MetodoPagoRepository repoMetodo;

    @Autowired
    private CajasRepository repoCaja;

    @Autowired
    private DetalleVentaRepository repoDetalle;

    @Autowired
    private VentaHabitacionRepository repoVentaHabitacion;

    @Autowired
    private VentaSalonRepository repoVentaSalon;

    @Autowired
    private VentaMetodoPagoRepository repoVentaMetodoPago;

    @Autowired
    private TransaccionesCajaRepository repoTransacciones;

    @Autowired
    private UsuariosRepository usuarioRepository;

    private Usuarios getUsuarioAutenticado() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        return usuarioRepository.findByUsername(username);
    }

    @Override
    public List<Ventas> buscarTodos() {
        return repoVenta.findAll();
    }

    @Override
    public Optional<Ventas> buscarPorId(Integer id) {
        return repoVenta.findById(id);
    }

    @Override
    public VentaDTO convertirDTO(Ventas venta) {
        VentaDTO dto = new VentaDTO();
        dto.setIdVenta(venta.getIdVenta());
        dto.setNumComprobante(venta.getComprobantePago().getNumComprobante());
        dto.setNumSerieBoleta(venta.getComprobantePago().getNumSerieBoleta());
        dto.setNumSerieFactura(venta.getComprobantePago().getNumSerieFactura());
        dto.setDniRucCliente(venta.getCliente().getDniRuc());
        dto.setCliente(venta.getCliente().getNombre());
        dto.setFecha(venta.getFecha());
        dto.setTotal(venta.getTotal());
        dto.setDescuento(venta.getDescuento());
        dto.setCargo(venta.getCargo());
        dto.setIgv(venta.getIgv());
        dto.setDetalleVenta(venta.getDetalleVenta());
        dto.setDetalleHabitacion(venta.getVentaHabitacion());
        dto.setDetalleSalon(venta.getVentaSalon());
        dto.setMetodosPago(venta.getVentaMetodoPago());
        dto.setEstadoVenta(venta.getEstadoVenta());

        return dto;
    }

    @Override
    @Transactional
    public void registrarPagoHospedaje(Ventas venta) {
        // 1. Configurar como venta de hospedaje
        venta.setTipoVenta("hospedaje");
        venta.setEstadoVenta("Completado");

        // 2. Guardar la venta
        Ventas ventaGuardada = repoVenta.save(venta);

        // 3. Actualizar estado de reserva a "Pagada"
        if (ventaGuardada.getVentaXReserva() != null && !ventaGuardada.getVentaXReserva().isEmpty()) {
            ventaGuardada.getVentaXReserva().forEach(r -> {
                Integer idReserva = r.getReserva().getId_reserva();
                var reserva = repoReservas.findById(idReserva)
                        .orElseThrow(() -> new EntityNotFoundException("Reserva no encontrada: " + idReserva));
                reserva.setEstado_reserva("Pagada");
                repoReservas.save(reserva);
            });
        }

        // 4. Registrar en caja
        if (ventaGuardada.getVentaMetodoPago() != null && !ventaGuardada.getVentaMetodoPago().isEmpty()) {
            var usuario = getUsuarioAutenticado();
            var caja = repoCaja.findByUsuarioAndEstadoCaja(usuario, "abierta")
                    .orElseThrow(() -> new RuntimeException("No hay caja abierta para el usuario"));

            for (VentaMetodoPago m : ventaGuardada.getVentaMetodoPago()) {
                Integer idMetodoPago = m.getMetodoPago().getIdMetodoPago();
                var metodoPago = repoMetodo.findById(idMetodoPago)
                        .orElseThrow(() -> new EntityNotFoundException("Método de Pago no encontrado: " + idMetodoPago));

                double monto = m.getPago();
                if (monto > 0) {
                    // Actualizar saldo total siempre
                    caja.setSaldoTotal(caja.getSaldoTotal() + monto);

                    // Solo si es efectivo: actualizar saldo físico y registrar transacción
                    if ("Efectivo".equalsIgnoreCase(metodoPago.getNombre())) {
                        caja.setSaldoFisico(caja.getSaldoFisico() + monto);

                        TransaccionesCaja transaccion = new TransaccionesCaja();
                        transaccion.setMontoTransaccion(monto);
                        transaccion.setFechaHoraTransaccion(new Date());
                        transaccion.setCaja(caja);
                        transaccion.setVenta(ventaGuardada);
                        transaccion.setMetodoPago(metodoPago);

                        TipoTransacciones tipoIngreso = new TipoTransacciones();
                        tipoIngreso.setId(1); // 1 = ingreso
                        transaccion.setTipo(tipoIngreso);

                        repoTransacciones.save(transaccion);
                    }

                    // Guardar caja (con saldo actualizado)
                    repoCaja.save(caja);
                }
            }
        }
    }

    @Override
    @Transactional
    public void registrarVentaProductos(Ventas venta) {
        // Configurar como venta de productos
        venta.setTipoVenta("productos");
        venta.setEstadoVenta("Pendiente"); // Inicia pendiente hasta confirmación

        // 1. Guardar la venta
        Ventas ventaGuardada = repoVenta.save(venta);

        // 2. Ajustar stock de productos
        if (ventaGuardada.getDetalleVenta() != null && !ventaGuardada.getDetalleVenta().isEmpty()) {
            ventaGuardada.getDetalleVenta().forEach(det -> {
                Integer prodId = det.getProducto().getId_producto();
                var producto = repoProductos.findById(prodId)
                        .orElseThrow(() -> new EntityNotFoundException("Producto no encontrado: " + prodId));

                int cantidadVendida = det.getCantidad();
                if (producto.getStock() < cantidadVendida) {
                    throw new RuntimeException("Stock insuficiente para el producto: " + producto.getNombre()
                            + ". Stock disponible: " + producto.getStock()
                            + ", cantidad solicitada: " + cantidadVendida);
                }

                MovimientosInventario movimiento = new MovimientosInventario();
                movimiento.setProducto(producto);
                movimiento.setTipo_movimiento("Salida");
                movimiento.setFecha(venta.getFecha());
                movimiento.setVenta(ventaGuardada);
                movimiento.setCantidad(cantidadVendida);
                repoMovimientosInventario.save(movimiento);

                producto.setStock(producto.getStock() - cantidadVendida);
                repoProductos.save(producto);
            });
        } else {
            throw new IllegalArgumentException("Una venta de productos debe tener al menos un producto");
        }

        // 3. NO registrar transacciones en caja (aún está pendiente)
        // Solo guardar los métodos de pago para tenerlos listos
    }

    @Override
    @Transactional
    public void editarVentaProductos(Ventas ventaModificada) {
        // 1. Obtener venta existente
        Ventas ventaExistente = repoVenta.findById(ventaModificada.getIdVenta())
                .orElseThrow(() -> new EntityNotFoundException("Venta no encontrada con ID: " + ventaModificada.getIdVenta()));

        // 2. Validaciones
        if (!"productos".equals(ventaExistente.getTipoVenta())) {
            throw new IllegalArgumentException("Solo se pueden editar ventas de productos");
        }

        if (!"Pendiente".equals(ventaExistente.getEstadoVenta())) {
            throw new IllegalArgumentException("Solo se pueden editar ventas pendientes. Estado actual: " + ventaExistente.getEstadoVenta());
        }

        // 3. Revertir stock de productos anteriores
        for (DetalleVenta detalle : ventaExistente.getDetalleVenta()) {
            Integer idProd = detalle.getProducto().getId_producto();
            Productos producto = repoProductos.findById(idProd)
                    .orElseThrow(() -> new EntityNotFoundException("Producto no encontrado: " + idProd));

            // Devolver stock
            producto.setStock(producto.getStock() + detalle.getCantidad());
            repoProductos.save(producto);

            // Crear movimiento de reversión
            MovimientosInventario movReversa = new MovimientosInventario();
            movReversa.setProducto(producto);
            movReversa.setTipo_movimiento("Entrada");
            movReversa.setFecha(ventaModificada.getFecha());
            movReversa.setVenta(ventaExistente);
            movReversa.setCantidad(detalle.getCantidad());
            repoMovimientosInventario.save(movReversa);
        }

        // 4. Eliminar detalles y métodos de pago antiguos
        ventaExistente.getDetalleVenta().clear();
        ventaExistente.getVentaMetodoPago().forEach(vmp -> repoVentaMetodoPago.delete(vmp));
        ventaExistente.getVentaMetodoPago().clear();
        repoVenta.save(ventaExistente);

        // 5. Agregar nuevos productos y ajustar stock
        for (DetalleVenta nuevoDetalle : ventaModificada.getDetalleVenta()) {
            Integer idProd = nuevoDetalle.getProducto().getId_producto();
            Productos producto = repoProductos.findById(idProd)
                    .orElseThrow(() -> new EntityNotFoundException("Producto no encontrado: " + idProd));

            int cantidadVendida = nuevoDetalle.getCantidad();
            if (producto.getStock() < cantidadVendida) {
                throw new RuntimeException("Stock insuficiente para el producto: " + producto.getNombre()
                        + ". Stock disponible: " + producto.getStock()
                        + ", cantidad solicitada: " + cantidadVendida);
            }

            // Ajustar stock
            producto.setStock(producto.getStock() - cantidadVendida);
            repoProductos.save(producto);

            // Crear movimiento
            MovimientosInventario mov = new MovimientosInventario();
            mov.setProducto(producto);
            mov.setTipo_movimiento("Salida");
            mov.setCantidad(cantidadVendida);
            mov.setFecha(ventaModificada.getFecha());
            mov.setVenta(ventaExistente);
            repoMovimientosInventario.save(mov);

            // Agregar detalle a la venta
            nuevoDetalle.setVenta(ventaExistente);
            ventaExistente.getDetalleVenta().add(nuevoDetalle);
        }

        // 6. Agregar nuevos métodos de pago (sin registrar en caja aún)
        for (VentaMetodoPago metodo : ventaModificada.getVentaMetodoPago()) {
            VentaMetodoPago nuevoMetodo = new VentaMetodoPago();
            nuevoMetodo.setPago(metodo.getPago());
            nuevoMetodo.setMetodoPago(metodo.getMetodoPago());
            nuevoMetodo.setVenta(ventaExistente);
            ventaExistente.getVentaMetodoPago().add(nuevoMetodo);
        }

        // 7. Actualizar campos generales
        ventaExistente.setFecha(ventaModificada.getFecha());
        ventaExistente.setTotal(ventaModificada.getTotal());
        ventaExistente.setDescuento(ventaModificada.getDescuento());
        ventaExistente.setCargo(ventaModificada.getCargo());
        ventaExistente.setIgv(ventaModificada.getIgv());
        ventaExistente.setCliente(ventaModificada.getCliente());

        // 8. Guardar cambios (NO registrar en caja aún)
        repoVenta.save(ventaExistente);
    }

    @Override
    @Transactional
    public void confirmarVentaProductos(Integer ventaId, String tipoComprobante) {
        // 1. Obtener venta pendiente
        Ventas venta = repoVenta.findById(ventaId)
                .orElseThrow(() -> new EntityNotFoundException("Venta no encontrada con ID: " + ventaId));

        // 2. Validaciones
        if (!"productos".equals(venta.getTipoVenta())) {
            throw new IllegalArgumentException("Solo se pueden confirmar ventas de productos");
        }

        if (!"Pendiente".equals(venta.getEstadoVenta())) {
            throw new IllegalArgumentException("Solo se pueden confirmar ventas pendientes. Estado actual: " + venta.getEstadoVenta());
        }

        if (!"Boleta".equals(tipoComprobante) && !"Factura".equals(tipoComprobante)) {
            throw new IllegalArgumentException("Tipo de comprobante debe ser 'Boleta' o 'Factura'");
        }

        // 3. Cambiar estado a completada
        venta.setEstadoVenta("Completado");
        venta.setFecha(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        // 4. Registrar transacciones en caja (SOLO PARA EFECTIVO)
        if (venta.getVentaMetodoPago() != null && !venta.getVentaMetodoPago().isEmpty()) {
            var usuario = getUsuarioAutenticado();
            var caja = repoCaja.findByUsuarioAndEstadoCaja(usuario, "abierta")
                    .orElseThrow(() -> new RuntimeException("No hay caja abierta para el usuario"));

            for (VentaMetodoPago m : venta.getVentaMetodoPago()) {
                Integer idMetodoPago = m.getMetodoPago().getIdMetodoPago();
                var metodoPago = repoMetodo.findById(idMetodoPago)
                        .orElseThrow(() -> new EntityNotFoundException("Método de Pago no encontrado: " + idMetodoPago));

                double monto = m.getPago();
                if (monto > 0) {
                    // SIEMPRE sumar al saldo total
                    caja.setSaldoTotal(caja.getSaldoTotal() + monto);

                    // SOLO para efectivo: sumar al saldo físico Y crear transacción
                    if ("Efectivo".equalsIgnoreCase(metodoPago.getNombre())) {
                        caja.setSaldoFisico(caja.getSaldoFisico() + monto);

                        // Crear transacción SOLO para efectivo
                        TransaccionesCaja transaccion = new TransaccionesCaja();
                        transaccion.setMontoTransaccion(monto);
                        transaccion.setFechaHoraTransaccion(new Date());
                        transaccion.setCaja(caja);
                        transaccion.setVenta(venta);
                        transaccion.setMetodoPago(metodoPago);

                        TipoTransacciones tipoIngreso = new TipoTransacciones();
                        tipoIngreso.setId(1); // 1 = ingreso
                        transaccion.setTipo(tipoIngreso);

                        repoTransacciones.save(transaccion);
                    }
                }
            }

            // Guardar caja una sola vez al final
            repoCaja.save(caja);
        }

        // 5. Crear comprobante básico (sin correlativo aún)
        if (venta.getComprobantePago() == null) {
            ComprobantePago comprobante = new ComprobantePago();
            comprobante.setIdVenta(venta.getIdVenta());
            comprobante.setFechaEmision(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

            // Configurar según tipo de comprobante
            if ("Boleta".equals(tipoComprobante)) {
                comprobante.setNumComprobante("B001");
                // numSerieBoleta se llenará cuando se genere el PDF/XML real
            } else { // Factura
                comprobante.setNumComprobante("F001");
                // numSerieFactura se llenará cuando se genere el PDF/XML real
            }

            venta.setComprobantePago(comprobante);
        } else {
            // Si ya existe, solo actualizar la fecha y tipo
            venta.getComprobantePago().setFechaEmision(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

            if ("Boleta".equals(tipoComprobante)) {
                venta.getComprobantePago().setNumComprobante("B001");
                venta.getComprobantePago().setNumSerieFactura(null); // Limpiar factura si había
            } else {
                venta.getComprobantePago().setNumComprobante("F001");
                venta.getComprobantePago().setNumSerieBoleta(null); // Limpiar boleta si había
            }
        }

        // 6. Guardar cambios
        repoVenta.save(venta);

        // 7. El numSerieBoleta/numSerieFactura y pdfUrl se llenarán 
        // cuando se genere el comprobante físico/XML posteriormente
    }

    @Override
    public void eliminar(Integer id) {
        repoVenta.deleteById(id);
    }

    @Override
    public String generarComprobante(Integer id) {
        String correlativo;
        String tipo;

        Ventas venta = repoVenta.findById(id).orElseThrow();

        if (venta.getComprobantePago().getNumComprobante().equals("B001")) {
            correlativo = venta.getComprobantePago().getNumSerieBoleta();
            tipo = "BOLETA";
        } else {
            correlativo = venta.getComprobantePago().getNumSerieFactura();
            tipo = "FACTURA";
        }

        StringBuilder filas = new StringBuilder();

        // Obtener detalles
        List<DetalleVenta> productos = repoDetalle.findByVenta_IdVenta(id);
        List<VentaHabitacion> habitaciones = repoVentaHabitacion.findByVenta_IdVenta(id);
        List<VentaSalon> salones = repoVentaSalon.findByVenta_IdVenta(id);

        //Subtotal
        Double subTotal = 0.0;
        Double igv = 0.0;

        // Agregamos productos
        for (DetalleVenta d : productos) {
            subTotal = subTotal + d.getSubTotal();
            filas.append("<tr>")
                    .append("<td style='text-align: center;'>").append(d.getCantidad()).append("</td>")
                    .append("<td>").append(d.getProducto().getNombre()).append("</td>")
                    .append("<td style='text-align: right;'>").append(String.format("%.2f", d.getProducto().getPrecioVenta())).append("</td>")
                    .append("<td style='text-align: right;'>").append(String.format("%.2f", d.getSubTotal())).append("</td>")
                    .append("</tr>");
        }

        // Agregamos habitaciones
        for (VentaHabitacion h : habitaciones) {
            subTotal = subTotal + h.getSubTotal();
            String descripcion = h.getHabitacion().getNumero()
                    + " Piso " + h.getHabitacion().getPiso().getNumero()
                    + " " + h.getHabitacion().getTipo_habitacion().getNombre()
                    + " X " + h.getDias() + " días";
            filas.append("<tr>")
                    .append("<td style='text-align: center;'>1</td>")
                    .append("<td>").append(descripcion).append("</td>")
                    .append("<td style='text-align: right;'>").append(String.format("%.2f", h.getHabitacion().getTipo_habitacion().getPrecio())).append("</td>")
                    .append("<td style='text-align: right;'>").append(String.format("%.2f", h.getSubTotal())).append("</td>")
                    .append("</tr>");
        }

        // Agregamos salones
        for (VentaSalon s : salones) {
            subTotal = subTotal + s.getSubTotal();
            String descripcion = s.getSalon().getNombre() + " X " + s.getDias() + " días";
            filas.append("<tr>")
                    .append("<td style='text-align: center;'>1</td>")
                    .append("<td>").append(descripcion).append("</td>")
                    .append("<td style='text-align: right;'>").append(String.format("%.2f", s.getSalon().getPrecio_diario())).append("</td>")
                    .append("<td style='text-align: right;'>").append(String.format("%.2f", s.getSubTotal())).append("</td>")
                    .append("</tr>");
        }

        igv = subTotal * (venta.getIgv() / 100);
        String html = """
                <!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8"/>
    <style>
        @page {
            size: 58mm 200mm;
            margin: 3mm;
        }

        body {
            font-family: Arial, sans-serif;
            font-size: 9px;
            margin: 0;
            padding: 0;
            line-height: 1.2;
        }

        .centrado {
            text-align: center;
            margin-bottom: 8px;
        }

        .linea {
            border-top: 1px dashed #000;
            margin: 6px 0;
        }

        .separador {
            text-align: center;
            margin: 5px 0;
            font-size: 8px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 5px;
        }

        th {
            font-size: 8px;
            font-weight: bold;
            padding: 3px 2px;
            border-bottom: 1px dashed #000;
            text-align: left;
        }

        td {
            padding: 2px;
            font-size: 8px;
            vertical-align: top;
        }

        .total {
            font-weight: bold;
            font-size: 10px;
            border-top: 1px dashed #000;
            padding-top: 3px;
        }

        .empresa-nombre {
            font-weight: bold;
            font-size: 11px;
            margin: 3px 0;
        }

        .ruc {
            font-size: 9px;
            margin: 2px 0;
        }

        .direccion {
            font-size: 8px;
            margin: 2px 0;
        }

        .tipo-comprobante {
            font-weight: bold;
            font-size: 10px;
            margin: 5px 0;
        }

        .numero-comprobante {
            font-size: 9px;
            margin: 3px 0;
        }

        .fecha {
            font-size: 8px;
            margin: 3px 0;
        }

        .cliente-info {
            margin: 8px 0;
            font-size: 8px;
        }

        .cliente-info p {
            margin: 2px 0;
        }

        .logo {
            margin-bottom: 8px;
        }

        .agradecimiento {
            margin-top: 8px;
            font-size: 8px;
        }
    </style>
</head>

<body>
    <div class="centrado">
        <img src="file:src/main/resources/static/img/logo-cerroverde2.png" width="100" alt="Logo"/><br/>
        <strong>CERRO VERDE TARAPOTO HOTEL S.A.C.</strong><br/>
        RUC: 20531481233<br/>
        Jr. Augusto B. Leguia Nro. 596<br/>
        ---------------------------------<br/>
        <strong>"""
                + tipo
                + """
        </strong><br/>
        """
                + venta.getComprobantePago().getNumComprobante()
                + """ 
         - 
         """
                + correlativo
                + """
         <br/>
        Fecha: """
                + venta.getFecha()
                + """
    </div>

    <div>
        <p style="margin: 0;">DNI/RUC: """ + venta.getCliente().getDniRuc()
                + """
         </p>
        <p style="margin: 0;">Cliente: """ + venta.getCliente().getNombre()
                + """ 
        </p>
    </div>

    <div class="linea"></div>

    <table>
        <thead>
            <th>Cant.</th>
            <th>Descrip.</th>
            <th>Precio U.</th>
            <th>Valor.</th>
        </thead>
        <tbody>
            """
                + filas.toString()
                + """
        </tbody>

    </table>

    <div class="linea"></div>

    <table>
        <tr>
            <td>Subtotal</td>
            <td style="text-align: right;">S/. """
                + subTotal.toString()
                + """
            </td>
        </tr>
        <tr>
            <td>Descuento</td>
            <td style="text-align: right;">S/. """
                + venta.getDescuento()
                + """
            </td>
        </tr>
        <tr>
            <td>IGV (18%)</td>
            <td style="text-align: right;">S/. """
                + igv.toString()
                + """
             </td>
        </tr>
        <tr>
            <td>Cargo</td>
            <td style="text-align: right;">S/. """
                + venta.getCargo()
                + """
            </td>
        </tr>
        <tr class="total">
            <td>Total</td>
            <td style="text-align: right;">S/. """
                + venta.getTotal()
                + """
            </td>
        </tr>
    </table>

    <div class="centrado">
        <div class="linea"></div>
        ¡Gracias por su compra!
    </div>
</body>

</html>
                """;
        return html;
    }

    @Override
    public byte[] generarPdf(Integer id) {
        String html = generarComprobante(id); // Este método debe generar el HTML como string

        try (ByteArrayOutputStream os = new ByteArrayOutputStream()) {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.withHtmlContent(html, null);
            builder.useFastMode();
            builder.toStream(os);
            builder.run();
            return os.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Error al generar PDF", e);
        }
    }
}
