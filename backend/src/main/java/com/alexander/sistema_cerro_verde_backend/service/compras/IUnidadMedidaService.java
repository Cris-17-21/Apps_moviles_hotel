package com.alexander.sistema_cerro_verde_backend.service.compras;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.compras.UnidadMedida;

public interface IUnidadMedidaService {
    List<UnidadMedida> buscarTodos(); //Listar todas las unidades de medida

    void guardar(UnidadMedida unidad); //Guardar unidad de medida

    void modificar(UnidadMedida unidad); //Modificar unidad de medida

    Optional<UnidadMedida> buscarId(Integer id); //Buscar una unidad de medida por Id

    void eliminar(Integer id); //Eliminar unidad de medida
}
