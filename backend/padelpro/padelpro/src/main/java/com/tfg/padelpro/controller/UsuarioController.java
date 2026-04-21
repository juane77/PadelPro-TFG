package com.tfg.padelpro.controller;

import java.time.LocalDate;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tfg.padelpro.dto.request.LoginRequestDTO;
import com.tfg.padelpro.dto.request.RegistroRequestDTO;
import com.tfg.padelpro.entity.Usuario;
import com.tfg.padelpro.repository.UsuarioRepository;
import com.tfg.padelpro.security.JwtUtil;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public UsuarioController(UsuarioRepository usuarioRepository,
                             PasswordEncoder passwordEncoder,
                             JwtUtil jwtUtil) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // 🔵 REGISTRO CON BCRYPT
    @PostMapping("/registrar")
    public ResponseEntity<?> registrar(@Valid @RequestBody RegistroRequestDTO dto) {

        if (usuarioRepository.findByEmail(dto.email()) != null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("mensaje", "El email ya está registrado"));
        }

        String passwordHasheada = passwordEncoder.encode(dto.password());

        Usuario nuevo = new Usuario(
                dto.nombre(),
                dto.email(),
                passwordHasheada
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

    // 🔵 LOGIN — devuelve token JWT
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDTO dto) {

        Usuario u = usuarioRepository.findByEmail(dto.email());

        if (u == null || !passwordEncoder.matches(dto.password(), u.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "Email o contraseña incorrectos"));
        }

        String token = jwtUtil.generateToken(u.getEmail());

        // 🎾 BONUS DIARIO — 5 pelotas si no ha iniciado sesión hoy
        LocalDate hoy = LocalDate.now();
        if (u.getUltimoLogin() == null || !u.getUltimoLogin().equals(hoy)) {
            u.setPelotas(u.getPelotas() + 5);
            u.setUltimoLogin(hoy);
            usuarioRepository.save(u);
        }

        return ResponseEntity.ok(
                Map.of(
                        "id", u.getId(),
                        "nombre", u.getNombre(),
                        "email", u.getEmail(),
                        "rol", u.getRol(),
                        "token", token,
                        "pelotas", u.getPelotas()
                )
        );
    }

    // 🎾 CONSULTAR PELOTAS
    @GetMapping("/{id}/pelotas")
    public ResponseEntity<?> getPelotas(@PathVariable Long id) {
        return usuarioRepository.findById(id).map(u ->
            ResponseEntity.<Object>ok(Map.of("pelotas", u.getPelotas()))
        ).orElse(ResponseEntity.<Object>notFound().build());
    }

    // 🔵 EDITAR NOMBRE
    @PutMapping("/{id}/nombre")
    public ResponseEntity<?> editarNombre(@PathVariable Long id,
                                          @RequestBody Map<String, String> body) {

        return usuarioRepository.findById(id).map(u -> {
            String nuevoNombre = body.get("nombre");
            if (nuevoNombre == null || nuevoNombre.trim().length() < 2) {
                return ResponseEntity.badRequest()
                        .<Object>body(Map.of("mensaje", "El nombre debe tener al menos 2 caracteres"));
            }
            u.setNombre(nuevoNombre.trim());
            usuarioRepository.save(u);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Nombre actualizado correctamente"));
        }).orElse(ResponseEntity.<Object>notFound().build());
    }
}