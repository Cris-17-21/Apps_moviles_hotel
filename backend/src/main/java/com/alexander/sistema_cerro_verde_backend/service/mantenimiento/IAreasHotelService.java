package com.alexander.sistema_cerro_verde_backend.service.mantenimiento;

import java.util.List;
import java.util.Optional;

import com.alexander.sistema_cerro_verde_backend.entity.mantenimiento.AreasHotel;



public interface IAreasHotelService {

    List<AreasHotel> buscarTodos();
    Optional<AreasHotel> buscarPorId(Integer id);
    void registrar(AreasHotel areashotel);
    void actualizar(Integer id, AreasHotel areashotel);
    void eliminarPorId(Integer id);

}