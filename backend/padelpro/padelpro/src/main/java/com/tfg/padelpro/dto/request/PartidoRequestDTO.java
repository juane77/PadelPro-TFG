package com.tfg.padelpro.dto.request;

import java.time.LocalDateTime;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

public record PartidoRequestDTO(

        @NotNull(message = "El usuarioId es obligatorio")
        Long usuarioId,

        @NotNull(message = "El pistaId es obligatorio")
        Long pistaId,

        Long reservaId, // opcional - vincula el partido a una reserva real

        @NotBlank(message = "El resultado es obligatorio")
        String resultado,

        @NotNull(message = "El nivel medio es obligatorio")
        @DecimalMin(value = "1.0", message = "El nivel mínimo es 1.0")
        @DecimalMax(value = "10.0", message = "El nivel máximo es 10.0")
        Double nivelMedio,

        @NotBlank(message = "El resultado final es obligatorio")
        @Pattern(regexp = "GANADO|PERDIDO", message = "El resultado final debe ser GANADO o PERDIDO")
        String resultadoFinal,

        @NotNull(message = "La fecha del partido es obligatoria")
        LocalDateTime fechaPartido,

        String amigosIds // opcional - IDs de amigos separados por coma: "2,5,8"
) {}