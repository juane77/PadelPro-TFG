package com.tfg.padelpro;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class PadelproApplication {

    public static void main(String[] args) {
        SpringApplication.run(PadelproApplication.class, args);
    }
}