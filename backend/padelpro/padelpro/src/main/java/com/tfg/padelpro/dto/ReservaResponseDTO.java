package com.tfg.padelpro.dto;

import java.time.LocalDateTime;

public record ReservaResponseDTO(
    Long id,
    String usuario,
    String pista,
    LocalDateTime fechaReserva,
    String estado
) {}
