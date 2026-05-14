package com.tfg.padelpro.security;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class JwtUtilTest {

    private JwtUtil jwtUtil;

    @BeforeEach
    void setUp() {
        jwtUtil = new JwtUtil();
    }

    @Test
    void generarToken_devuelveTokenNoNulo() {
        String token = jwtUtil.generateToken("test@test.com");
        assertNotNull(token);
        assertFalse(token.isBlank());
    }

    @Test
    void extractEmail_devuelveEmailCorrecto() {
        String email = "usuario@email.com";
        String token = jwtUtil.generateToken(email);
        assertEquals(email, jwtUtil.extractEmail(token));
    }

    @Test
    void isValid_devuelveTrueParaTokenValido() {
        String token = jwtUtil.generateToken("test@test.com");
        assertTrue(jwtUtil.isValid(token));
    }

    @Test
    void isValid_devuelveFalseParaTokenInvalido() {
        assertFalse(jwtUtil.isValid("token-invalido"));
    }

    @Test
    void isValid_devuelveFalseParaTokenVacio() {
        assertFalse(jwtUtil.isValid(""));
    }
}
