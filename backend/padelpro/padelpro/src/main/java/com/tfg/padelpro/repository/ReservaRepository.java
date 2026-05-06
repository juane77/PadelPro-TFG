package com.tfg.padelpro.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tfg.padelpro.entity.Reserva;

public interface ReservaRepository extends JpaRepository<Reserva, Long> {

    boolean existsByPistaIdAndFechaReservaAndEstado(Long pistaId, LocalDateTime fechaReserva, String estado);

    long countByUsuarioIdAndEstado(Long usuarioId, String estado);

    long countByEstado(String estado);

    boolean existsByUsuarioIdAndFechaReservaBetweenAndEstado(Long usuarioId, LocalDateTime inicio, LocalDateTime fin, String estado);

    List<Reserva> findByPistaIdAndFechaReservaBetweenAndEstado(Long pistaId, LocalDateTime inicio, LocalDateTime fin, String estado);

    List<Reserva> findByUsuarioId(Long usuarioId);

    List<Reserva> findAllByOrderByFechaReservaDesc();

    // Necesario para el scheduler
    List<Reserva> findByFechaReservaBefore(LocalDateTime fecha);
}