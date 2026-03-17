package com.tfg.padelpro.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tfg.padelpro.entity.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Usuario findByEmail(String email);
}
