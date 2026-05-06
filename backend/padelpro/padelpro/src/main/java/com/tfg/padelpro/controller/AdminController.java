package com.tfg.padelpro.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tfg.padelpro.entity.Reserva;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.PartidoRepository;
import com.tfg.padelpro.repository.ReservaRepository;
import com.tfg.padelpro.repository.UsuarioRepository;
import com.tfg.padelpro.repository.ValoracionRepository;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UsuarioRepository usuarioRepository;
    private final ReservaRepository reservaRepository;
    private final PartidoRepository partidoRepository;
    private final ValoracionRepository valoracionRepository;

    public AdminController(UsuarioRepository usuarioRepository,
                           ReservaRepository reservaRepository,
                           PartidoRepository partidoRepository,
                           ValoracionRepository valoracionRepository) {
        this.usuarioRepository = usuarioRepository;
        this.reservaRepository = reservaRepository;
        this.partidoRepository = partidoRepository;
        this.valoracionRepository = valoracionRepository;
    }

    // ESTADÍSTICAS GLOBALES DEL DASHBOARD
    @GetMapping("/stats")
    public ResponseEntity<?> getStats() {
        long totalUsuarios = usuarioRepository.count();
        long totalReservas = reservaRepository.count();
        long reservasActivas = reservaRepository.countByEstado("ACTIVA");
        long totalPartidos = partidoRepository.count();

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsuarios", totalUsuarios);
        stats.put("totalReservas", totalReservas);
        stats.put("reservasActivas", reservasActivas);
        stats.put("totalPartidos", totalPartidos);

        return ResponseEntity.ok(stats);
    }

    // LISTAR TODOS LOS USUARIOS
    @GetMapping("/usuarios")
    public ResponseEntity<?> getUsuarios() {
        List<Usuario> usuarios = usuarioRepository.findAll();
        List<Map<String, Object>> respuesta = usuarios.stream().map(u -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", u.getId());
            map.put("nombre", u.getNombre());
            map.put("email", u.getEmail());
            map.put("rol", u.getRol());
            map.put("pelotas", u.getPelotas());
            map.put("ultimoLogin", u.getUltimoLogin());
            return map;
        }).toList();
        return ResponseEntity.ok(respuesta);
    }

    // CAMBIAR ROL DE USUARIO
    @PutMapping("/usuarios/{id}/rol")
    public ResponseEntity<?> cambiarRol(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String nuevoRol = body.get("rol");
        if (nuevoRol == null || (!nuevoRol.equals("USER") && !nuevoRol.equals("ADMIN"))) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "Rol inválido. Usa USER o ADMIN"));
        }
        return usuarioRepository.findById(id).map(u -> {
            u.setRol(nuevoRol);
            usuarioRepository.save(u);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Rol actualizado a " + nuevoRol));
        }).orElse(ResponseEntity.<Object>status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", "Usuario no encontrado")));
    }

    // LISTAR TODAS LAS RESERVAS
    @GetMapping("/reservas")
    public ResponseEntity<?> getReservas() {
        List<Reserva> reservas = reservaRepository.findAllByOrderByFechaReservaDesc();
        List<Map<String, Object>> respuesta = reservas.stream().map(r -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", r.getId());
            map.put("usuario", r.getUsuario().getNombre());
            map.put("email", r.getUsuario().getEmail());
            map.put("pista", r.getPista().getNombre());
            map.put("club", r.getPista().getClub().getNombre());
            map.put("fechaReserva", r.getFechaReserva());
            map.put("estado", r.getEstado());
            return map;
        }).toList();
        return ResponseEntity.ok(respuesta);
    }

    // CANCELAR RESERVA COMO ADMIN (sin restricción de 24h)
    @PutMapping("/reservas/{id}/cancelar")
    public ResponseEntity<?> cancelarReservaAdmin(@PathVariable Long id) {
        return reservaRepository.findById(id).map(r -> {
            if (!"ACTIVA".equals(r.getEstado())) {
                return ResponseEntity.<Object>badRequest().body(Map.of("mensaje", "La reserva ya está cancelada"));
            }
            r.setEstado("CANCELADA");
            reservaRepository.save(r);
            // Devolver pelotas al usuario
            Usuario u = r.getUsuario();
            u.setPelotas(u.getPelotas() + 10);
            usuarioRepository.save(u);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Reserva cancelada por administrador"));
        }).orElse(ResponseEntity.<Object>notFound().build());
    }
}