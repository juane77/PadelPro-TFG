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
@Table(name = "partido")
public class Partido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_partido")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_pista", nullable = false)
    private Pista pista;

    @Column(nullable = false)
    private String resultado; // ej: "6-2 · 1-6 · 7-6"

    @Column(name = "nivel_medio", nullable = false)
    private Double nivelMedio;

    @Column(nullable = false)
    private String resultado_final; // "GANADO" o "PERDIDO"

    @Column(name = "fecha_partido", nullable = false)
    private LocalDateTime fechaPartido;

    protected Partido() {}

    public Partido(Usuario usuario, Pista pista, String resultado,
                   Double nivelMedio, String resultado_final, LocalDateTime fechaPartido) {
        this.usuario = usuario;
        this.pista = pista;
        this.resultado = resultado;
        this.nivelMedio = nivelMedio;
        this.resultado_final = resultado_final;
        this.fechaPartido = fechaPartido;
    }

    public Long getId() { return id; }
    public Usuario getUsuario() { return usuario; }
    public Pista getPista() { return pista; }
    public String getResultado() { return resultado; }
    public Double getNivelMedio() { return nivelMedio; }
    public String getResultado_final() { return resultado_final; }
    public LocalDateTime getFechaPartido() { return fechaPartido; }
}