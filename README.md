# Plataforma de Cursos

Aplicación web para gestión de una plataforma de cursos online, desarrollada con Ruby on Rails para el Trabajo Práctico N°1 de Programación IV.

## Objetivo

Permitir que profesores publiquen cursos organizados por categorías, con lecciones, y que alumnos se inscriban y dejen reseñas.

## Tipos de usuario

- **Admin**: gestiona categorías, cursos y lecciones desde el back-office (`/admin`).
- **Profesor**: dicta cursos (asignado como `user` de un `Course`).
- **Alumno**: se inscribe a cursos y deja reseñas a través de la API.

## Modelo de datos

- **User**: alumno, profesor o admin (campo `role`), con autenticación por contraseña (`has_secure_password`).
- **Category**: categoría de cursos.
- **Course**: pertenece a una categoría y a un profesor (`user`); tiene imagen de portada (Active Storage).
- **Lesson**: pertenece a un curso.
- **Enrollment**: inscripción de un alumno a un curso (estado: pendiente/activa/completada/cancelada).
- **Review**: reseña de un alumno sobre un curso (rating 1-5 + comentario).

## Instalación

1. Cloná el repositorio y entrá a la carpeta:
```bash
   git clone <URL_DEL_REPO>
   cd plataforma_cursos
```

2. Instalá las dependencias:
```bash
   bundle install
```

3. Prepar. la base de datos:
```bash
   bin/rails db:create
   bin/rails db:migrate
```

4. (Opcional) Creá un usuario admin de prueba desde la consola:
```bash
   bin/rails console
```
```ruby
   User.create(name: "Admin", email: "admin@test.com", password: "admin123", role: "admin")
```

5. Levantá el servidor:
```bash
   bin/rails server
```

6. Accedé a `http://localhost:3000`.

## Back-office (admin)

- URL: `http://localhost:3000/login`
- Credenciales de prueba: `admin@test.com` / `admin123` (ver paso 4 de instalación)
- Gestión de: Categorías (`/admin/categories`), Cursos (`/admin/courses`), Lecciones (`/admin/lessons`)

## API (api/v1)

Todas las respuestas son JSON. Los endpoints protegidos requieren el header `Authorization: Bearer <token>`.

| Método | Endpoint              | Descripción                          | Auth |
|--------|------------------------|---------------------------------------|------|
| POST   | `/api/v1/login`        | Login, devuelve token                 | No   |
| GET    | `/api/v1/courses`      | Lista de cursos                       | No   |
| GET    | `/api/v1/courses/:id`  | Detalle de un curso (con lecciones)   | No   |
| GET    | `/api/v1/profile`      | Perfil del usuario autenticado        | Sí   |
| GET    | `/api/v1/orders`       | Inscripciones del usuario             | Sí   |
| POST   | `/api/v1/orders`       | Inscribirse a un curso (`course_id`)  | Sí   |

### Ejemplo de login (PowerShell):
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/login" -Method Post -ContentType "application/json" -Body '{"email":"juan@test.com","password":"123456"}'
```

## Testing

```bash
bin/rails test
```

## Calidad y seguridad

```bash
bin/rubocop
bin/brakeman
```

## Tecnologías

- Ruby 3.4 / Rails 8.1
- SQLite
- Active Storage (imagen de portada de cursos)
- Action Mailer (confirmación de inscripción, visible en desarrollo con `letter_opener`)