package com.tfg.padelpro.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "amistad")
public class Amistad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_amistad")
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_solicitante", nullable = false)
    private Usuario solicitante;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_receptor", nullable = false)
    private Usuario receptor;

    @Column(nullable = false)
    private String estado = "PENDIENTE"; // PENDIENTE, ACEPTADA, RECHAZADA

    protected Amistad() {}

    public Amistad(Usuario solicitante, Usuario receptor) {
        this.solicitante = solicitante;
        this.receptor = receptor;
        this.estado = "PENDIENTE";
    }

    public Long getId() { return id; }
    public Usuario getSolicitante() { return solicitante; }
    public Usuario getReceptor() { return receptor; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}