package com.tfg.padelpro.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tfg.padelpro.entity.Notificacion;
import com.tfg.padelpro.repository.NotificacionRepository;

@RestController
@RequestMapping("/api/notificaciones")
public class NotificacionController {

    private final NotificacionRepository notificacionRepository;

    public NotificacionController(NotificacionRepository notificacionRepository) {
        this.notificacionRepository = notificacionRepository;
    }

    // 🔵 OBTENER NOTIFICACIONES DEL USUARIO
    @GetMapping("/usuario/{id}")
    public ResponseEntity<?> getNotificaciones(@PathVariable Long id) {

        List<Notificacion> lista =
                notificacionRepository.findByUsuarioIdOrderByFechaNotificacionDesc(id);

        List<Map<String, Object>> respuesta = lista.stream().map(n -> Map.<String, Object>of(
                "id", n.getId(),
                "mensaje", n.getMensaje(),
                "tipo", n.getTipo(),
                "leida", n.isLeida(),
                "fecha", n.getFechaNotificacion()
        )).toList();

        return ResponseEntity.ok(respuesta);
    }

    // 🔵 CONTAR NO LEÍDAS
    @GetMapping("/usuario/{id}/noLeidas")
    public ResponseEntity<?> contarNoLeidas(@PathVariable Long id) {
        long count = notificacionRepository.countByUsuarioIdAndLeidaFalse(id);
        return ResponseEntity.ok(Map.of("noLeidas", count));
    }

    // 🔵 MARCAR COMO LEÍDA
    @PutMapping("/{id}/leer")
    public ResponseEntity<?> marcarLeida(@PathVariable Long id) {

        return notificacionRepository.findById(id).map(n -> {
            n.setLeida(true);
            notificacionRepository.save(n);
            return ResponseEntity.ok(Map.of("mensaje", "Notificación marcada como leída"));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 🔵 MARCAR TODAS COMO LEÍDAS
    @PutMapping("/usuario/{id}/leerTodas")
    public ResponseEntity<?> marcarTodasLeidas(@PathVariable Long id) {

        List<Notificacion> lista =
                notificacionRepository.findByUsuarioIdOrderByFechaNotificacionDesc(id);

        lista.forEach(n -> n.setLeida(true));
        notificacionRepository.saveAll(lista);

        return ResponseEntity.ok(Map.of("mensaje", "Todas las notificaciones marcadas como leídas"));
    }

    // 🗑️ BORRAR NOTIFICACIÓN
    @DeleteMapping("/{id}")
    public ResponseEntity<?> borrarNotificacion(@PathVariable Long id) {
        if (!notificacionRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        notificacionRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("mensaje", "Notificación eliminada"));
    }

    // 🗑️ BORRAR TODAS LAS NOTIFICACIONES DEL USUARIO
    @DeleteMapping("/usuario/{id}")
    public ResponseEntity<?> borrarTodas(@PathVariable Long id) {
        List<Notificacion> lista =
                notificacionRepository.findByUsuarioIdOrderByFechaNotificacionDesc(id);
        notificacionRepository.deleteAll(lista);
        return ResponseEntity.ok(Map.of("mensaje", "Todas las notificaciones eliminadas"));
    }
}