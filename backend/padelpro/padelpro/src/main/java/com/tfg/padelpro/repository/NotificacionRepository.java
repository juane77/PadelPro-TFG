package com.tfg.padelpro.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tfg.padelpro.entity.Notificacion;

public interface NotificacionRepository extends JpaRepository<Notificacion, Long> {

    List<Notificacion> findByUsuarioIdOrderByFechaNotificacionDesc(Long usuarioId);

    long countByUsuarioIdAndLeidaFalse(Long usuarioId);
}