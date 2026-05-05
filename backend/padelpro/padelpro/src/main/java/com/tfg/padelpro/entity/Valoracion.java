package com.tfg.padelpro.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "valoracion")
public class Valoracion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_valoracion")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_pista", nullable = false)
    private Pista pista;

    @Column(nullable = false)
    private Double puntuacion; // 1.0 - 5.0

    protected Valoracion() {}

    public Valoracion(Usuario usuario, Pista pista, Double puntuacion) {
        this.usuario = usuario;
        this.pista = pista;
        this.puntuacion = puntuacion;
    }

    public Long getId() { return id; }
    public Usuario getUsuario() { return usuario; }
    public Pista getPista() { return pista; }
    public Double getPuntuacion() { return puntuacion; }
    public void setPuntuacion(Double puntuacion) { this.puntuacion = puntuacion; }
}