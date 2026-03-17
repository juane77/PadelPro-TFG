package com.tfg.padelpro.dto.request;

import java.time.LocalDateTime;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;

public record ReservaRequestDTO(
        @NotNull(message = "El usuarioId es obligatorio")
        Long usuarioId,
        @NotNull(message = "El pistaId es obligatorio")
        Long pistaId,
        @NotNull(message = "La fecha de reserva es obligatoria")
        @Future(message = "La fecha debe ser futura")
        LocalDateTime fechaReserva
        ) {

}
