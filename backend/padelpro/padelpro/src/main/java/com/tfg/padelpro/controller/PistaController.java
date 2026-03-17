package com.tfg.padelpro.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tfg.padelpro.entity.Pista;
import com.tfg.padelpro.repository.PistaRepository;

@RestController
@RequestMapping("/api/pistas")
public class PistaController {

    private final PistaRepository pistaRepository;

    public PistaController(PistaRepository pistaRepository) {
        this.pistaRepository = pistaRepository;
    }

    @GetMapping
    public ResponseEntity<?> buscarPistas(
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) String ciudad,
            @RequestParam(required = false) Double precioMax
    ) {

        List<Pista> pistas = pistaRepository.buscarConFiltros(tipo, ciudad, precioMax);

        return ResponseEntity.ok(pistas);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerPorId(@PathVariable Long id) {
        return pistaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
