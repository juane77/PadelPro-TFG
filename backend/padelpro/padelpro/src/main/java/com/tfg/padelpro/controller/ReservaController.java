package com.tfg.padelpro.controller;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.tfg.padelpro.dto.request.ReservaRequestDTO;
import com.tfg.padelpro.entity.Pista;
import com.tfg.padelpro.entity.Reserva;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.PistaRepository;
import com.tfg.padelpro.repository.ReservaRepository;
import com.tfg.padelpro.repository.UsuarioRepository;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/reservas")
public class ReservaController {

    private final ReservaRepository reservaRepository;
    private final UsuarioRepository usuarioRepository;
    private final PistaRepository pistaRepository;

    public ReservaController(ReservaRepository reservaRepository,
            UsuarioRepository usuarioRepository,
            PistaRepository pistaRepository) {
        this.reservaRepository = reservaRepository;
        this.usuarioRepository = usuarioRepository;
        this.pistaRepository = pistaRepository;
    }

    // 🔵 CREAR RESERVA
    @PostMapping
    public ResponseEntity<?> crearReserva(@Valid @RequestBody ReservaRequestDTO dto) {

        Usuario usuario = usuarioRepository.findById(dto.usuarioId())
                .orElse(null);

        if (usuario == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("mensaje", "Usuario no encontrado"));
        }

        Pista pista = pistaRepository.findById(dto.pistaId())
                .orElse(null);

        if (pista == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("mensaje", "Pista no encontrada"));
        }

        boolean existe = reservaRepository
                .existsByPistaIdAndFechaReservaAndEstado(
                        dto.pistaId(),
                        dto.fechaReserva(),
                        "ACTIVA"
                );

        if (existe) {
            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "La pista ya está reservada en ese horario"));
        }

        long reservasUsuario = reservaRepository.countByUsuarioIdAndEstado(
                dto.usuarioId(),
                "ACTIVA"
        );

        if (reservasUsuario >= 5) {

            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "Has alcanzado el máximo de 5 reservas"));

        }

        boolean yaTieneReservaEseDia
                = reservaRepository.existsByUsuarioIdAndFechaReservaBetweenAndEstado(
                        dto.usuarioId(),
                        dto.fechaReserva().toLocalDate().atStartOfDay(),
                        dto.fechaReserva().toLocalDate().atTime(23, 59),
                        "ACTIVA"
                );

        if (yaTieneReservaEseDia) {

            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "Solo puedes tener una reserva por día"));

        }

        Reserva nueva = new Reserva(usuario, pista, dto.fechaReserva());
        Reserva guardada = reservaRepository.save(nueva);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of(
                        "id", guardada.getId(),
                        "usuario", guardada.getUsuario().getNombre(),
                        "pista", guardada.getPista().getNombre(),
                        "fechaReserva", guardada.getFechaReserva(),
                        "estado", guardada.getEstado()
                ));
    }

    // 🔴 CANCELAR RESERVA
    @PutMapping("/{id}/cancelar")
    public ResponseEntity<?> cancelarReserva(@PathVariable Long id) {

        Optional<Reserva> opt = reservaRepository.findById(id);

        if (opt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Reserva reserva = opt.get();

        if (!"ACTIVA".equals(reserva.getEstado())) {
            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "La reserva ya está cancelada"));
        }

        LocalDateTime ahora = LocalDateTime.now();
        LocalDateTime limiteCancelacion = reserva.getFechaReserva().minusHours(24);

        if (ahora.isAfter(limiteCancelacion)) {

            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "No se puede cancelar con menos de 24 horas de antelación"));

        }

        reserva.setEstado("CANCELADA");
        reservaRepository.save(reserva);

        return ResponseEntity.ok(
                Map.of("mensaje", "Reserva cancelada correctamente")
        );
    }

    @GetMapping("/pista/{id}")
    public ResponseEntity<?> reservasPorPista(
            @PathVariable Long id,
            @RequestParam String fecha
    ) {

        LocalDate date = LocalDate.parse(fecha);

        LocalDateTime inicio = date.atStartOfDay();
        LocalDateTime fin = date.atTime(23, 59, 59);

        return ResponseEntity.ok(
                reservaRepository
                        .findByPistaIdAndFechaReservaBetweenAndEstado(
                                id,
                                inicio,
                                fin,
                                "ACTIVA"
                        )
        );
    }

    @GetMapping("/usuario/{id}")
    public List<Reserva> getReservasUsuario(@PathVariable Long id) {
        return reservaRepository.findByUsuarioId(id);
    }
}
