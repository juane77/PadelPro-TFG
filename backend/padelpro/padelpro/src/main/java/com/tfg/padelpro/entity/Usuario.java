package com.tfg.padelpro.entity;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "usuario")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuario")
    private Long id;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String estado = "ACTIVO";

    @Column(nullable = false)
    private String rol = "USER";

    @Column(nullable = false)
    private int pelotas = 100;

    @Column(name = "ultimo_login")
    private LocalDate ultimoLogin;

    @ManyToOne
    @JoinColumn(name = "id_club", nullable = true)
    private Club club;

    protected Usuario() {}

    public Usuario(String nombre, String email, String password) {
        this.nombre = nombre;
        this.email = email;
        this.password = password;
        this.estado = "ACTIVO";
        this.rol = "USER";
        this.pelotas = 100;
    }

    public Long getId() { return id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getEmail() { return email; }
    public String getRol() { return rol; }
    public String getPassword() { return password; }
    public void setRol(String rol) { this.rol = rol; }
    public int getPelotas() { return pelotas; }
    public void setPelotas(int pelotas) { this.pelotas = pelotas; }
    public LocalDate getUltimoLogin() { return ultimoLogin; }
    public void setUltimoLogin(LocalDate ultimoLogin) { this.ultimoLogin = ultimoLogin; }
    public Club getClub() { return club; }
    public void setClub(Club club) { this.club = club; }
}