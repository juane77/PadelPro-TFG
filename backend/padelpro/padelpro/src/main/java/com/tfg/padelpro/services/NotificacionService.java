package com.tfg.padelpro.services;

import org.springframework.stereotype.Service;

import com.tfg.padelpro.entity.Notificacion;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.NotificacionRepository;

@Service
public class NotificacionService {

    private final NotificacionRepository notificacionRepository;

    public NotificacionService(NotificacionRepository notificacionRepository) {
        this.notificacionRepository = notificacionRepository;
    }

    public void crear(Usuario usuario, String mensaje, String tipo) {
        notificacionRepository.save(new Notificacion(usuario, mensaje, tipo));
    }

    public void info(Usuario usuario, String mensaje) {
        crear(usuario, mensaje, "INFO");
    }

    public void importante(Usuario usuario, String mensaje) {
        crear(usuario, mensaje, "IMPORTANTE");
    }

    public void alerta(Usuario usuario, String mensaje) {
        crear(usuario, mensaje, "ALERTA");
    }
}