package com.tfg.padelpro.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tfg.padelpro.entity.Reserva;

public interface ReservaRepository extends JpaRepository<Reserva, Long> {

    /// comprobar si existe reserva
    boolean existsByPistaIdAndFechaReservaAndEstado(
            Long pistaId,
            LocalDateTime fechaReserva,
            String estado
    );

    /// reservas de una pista entre dos horas
    List<Reserva> findByPistaIdAndFechaReservaBetweenAndEstado(
            Long pistaId,
            LocalDateTime inicio,
            LocalDateTime fin,
            String estado
    );

    /// reservas de usuario
    List<Reserva> findByUsuarioId(Long id);

    long countByUsuarioIdAndEstado(Long usuarioId, String estado);

    boolean existsByUsuarioIdAndFechaReservaBetweenAndEstado(
            Long usuarioId,
            LocalDateTime inicio,
            LocalDateTime fin,
            String estado
    );
}
