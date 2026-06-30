package com.alexander.sistema_cerro_verde_backend.service.ventas.jpa;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alexander.sistema_cerro_verde_backend.entity.ventas.ComprobantePago;
import com.alexander.sistema_cerro_verde_backend.repository.ventas.ComprobantePagoRepository;
import com.alexander.sistema_cerro_verde_backend.service.ventas.IComprobantePagoService;

@Service
public class ComprobantePagoService implements IComprobantePagoService {

    @Autowired
    private ComprobantePagoRepository repoComprobante;

    @Override
    public List<ComprobantePago> buscarTodos() {
        return repoComprobante.findAll();
    }

    @Override
    public Optional<ComprobantePago> buscarPorId(Integer id) {
        return repoComprobante.findById(id);
    }

    @Override
    public void guardar(ComprobantePago comprobante) {
        repoComprobante.save(comprobante);
    }

    @Override
    public void modificar(ComprobantePago comprobante) {
        repoComprobante.save(comprobante);
    }

    @Override
    public void eliminar(Integer id) {
        repoComprobante.deleteById(id);
    }

    @Override
    public String generarSiguienteCorrelativo(String tipo) {
        ComprobantePago ultimo = null;
        String correlativo = null;
        int nuevoNumero = 1;

        if ("Boleta".equals(tipo)) {
            // Busca el último comprobante con numComprobante "B001"
            ultimo = repoComprobante.findTopByNumComprobanteOrderByIdVentaDesc("B001").orElse(null);
            if (ultimo != null && ultimo.getNumSerieBoleta() != null) {
                correlativo = ultimo.getNumSerieBoleta();
            }
        } else if ("Factura".equals(tipo)) {
            // Busca el último comprobante con numComprobante "F001"
            ultimo = repoComprobante.findTopByNumComprobanteOrderByIdVentaDesc("F001").orElse(null);
            if (ultimo != null && ultimo.getNumSerieFactura() != null) {
                correlativo = ultimo.getNumSerieFactura();
            }
        }

        if (correlativo != null) {
            try {
                nuevoNumero = Integer.parseInt(correlativo) + 1;
            } catch (NumberFormatException e) {
                throw new RuntimeException("Número inválido en el correlativo: " + correlativo);
            }
        }

        // Devuelve siempre 8 dígitos con ceros a la izquierda
        return String.format("%08d", nuevoNumero);
    }
}
