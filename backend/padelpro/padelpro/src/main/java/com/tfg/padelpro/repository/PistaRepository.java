package com.tfg.padelpro.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tfg.padelpro.entity.Pista;

public interface PistaRepository extends JpaRepository<Pista, Long> {

    @Query("""
           SELECT p FROM Pista p
           WHERE (:tipo IS NULL OR LOWER(p.tipo) = LOWER(:tipo))
           AND (:ciudad IS NULL OR LOWER(p.club.ciudad) = LOWER(:ciudad))
           AND (:precioMax IS NULL OR p.precioHora <= :precioMax)
           """)
    List<Pista> buscarConFiltros(
            @Param("tipo") String tipo,
            @Param("ciudad") String ciudad,
            @Param("precioMax") Double precioMax
    );
}