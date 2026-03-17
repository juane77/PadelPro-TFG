package com.tfg.padelpro.controller;

import com.tfg.padelpro.dto.request.RegistroRequestDTO;
import com.tfg.padelpro.dto.request.LoginRequestDTO;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.UsuarioRepository;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;

    public UsuarioController(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    // 🔵 REGISTRO CON DTO Y VALIDACIÓN
    @PostMapping("/registrar")
    public ResponseEntity<?> registrar(@Valid @RequestBody RegistroRequestDTO dto) {

        if (usuarioRepository.findByEmail(dto.email()) != null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "El email ya está registrado"));
        }

        Usuario nuevo = new Usuario(
                dto.nombre(),
                dto.email(),
                dto.password()
        );

        Usuario guardado = usuarioRepository.save(nuevo);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of(
                        "id", guardado.getId(),
                        "nombre", guardado.getNombre(),
                        "email", guardado.getEmail(),
                        "rol", guardado.getRol()
                ));
    }

    // 🔵 LOGIN CON DTO Y VALIDACIÓN
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDTO dto) {

        Usuario u = usuarioRepository.findByEmail(dto.email());

        if (u == null || !u.getPassword().equals(dto.password())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "Email o contraseña incorrectos"));
        }

        return ResponseEntity.ok(
                Map.of(
                        "id", u.getId(),
                        "nombre", u.getNombre(),
                        "email", u.getEmail(),
                        "rol", u.getRol()
                )
        );
    }
}
