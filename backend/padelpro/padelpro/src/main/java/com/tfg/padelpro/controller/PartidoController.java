package com.tfg.padelpro.controller;

import java.util.HashMap;
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
import com.tfg.padelpro.entity.Reserva;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.PartidoRepository;
import com.tfg.padelpro.repository.PistaRepository;
import com.tfg.padelpro.repository.ReservaRepository;
import com.tfg.padelpro.repository.UsuarioRepository;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/partidos")
public class PartidoController {

    private final PartidoRepository partidoRepository;
    private final UsuarioRepository usuarioRepository;
    private final PistaRepository pistaRepository;
    private final ReservaRepository reservaRepository;

    public PartidoController(PartidoRepository partidoRepository,
                             UsuarioRepository usuarioRepository,
                             PistaRepository pistaRepository,
                             ReservaRepository reservaRepository) {
        this.partidoRepository = partidoRepository;
        this.usuarioRepository = usuarioRepository;
        this.pistaRepository = pistaRepository;
        this.reservaRepository = reservaRepository;
    }

    // REGISTRAR PARTIDO
    @PostMapping
    public ResponseEntity<?> registrarPartido(@Valid @RequestBody PartidoRequestDTO dto) {

        Usuario usuario = usuarioRepository.findById(dto.usuarioId()).orElse(null);
        if (usuario == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", "Usuario no encontrado"));

        Pista pista = pistaRepository.findById(dto.pistaId()).orElse(null);
        if (pista == null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", "Pista no encontrada"));

        // Reserva opcional
        Reserva reserva = null;
        if (dto.reservaId() != null) {
            reserva = reservaRepository.findById(dto.reservaId()).orElse(null);
        }

        Partido partido = new Partido(
                usuario, pista, reserva,
                dto.resultado(), dto.nivelMedio(), dto.resultadoFinal(),
                dto.fechaPartido(), dto.amigosIds()
        );

        Partido guardado = partidoRepository.save(partido);

        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("id", guardado.getId());
        respuesta.put("resultado", guardado.getResultado());
        respuesta.put("nivelMedio", guardado.getNivelMedio());
        respuesta.put("resultadoFinal", guardado.getResultado_final());
        respuesta.put("fechaPartido", guardado.getFechaPartido());
        respuesta.put("pista", guardado.getPista().getNombre());
        respuesta.put("club", guardado.getPista().getClub().getNombre());
        respuesta.put("reservaVinculada", guardado.getReserva() != null);
        respuesta.put("amigosIds", guardado.getAmigosIds() != null ? guardado.getAmigosIds() : "");

        return ResponseEntity.status(HttpStatus.CREATED).body(respuesta);
    }

    // PARTIDOS DEL USUARIO
    @GetMapping("/usuario/{id}")
    public ResponseEntity<?> getPartidosUsuario(@PathVariable Long id) {

        List<Partido> partidos = partidoRepository.findByUsuarioIdOrderByFechaPartidoDesc(id);

        List<Map<String, Object>> respuesta = partidos.stream().map(p -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", p.getId());
            map.put("resultado", p.getResultado());
            map.put("nivelMedio", p.getNivelMedio());
            map.put("resultadoFinal", p.getResultado_final());
            map.put("fechaPartido", p.getFechaPartido());
            map.put("pista", p.getPista().getNombre());
            map.put("club", p.getPista().getClub().getNombre());
            map.put("reservaVinculada", p.getReserva() != null);
            map.put("amigosIds", p.getAmigosIds() != null ? p.getAmigosIds() : "");
            return map;
        }).toList();

        return ResponseEntity.ok(respuesta);
    }
}