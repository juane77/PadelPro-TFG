package com.tfg.padelpro.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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

    // STATS — SUPERADMIN ve todo, ADMIN solo su club
    @GetMapping("/stats")
    public ResponseEntity<?> getStats(@RequestParam(required = false) Long clubId) {
        long totalUsuarios = usuarioRepository.count();
        long totalPartidos = partidoRepository.count();

        long totalReservas;
        long reservasActivas;

        if (clubId != null) {
            // Admin de club — solo sus reservas
            List<Reserva> reservasClub = reservaRepository.findAllByOrderByFechaReservaDesc()
                    .stream().filter(r -> r.getPista().getClub().getId().equals(clubId)).toList();
            totalReservas = reservasClub.size();
            reservasActivas = reservasClub.stream().filter(r -> "ACTIVA".equals(r.getEstado())).count();
        } else {
            // Superadmin — todo
            totalReservas = reservaRepository.count();
            reservasActivas = reservaRepository.countByEstado("ACTIVA");
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsuarios", totalUsuarios);
        stats.put("totalReservas", totalReservas);
        stats.put("reservasActivas", reservasActivas);
        stats.put("totalPartidos", totalPartidos);
        return ResponseEntity.ok(stats);
    }

    // USUARIOS — solo SUPERADMIN
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
            map.put("club", u.getClub() != null ? u.getClub().getNombre() : null);
            map.put("idClub", u.getClub() != null ? u.getClub().getId() : null);
            return map;
        }).toList();
        return ResponseEntity.ok(respuesta);
    }

    // CAMBIAR ROL
    @PutMapping("/usuarios/{id}/rol")
    public ResponseEntity<?> cambiarRol(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String nuevoRol = body.get("rol");
        if (nuevoRol == null || (!nuevoRol.equals("USER") && !nuevoRol.equals("ADMIN") && !nuevoRol.equals("SUPERADMIN"))) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "Rol inválido"));
        }
        return usuarioRepository.findById(id).map(u -> {
            u.setRol(nuevoRol);
            usuarioRepository.save(u);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Rol actualizado a " + nuevoRol));
        }).orElse(ResponseEntity.<Object>status(HttpStatus.NOT_FOUND).body(Map.of("mensaje", "Usuario no encontrado")));
    }

    // RESERVAS — SUPERADMIN ve todo, ADMIN solo su club
    @GetMapping("/reservas")
    public ResponseEntity<?> getReservas(@RequestParam(required = false) Long clubId) {
        List<Reserva> reservas = reservaRepository.findAllByOrderByFechaReservaDesc();

        // Filtrar por club si es ADMIN de club
        if (clubId != null) {
            reservas = reservas.stream()
                    .filter(r -> r.getPista().getClub().getId().equals(clubId))
                    .collect(Collectors.toList());
        }

        List<Map<String, Object>> respuesta = reservas.stream().map(r -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", r.getId());
            map.put("usuario", r.getUsuario().getNombre());
            map.put("email", r.getUsuario().getEmail());
            map.put("pista", r.getPista().getNombre());
            map.put("club", r.getPista().getClub().getNombre());
            map.put("clubId", r.getPista().getClub().getId());
            map.put("fechaReserva", r.getFechaReserva());
            map.put("estado", r.getEstado());
            return map;
        }).toList();

        return ResponseEntity.ok(respuesta);
    }

    // CANCELAR RESERVA (admin de club solo puede cancelar las suyas)
    @PutMapping("/reservas/{id}/cancelar")
    public ResponseEntity<?> cancelarReservaAdmin(@PathVariable Long id,
                                                   @RequestParam(required = false) Long clubId) {
        return reservaRepository.findById(id).map(r -> {
            // Verificar que el admin de club solo cancela reservas de su club
            if (clubId != null && !r.getPista().getClub().getId().equals(clubId)) {
                return ResponseEntity.<Object>status(HttpStatus.FORBIDDEN)
                        .body(Map.of("mensaje", "No tienes permisos para cancelar esta reserva"));
            }
            if (!"ACTIVA".equals(r.getEstado())) {
                return ResponseEntity.<Object>badRequest().body(Map.of("mensaje", "La reserva ya está cancelada"));
            }
            r.setEstado("CANCELADA");
            reservaRepository.save(r);
            Usuario u = r.getUsuario();
            u.setPelotas(u.getPelotas() + 10);
            usuarioRepository.save(u);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Reserva cancelada por administrador"));
        }).orElse(ResponseEntity.<Object>notFound().build());
    }
}