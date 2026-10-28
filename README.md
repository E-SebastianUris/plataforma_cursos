# Plataforma de Cursos

Aplicación web de una plataforma de cursos online, desarrollada con Ruby on Rails para el Trabajo Práctico N°1 de Programación IV.

Tiene dos partes separadas:

- **Back office** de administración, hecho con Rails tradicional (controllers, vistas ERB, formularios y Active Record).
- **API JSON** versionada (`/api/v1`) pensada para ser consumida por un front-end público.

## Objetivo

Permitir que un profesor publique cursos organizados por categorías y con lecciones, y que los alumnos se inscriban y dejen reseñas.

## Tipos de usuario

| Rol | Qué hace | Cómo accede |
|-----|----------|-------------|
| Admin | Administra categorías, cursos, lecciones, usuarios y modera reseñas | Back office (`/login`) |
| Profesor | Dicta cursos (es el `user` de un `Course`); lo crea un admin | Creado desde el back office |
| Alumno | Se inscribe a cursos y los reseña | API, con token |

Todos los usuarios están en un único modelo `User` con un campo `role` (`alumno`, `profesor`, `admin`). Solo los admin pueden iniciar sesión en el back office.

## Modelo de datos

- **User**: nombre, email (único), contraseña (`has_secure_password`), rol y `auth_token` para la API.
- **Category**: nombre (único) y descripción. Tiene muchos cursos.
- **Course**: título, descripción, precio (>= 0) e imagen de portada (Active Storage). Pertenece a una categoría y a un profesor. Tiene muchas lecciones, inscripciones y reseñas.
- **Lesson**: título, contenido y posición. Pertenece a un curso.
- **Enrollment**: inscripción de un alumno a un curso, con estado (`pendiente`, `activa`, `completada`, `cancelada`). Un alumno no puede inscribirse dos veces al mismo curso.
- **Review**: puntaje de 1 a 5 y comentario de un alumno sobre un curso. Un alumno solo puede reseñar un curso una vez.

Al eliminar un curso se eliminan sus lecciones, inscripciones y reseñas. Al eliminar un profesor se eliminan sus cursos.

## Instalación

Requisitos: Ruby 3.4 o superior y Bundler (la base de datos es SQLite, no hace falta instalar un servidor).

```bash
git clone <URL_DEL_REPOSITORIO>
cd plataforma_cursos
bundle install
bin/rails db:setup
bin/rails server
```

`db:setup` crea la base de datos, aplica las migraciones y carga datos de demostración (`db/seeds.rb`). La aplicación queda en `http://localhost:3000`.

En Windows, si `bin/rails` no se ejecuta directamente, usar `ruby bin/rails ...`.

## Credenciales de prueba

Cargadas por `db/seeds.rb`:

| Rol | Email | Contraseña |
|-----|-------|------------|
| Admin | admin@test.com | admin123 |
| Profesor | profesor@test.com | 123456 |
| Alumno | juan@test.com | 123456 |
| Alumno | ana@test.com | 123456 |

## Back office

Ingresar en `http://localhost:3000/login` con el usuario admin. Secciones (`/admin`):

- **Categorías**, **Cursos** y **Lecciones**: alta, baja, modificación y listado. En los cursos se puede subir una imagen de portada.
- **Usuarios**: alta, edición (la contraseña vacía conserva la actual) y baja. Desde acá se crean los profesores. Un admin no puede eliminar su propio usuario.
- **Reseñas**: listado y eliminación. Las reseñas las escriben los alumnos por la API, así que el back office solo permite moderarlas.

## API

Todas las respuestas son JSON. Los endpoints protegidos requieren el header `Authorization: Bearer <token>`, y el token se obtiene con `POST /api/v1/login` (cambia en cada login).

| Método | Endpoint | Descripción | Token |
|--------|----------|-------------|-------|
| POST | `/api/v1/login` | Recibe `email` y `password`; devuelve el token y los datos básicos del usuario | No |
| GET | `/api/v1/courses` | Lista de cursos con categoría y profesor | No |
| GET | `/api/v1/courses/:id` | Detalle de un curso con sus lecciones | No |
| GET | `/api/v1/courses/:course_id/reviews` | Reseñas del curso, con promedio y cantidad | No |
| POST | `/api/v1/courses/:course_id/reviews` | Crea una reseña (`rating` de 1 a 5 y `comment`) | Sí |
| GET | `/api/v1/profile` | Datos del usuario autenticado | Sí |
| GET | `/api/v1/orders` | Inscripciones del usuario autenticado | Sí |
| POST | `/api/v1/orders` | Inscribe al usuario a un curso (`course_id`) y le envía un email de confirmación | Sí |

Reglas de negocio:

- Solo se puede reseñar un curso estando inscripto (con una inscripción que no esté cancelada) y una sola vez.
- La reseña siempre se asocia al usuario del token.

Errores: se responde con el código HTTP correspondiente (`401` sin token o con credenciales inválidas, `403` si no está inscripto, `404` si el recurso no existe, `422` si falla una validación) y un JSON con `error` o `errors`.

### Ejemplo de uso

```bash
# 1. Login (devuelve el token)
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ana@test.com","password":"123456"}'

# 2. Listar cursos
curl http://localhost:3000/api/v1/courses

# 3. Reseñar el curso 1 (reemplazar TOKEN)
curl -X POST http://localhost:3000/api/v1/courses/1/reviews \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"rating":4,"comment":"Muy buen curso"}'
```

## Emails

Al inscribirse a un curso se envía un email de confirmación con Action Mailer. En desarrollo se usa `letter_opener`, que abre el mensaje en el navegador en lugar de enviarlo.

## Tests

```bash
bin/rails db:test:prepare
bin/rails test
```

La suite tiene 126 tests (Minitest):

- Modelos: validaciones, asociaciones y borrado en cascada (48).
- Mailer: destinatario, asunto y contenido (4).
- Back office: acceso, login y CRUD de cada sección (41).
- API: autenticación, cursos, inscripciones y reseñas (33).

## Calidad y seguridad

```bash
bin/rubocop
bin/brakeman
bin/bundler-audit
```

Los tres se ejecutan también en cada pull request con GitHub Actions (`.github/workflows/ci.yml`).

## Tecnologías

Ruby 3.4, Rails 8.1, SQLite, Active Storage, Action Mailer, Minitest, Rubocop, Brakeman y bundler-audit.
