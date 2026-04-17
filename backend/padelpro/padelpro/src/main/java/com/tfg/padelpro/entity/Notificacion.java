package com.tfg.padelpro.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "notificacion")
public class Notificacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_notificacion")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @Column(nullable = false)
    private String mensaje;

    // INFO, IMPORTANTE, ALERTA
    @Column(nullable = false)
    private String tipo;

    @Column(nullable = false)
    private boolean leida = false;

    @Column(name = "fecha_notificacion", nullable = false)
    private LocalDateTime fechaNotificacion;

    protected Notificacion() {}

    public Notificacion(Usuario usuario, String mensaje, String tipo) {
        this.usuario = usuario;
        this.mensaje = mensaje;
        this.tipo = tipo;
        this.leida = false;
        this.fechaNotificacion = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public Usuario getUsuario() { return usuario; }
    public String getMensaje() { return mensaje; }
    public String getTipo() { return tipo; }
    public boolean isLeida() { return leida; }
    public LocalDateTime getFechaNotificacion() { return fechaNotificacion; }
    public void setLeida(boolean leida) { this.leida = leida; }
}