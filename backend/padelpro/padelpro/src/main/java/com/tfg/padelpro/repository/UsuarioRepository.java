package com.tfg.padelpro.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tfg.padelpro.entity.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Usuario findByEmail(String email);

    // Buscar usuarios por nombre o email (excluyendo al propio usuario)
    @Query("SELECT u FROM Usuario u WHERE u.id != :usuarioId AND (LOWER(u.nombre) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :q, '%')))")
    List<Usuario> buscarPorNombreOEmail(@Param("q") String q, @Param("usuarioId") Long usuarioId);
}