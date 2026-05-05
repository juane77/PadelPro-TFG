package com.tfg.padelpro.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tfg.padelpro.entity.Pista;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.entity.Valoracion;
import com.tfg.padelpro.repository.PistaRepository;
import com.tfg.padelpro.repository.UsuarioRepository;
import com.tfg.padelpro.repository.ValoracionRepository;

@RestController
@RequestMapping("/api/valoraciones")
public class ValoracionController {

    private final ValoracionRepository valoracionRepository;
    private final UsuarioRepository usuarioRepository;
    private final PistaRepository pistaRepository;

    public ValoracionController(ValoracionRepository valoracionRepository,
                                UsuarioRepository usuarioRepository,
                                PistaRepository pistaRepository) {
        this.valoracionRepository = valoracionRepository;
        this.usuarioRepository = usuarioRepository;
        this.pistaRepository = pistaRepository;
    }

    // VALORAR O ACTUALIZAR VALORACIÓN DE UNA PISTA
    @PostMapping
    public ResponseEntity<?> valorar(@RequestBody Map<String, Object> body) {
        Long usuarioId = Long.valueOf(body.get("usuarioId").toString());
        Long pistaId = Long.valueOf(body.get("pistaId").toString());
        Double puntuacion = Double.valueOf(body.get("puntuacion").toString());

        if (puntuacion < 1.0 || puntuacion > 5.0) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "La puntuación debe estar entre 1 y 5"));
        }

        Usuario usuario = usuarioRepository.findById(usuarioId).orElse(null);
        Pista pista = pistaRepository.findById(pistaId).orElse(null);

        if (usuario == null || pista == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", "Usuario o pista no encontrada"));
        }

        Optional<Valoracion> existente = valoracionRepository.findByUsuarioIdAndPistaId(usuarioId, pistaId);

        Valoracion valoracion;
        if (existente.isPresent()) {
            valoracion = existente.get();
            valoracion.setPuntuacion(puntuacion);
        } else {
            valoracion = new Valoracion(usuario, pista, puntuacion);
        }

        valoracionRepository.save(valoracion);

        Double media = valoracionRepository.getMediaByPistaId(pistaId);
        long total = valoracionRepository.countByPistaId(pistaId);

        return ResponseEntity.ok(Map.of(
            "mensaje", "Valoración guardada",
            "media", media != null ? Math.round(media * 10.0) / 10.0 : 0.0,
            "total", total,
            "miValoracion", puntuacion
        ));
    }

    // OBTENER MEDIA Y VALORACIÓN DEL USUARIO PARA UNA PISTA
    @GetMapping("/pista/{pistaId}/usuario/{usuarioId}")
    public ResponseEntity<?> getValoracion(@PathVariable Long pistaId, @PathVariable Long usuarioId) {
        Double media = valoracionRepository.getMediaByPistaId(pistaId);
        long total = valoracionRepository.countByPistaId(pistaId);
        Optional<Valoracion> miValoracion = valoracionRepository.findByUsuarioIdAndPistaId(usuarioId, pistaId);

        return ResponseEntity.ok(Map.of(
            "media", media != null ? Math.round(media * 10.0) / 10.0 : 4.0,
            "total", total,
            "miValoracion", miValoracion.map(Valoracion::getPuntuacion).orElse(0.0)
        ));
    }

    // OBTENER SOLO LA MEDIA DE UNA PISTA (público)
    @GetMapping("/pista/{pistaId}")
    public ResponseEntity<?> getMedia(@PathVariable Long pistaId) {
        Double media = valoracionRepository.getMediaByPistaId(pistaId);
        long total = valoracionRepository.countByPistaId(pistaId);
        return ResponseEntity.ok(Map.of(
            "media", media != null ? Math.round(media * 10.0) / 10.0 : 4.0,
            "total", total
        ));
    }
}