package com.alexander.sistema_cerro_verde_backend.service.compras;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Mono;

@Service
public class ApiService {
    WebClient web = WebClient.create();
    private final String TOKEN = "apis-token-16217.AT5XTgs7ZegVsB2bbdc1WtrGpJ6RMa3w";

    public ApiService(WebClient.Builder webClientBuilder) {
        this.web = webClientBuilder
            .baseUrl("https://cerro-verde.apis.net.pe/v2")
            .build();
    }

    public String consumirApi(String ruc) {
        Mono<String> respuesta = web.get()
            .uri(uriBuilder -> uriBuilder
                .path("/sunat/ruc/full")
                .queryParam("numero", ruc)
                .build()
            )
            .header("Authorization", "Bearer " + TOKEN) // Agrega el token en header
            .retrieve()
            .bodyToMono(String.class);
        return respuesta.block(); // bloquea hasta que obtenga respuesta
    }
}
