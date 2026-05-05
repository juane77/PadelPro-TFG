package com.tfg.padelpro.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tfg.padelpro.entity.Amistad;

public interface AmistadRepository extends JpaRepository<Amistad, Long> {

    // Amistades aceptadas de un usuario
    @Query("SELECT a FROM Amistad a WHERE (a.solicitante.id = :id OR a.receptor.id = :id) AND a.estado = 'ACEPTADA'")
    List<Amistad> findAmigosAceptados(@Param("id") Long id);

    // Solicitudes pendientes recibidas
    @Query("SELECT a FROM Amistad a WHERE a.receptor.id = :id AND a.estado = 'PENDIENTE'")
    List<Amistad> findSolicitudesPendientes(@Param("id") Long id);

    // Comprobar si ya existe una amistad entre dos usuarios
    @Query("SELECT a FROM Amistad a WHERE (a.solicitante.id = :id1 AND a.receptor.id = :id2) OR (a.solicitante.id = :id2 AND a.receptor.id = :id1)")
    Optional<Amistad> findEntreUsuarios(@Param("id1") Long id1, @Param("id2") Long id2);
}