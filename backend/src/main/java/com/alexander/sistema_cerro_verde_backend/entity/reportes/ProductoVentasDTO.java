package com.alexander.sistema_cerro_verde_backend.entity.reportes;

import java.math.BigDecimal;
import java.math.BigInteger;

public interface ProductoVentasDTO {

  // alias “productoNombre” en SQL → getter getProductoNombre()
    String getProductoNombre();

    // alias “cantidadVendida” en SQL → getter getCantidadVendida()
    BigInteger getCantidadVendida();

    // alias “totalVendido” en SQL → getter getTotalVendido()
    BigDecimal getTotalVendido();
}
