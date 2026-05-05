package com.tfg.padelpro.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tfg.padelpro.entity.Amistad;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.AmistadRepository;
import com.tfg.padelpro.repository.UsuarioRepository;

@RestController
@RequestMapping("/api/amistades")
public class AmistadController {

    private final AmistadRepository amistadRepository;
    private final UsuarioRepository usuarioRepository;

    public AmistadController(AmistadRepository amistadRepository, UsuarioRepository usuarioRepository) {
        this.amistadRepository = amistadRepository;
        this.usuarioRepository = usuarioRepository;
    }

    // BUSCAR USUARIOS POR NOMBRE O EMAIL
    @GetMapping("/buscar")
    public ResponseEntity<?> buscarUsuarios(@RequestParam String q, @RequestParam Long usuarioId) {
        List<Usuario> usuarios = usuarioRepository.buscarPorNombreOEmail(q, usuarioId);
        List<Map<String, Object>> respuesta = usuarios.stream().map(u -> {
            Optional<Amistad> amistad = amistadRepository.findEntreUsuarios(usuarioId, u.getId());
            String estadoAmistad = amistad.map(Amistad::getEstado).orElse("NINGUNA");
            Long idAmistad = amistad.map(Amistad::getId).orElse(null);
            return Map.<String, Object>of(
                "id", u.getId(),
                "nombre", u.getNombre(),
                "email", u.getEmail(),
                "estadoAmistad", estadoAmistad,
                "idAmistad", idAmistad != null ? idAmistad : 0L
            );
        }).toList();
        return ResponseEntity.ok(respuesta);
    }

    // ENVIAR SOLICITUD DE AMISTAD
    @PostMapping("/solicitar")
    public ResponseEntity<?> solicitarAmistad(@RequestBody Map<String, Long> body) {
        Long solicitanteId = body.get("solicitanteId");
        Long receptorId = body.get("receptorId");

        if (solicitanteId.equals(receptorId)) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "No puedes añadirte a ti mismo"));
        }

        Usuario solicitante = usuarioRepository.findById(solicitanteId).orElse(null);
        Usuario receptor = usuarioRepository.findById(receptorId).orElse(null);

        if (solicitante == null || receptor == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", "Usuario no encontrado"));
        }

        Optional<Amistad> existente = amistadRepository.findEntreUsuarios(solicitanteId, receptorId);
        if (existente.isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "Ya existe una solicitud o amistad entre estos usuarios"));
        }

        Amistad amistad = new Amistad(solicitante, receptor);
        amistadRepository.save(amistad);

        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("mensaje", "Solicitud enviada correctamente"));
    }

    // ACEPTAR SOLICITUD
    @PutMapping("/{id}/aceptar")
    public ResponseEntity<?> aceptarSolicitud(@PathVariable Long id) {
        return amistadRepository.findById(id).map(a -> {
            a.setEstado("ACEPTADA");
            amistadRepository.save(a);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Amistad aceptada"));
        }).orElse(ResponseEntity.<Object>notFound().build());
    }

    // RECHAZAR O ELIMINAR AMISTAD
    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarAmistad(@PathVariable Long id) {
        return amistadRepository.findById(id).map(a -> {
            amistadRepository.delete(a);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Amistad eliminada"));
        }).orElse(ResponseEntity.<Object>notFound().build());
    }

    // LISTAR AMIGOS ACEPTADOS
    @GetMapping("/usuario/{id}")
    public ResponseEntity<?> getAmigos(@PathVariable Long id) {
        List<Amistad> amistades = amistadRepository.findAmigosAceptados(id);
        List<Map<String, Object>> respuesta = amistades.stream().map(a -> {
            Usuario amigo = a.getSolicitante().getId().equals(id) ? a.getReceptor() : a.getSolicitante();
            return Map.<String, Object>of(
                "idAmistad", a.getId(),
                "id", amigo.getId(),
                "nombre", amigo.getNombre(),
                "email", amigo.getEmail()
            );
        }).toList();
        return ResponseEntity.ok(respuesta);
    }

    // SOLICITUDES PENDIENTES RECIBIDAS
    @GetMapping("/pendientes/{id}")
    public ResponseEntity<?> getSolicitudesPendientes(@PathVariable Long id) {
        List<Amistad> pendientes = amistadRepository.findSolicitudesPendientes(id);
        List<Map<String, Object>> respuesta = pendientes.stream().map(a -> Map.<String, Object>of(
            "idAmistad", a.getId(),
            "id", a.getSolicitante().getId(),
            "nombre", a.getSolicitante().getNombre(),
            "email", a.getSolicitante().getEmail()
        )).toList();
        return ResponseEntity.ok(respuesta);
    }
}