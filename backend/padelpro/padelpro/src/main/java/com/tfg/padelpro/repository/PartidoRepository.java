package com.tfg.padelpro.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tfg.padelpro.entity.Partido;

public interface PartidoRepository extends JpaRepository<Partido, Long> {
    List<Partido> findByUsuarioIdOrderByFechaPartidoDesc(Long usuarioId);
}