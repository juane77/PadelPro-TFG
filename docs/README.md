# PadelPro 🎾

Aplicación para reservar pistas de pádel, gestionar partidos, conectar con otros jugadores y seguir noticias del mundo del pádel.

## Tecnologías

- **Frontend:** Flutter (Android + Web)
- **Backend:** Spring Boot 4.0.2 (Java 21)
- **Base de datos:** PostgreSQL (Supabase)
- **Almacenamiento:** Supabase Storage (fotos de perfil)
- **Email:** Brevo API
- **Noticias:** GNews API

## Requisitos

- Flutter SDK ^3.10.4
- Java 21
- Maven

## Cómo arrancar

### Backend

```bash
cd backend/padelpro/padelpro
mvn spring-boot:run
```

El servidor arranca en `http://localhost:8080`.

### Frontend (Flutter)

```bash
cd frontend/PadelPro/PadelPro
flutter pub get
flutter run
```

Para web:
```bash
flutter run -d chrome
```

## Tests

### Frontend
```bash
cd frontend/PadelPro/PadelPro
flutter test
```

### Backend
```bash
cd backend/padelpro/padelpro
mvn test
```
