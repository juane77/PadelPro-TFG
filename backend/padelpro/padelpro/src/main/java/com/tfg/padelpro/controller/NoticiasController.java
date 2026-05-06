package com.tfg.padelpro.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/api/noticias")
public class NoticiasController {

    private static final String API_KEY = "fa4f3a36c32c857fe26640fa9de56f77";
    private static final String URL = "https://gnews.io/api/v4/search?q=padel&lang=es&max=20&sortby=publishedAt&apikey=" + API_KEY;

    @GetMapping
    public ResponseEntity<?> getNoticias() {
        try {
            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.getForObject(URL, String.class);
            return ResponseEntity.ok()
                    .header("Content-Type", "application/json")
                    .body(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("{\"error\":\"No se pudieron cargar las noticias\"}");
        }
    }
}