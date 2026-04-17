package com.tfg.padelpro.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tfg.padelpro.dto.request.PartidoRequestDTO;
import com.tfg.padelpro.entity.Partido;
import com.tfg.padelpro.entity.Pista;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.PartidoRepository;
import com.tfg.padelpro.repository.PistaRepository;
import com.tfg.padelpro.repository.UsuarioRepository;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/partidos")
public class PartidoController {

    private final PartidoRepository partidoRepository;
    private final UsuarioRepository usuarioRepository;
    private final PistaRepository pistaRepository;

    public PartidoController(PartidoRepository partidoRepository,
                             UsuarioRepository usuarioRepository,
                             PistaRepository pistaRepository) {
        this.partidoRepository = partidoRepository;
        this.usuarioRepository = usuarioRepository;
        this.pistaRepository = pistaRepository;
    }

    // 🔵 REGISTRAR PARTIDO
    @PostMapping
    public ResponseEntity<?> registrarPartido(@Valid @RequestBody PartidoRequestDTO dto) {

        Usuario usuario = usuarioRepository.findById(dto.usuarioId()).orElse(null);

        if (usuario == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("mensaje", "Usuario no encontrado"));
        }

        Pista pista = pistaRepository.findById(dto.pistaId()).orElse(null);

        if (pista == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("mensaje", "Pista no encontrada"));
        }

        Partido partido = new Partido(
                usuario,
                pista,
                dto.resultado(),
                dto.nivelMedio(),
                dto.resultadoFinal(),
                dto.fechaPartido()
        );

        Partido guardado = partidoRepository.save(partido);

        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "id", guardado.getId(),
                "resultado", guardado.getResultado(),
                "nivelMedio", guardado.getNivelMedio(),
                "resultadoFinal", guardado.getResultado_final(),
                "fechaPartido", guardado.getFechaPartido(),
                "pista", guardado.getPista().getNombre(),
                "club", guardado.getPista().getClub().getNombre()
        ));
    }

    // 🔵 PARTIDOS DEL USUARIO
    @GetMapping("/usuario/{id}")
    public ResponseEntity<?> getPartidosUsuario(@PathVariable Long id) {

        List<Partido> partidos = partidoRepository.findByUsuarioIdOrderByFechaPartidoDesc(id);

        List<Map<String, Object>> respuesta = partidos.stream().map(p -> Map.<String, Object>of(
                "id", p.getId(),
                "resultado", p.getResultado(),
                "nivelMedio", p.getNivelMedio(),
                "resultadoFinal", p.getResultado_final(),
                "fechaPartido", p.getFechaPartido(),
                "pista", p.getPista().getNombre(),
                "club", p.getPista().getClub().getNombre()
        )).toList();

        return ResponseEntity.ok(respuesta);
    }
}
