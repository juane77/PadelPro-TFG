package com.tfg.padelpro.controller;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

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

    @PostMapping("/registrar")
    public ResponseEntity<?> registrar(@Valid @RequestBody RegistroRequestDTO dto) {
        if (usuarioRepository.findByEmail(dto.email()) != null) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "El email ya está registrado"));
        }
        String passwordHasheada = passwordEncoder.encode(dto.password());
        Usuario nuevo = new Usuario(dto.nombre(), dto.email(), passwordHasheada);
        Usuario guardado = usuarioRepository.save(nuevo);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "id", guardado.getId(),
                "nombre", guardado.getNombre(),
                "email", guardado.getEmail(),
                "rol", guardado.getRol()
        ));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequestDTO dto) {
        Usuario u = usuarioRepository.findByEmail(dto.email());
        if (u == null || !passwordEncoder.matches(dto.password(), u.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("mensaje", "Email o contraseña incorrectos"));
        }

        String token = jwtUtil.generateToken(u.getEmail());

        LocalDate hoy = LocalDate.now();
        if (u.getUltimoLogin() == null || !u.getUltimoLogin().equals(hoy)) {
            u.setPelotas(u.getPelotas() + 5);
            u.setUltimoLogin(hoy);
            usuarioRepository.save(u);
        }

        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("id", u.getId());
        respuesta.put("nombre", u.getNombre());
        respuesta.put("email", u.getEmail());
        respuesta.put("rol", u.getRol());
        respuesta.put("token", token);
        respuesta.put("pelotas", u.getPelotas());
        // Devolver idClub para que el panel sepa qué club filtrar
        respuesta.put("idClub", u.getClub() != null ? u.getClub().getId() : null);
        respuesta.put("clubNombre", u.getClub() != null ? u.getClub().getNombre() : null);

        return ResponseEntity.ok(respuesta);
    }

    @GetMapping("/{id}/pelotas")
    public ResponseEntity<?> getPelotas(@PathVariable Long id) {
        return usuarioRepository.findById(id).map(u ->
            ResponseEntity.<Object>ok(Map.of("pelotas", u.getPelotas()))
        ).orElse(ResponseEntity.<Object>notFound().build());
    }

    @PutMapping("/{id}/nombre")
    public ResponseEntity<?> editarNombre(@PathVariable Long id, @RequestBody Map<String, String> body) {
        return usuarioRepository.findById(id).map(u -> {
            String nuevoNombre = body.get("nombre");
            if (nuevoNombre == null || nuevoNombre.trim().length() < 2) {
                return ResponseEntity.badRequest().<Object>body(Map.of("mensaje", "El nombre debe tener al menos 2 caracteres"));
            }
            u.setNombre(nuevoNombre.trim());
            usuarioRepository.save(u);
            return ResponseEntity.<Object>ok(Map.of("mensaje", "Nombre actualizado correctamente"));
        }).orElse(ResponseEntity.<Object>notFound().build());
    }

    @PostMapping("/recuperar")
    public ResponseEntity<?> solicitarRecuperacion(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        
        if (email == null || email.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("mensaje", "El email es obligatorio"));
        }
        
        Usuario u = usuarioRepository.findByEmail(email);
        
        if (u == null) {
            return ResponseEntity.badRequest()
                .body(Map.of("mensaje", "El email no está registrado"));
        }
        
        String codigo = String.format("%06d", new Random().nextInt(999999));
        u.setCodigoRecuperacion(codigo);
        u.setCodigoExpiracion(LocalDateTime.now().plusMinutes(15));
        usuarioRepository.save(u);
        
        return ResponseEntity.ok(Map.of(
            "mensaje", "Código generado",
            "codigo", codigo
        ));
    }

    @PostMapping("/cambiar-password")
    public ResponseEntity<?> cambiarPassword(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String codigo = body.get("codigo");
        String nuevaPassword = body.get("nuevaPassword");
        
        if (email == null || codigo == null || nuevaPassword == null) {
            return ResponseEntity.badRequest()
                .body(Map.of("mensaje", "Todos los campos son obligatorios"));
        }
        
        Usuario u = usuarioRepository.findByEmail(email);
        
        if (u == null) {
            return ResponseEntity.badRequest()
                .body(Map.of("mensaje", "Usuario no encontrado"));
        }
        
        if (u.getCodigoRecuperacion() == null || 
            !u.getCodigoRecuperacion().equals(codigo) ||
            u.getCodigoExpiracion() == null ||
            u.getCodigoExpiracion().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest()
                .body(Map.of("mensaje", "Código inválido o expirado"));
        }
        
        if (nuevaPassword.length() < 4) {
            return ResponseEntity.badRequest()
                .body(Map.of("mensaje", "La contraseña debe tener al menos 4 caracteres"));
        }
        
        u.setPassword(passwordEncoder.encode(nuevaPassword));
        u.setCodigoRecuperacion(null);
        u.setCodigoExpiracion(null);
        usuarioRepository.save(u);
        
        return ResponseEntity.ok(Map.of("mensaje", "Contraseña actualizada correctamente"));
    }
}