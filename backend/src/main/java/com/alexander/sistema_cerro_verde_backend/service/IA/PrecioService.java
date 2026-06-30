package com.alexander.sistema_cerro_verde_backend.service.IA;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import com.alexander.sistema_cerro_verde_backend.entity.IA.PrecioRequest;
import com.alexander.sistema_cerro_verde_backend.entity.IA.PrecioResponse;

public class PrecioService {
    
 public PrecioResponse predecirPrecio(String fecha) {
        String url = "http://127.0.0.1:5000/predecir_precio";

        RestTemplate restTemplate = new RestTemplate();

        PrecioRequest request = new PrecioRequest();
        request.setFecha(fecha);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<PrecioRequest> entity = new HttpEntity<>(request, headers);

        ResponseEntity<PrecioResponse> response = restTemplate.postForEntity(
            url, entity, PrecioResponse.class
        );

        return response.getBody();
    }
}