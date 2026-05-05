package com.tfg.padelpro.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import com.tfg.padelpro.entity.Valoracion;

public interface ValoracionRepository extends JpaRepository<Valoracion, Long> {

    Optional<Valoracion> findByUsuarioIdAndPistaId(Long usuarioId, Long pistaId);

    @Query("SELECT AVG(v.puntuacion) FROM Valoracion v WHERE v.pista.id = :pistaId")
    Double getMediaByPistaId(@Param("pistaId") Long pistaId);

    long countByPistaId(Long pistaId);
}