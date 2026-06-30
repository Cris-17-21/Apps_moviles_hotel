package com.alexander.sistema_cerro_verde_backend.service.ventas;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Mono;

@Service
public class ApiCliente {
    WebClient web = WebClient.create();
    private final String TOKEN = "apis-token-16217.AT5XTgs7ZegVsB2bbdc1WtrGpJ6RMa3w";

    public ApiCliente(WebClient.Builder webClientBuilder) {
        this.web = webClientBuilder
            .baseUrl("https://api.apis.net.pe/v2")
            .build();
    }

    public String consumirApi(String numero) {
        String tipo = numero.length() == 8 ? "reniec/dni" : "sunat/ruc";
    
        Mono<String> respuesta = web.get()
            .uri(uriBuilder -> uriBuilder
                .path("/" + tipo)
                .queryParam("numero", numero)
                .build()
            )
            .header("Authorization", "Bearer " + TOKEN)
            .retrieve()
            .bodyToMono(String.class);
    
        return respuesta.block();
    }
    
    
}
