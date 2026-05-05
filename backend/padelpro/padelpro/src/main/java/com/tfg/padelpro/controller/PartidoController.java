package com.tfg.padelpro.controller;

import java.util.ArrayList;
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
        return ResponseEntity.status(HttpStatus.CREATED).body(buildPartidoMap(guardado, false, null));
    }

    // PARTIDOS DEL USUARIO (propios)
    @GetMapping("/usuario/{id}")
    public ResponseEntity<?> getPartidosUsuario(@PathVariable Long id) {
        List<Partido> partidos = partidoRepository.findByUsuarioIdOrderByFechaPartidoDesc(id);
        List<Map<String, Object>> respuesta = partidos.stream()
                .map(p -> buildPartidoMap(p, false, null))
                .toList();
        return ResponseEntity.ok(respuesta);
    }

    // PARTIDOS DONDE EL USUARIO FUE INVITADO COMO AMIGO
    @GetMapping("/invitado/{id}")
    public ResponseEntity<?> getPartidosComoInvitado(@PathVariable Long id) {
        String idStr = id.toString();
        // Buscar todos los partidos que tengan este ID en amigosIds
        List<Partido> todos = partidoRepository.findAll();
        List<Map<String, Object>> respuesta = new ArrayList<>();

        for (Partido p : todos) {
            if (p.getAmigosIds() != null && !p.getAmigosIds().isEmpty()) {
                String[] ids = p.getAmigosIds().split(",");
                for (String aid : ids) {
                    if (aid.trim().equals(idStr)) {
                        String nombreCreador = p.getUsuario().getNombre();
                        respuesta.add(buildPartidoMap(p, true, nombreCreador));
                        break;
                    }
                }
            }
        }

        // Ordenar por fecha descendente
        respuesta.sort((a, b) -> b.get("fechaPartido").toString().compareTo(a.get("fechaPartido").toString()));
        return ResponseEntity.ok(respuesta);
    }

    // OBTENER UN PARTIDO POR ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getPartido(@PathVariable Long id) {
        return partidoRepository.findById(id)
                .map(p -> ResponseEntity.ok(buildPartidoMap(p, false, null)))
                .orElse(ResponseEntity.notFound().build());
    }

    private Map<String, Object> buildPartidoMap(Partido p, boolean esInvitado, String nombreCreador) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", p.getId());
        map.put("resultado", p.getResultado());
        map.put("nivelMedio", p.getNivelMedio());
        map.put("resultadoFinal", p.getResultado_final());
        map.put("fechaPartido", p.getFechaPartido());
        map.put("pista", p.getPista().getNombre());
        map.put("pistaId", p.getPista().getId());
        map.put("club", p.getPista().getClub().getNombre());
        map.put("reservaVinculada", p.getReserva() != null);
        map.put("amigosIds", p.getAmigosIds() != null ? p.getAmigosIds() : "");
        map.put("esInvitado", esInvitado);
        map.put("nombreCreador", nombreCreador != null ? nombreCreador : "");
        return map;
    }
}