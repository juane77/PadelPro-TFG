package com.tfg.padelpro;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.tfg.padelpro.entity.Reserva;
import com.tfg.padelpro.repository.ReservaRepository;

import jakarta.annotation.PostConstruct;

@Component
public class ReservaScheduler {

    private final ReservaRepository reservaRepository;

    public ReservaScheduler(ReservaRepository reservaRepository) {
        this.reservaRepository = reservaRepository;
    }

    // Se ejecuta al arrancar el servidor
    @PostConstruct
    public void cancelarAlArrancar() {
        cancelarReservasPasadas();
    }

    // Se ejecuta cada día a medianoche
    @Scheduled(cron = "0 0 0 * * *")
    public void cancelarReservasPasadas() {

        List<Reserva> pasadas = reservaRepository
                .findByFechaReservaBefore(LocalDateTime.now());

        for (Reserva r : pasadas) {
            if ("ACTIVA".equals(r.getEstado())) {
                r.setEstado("CANCELADA");
            }
        }

        reservaRepository.saveAll(pasadas);
    }
}