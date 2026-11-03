# Contrato de la API REST (`/api/v1`)

## 1. Información General

- **URL Base local**: `http://localhost:3000/api/v1`
- **URL Base producción (Render)**: `https://<tu-app>.onrender.com/api/v1`
- **Formato**: Todas las peticiones con cuerpo y las respuestas usan `application/json; charset=utf-8`.
- **CORS**: Habilitado mediante `rack-cors`. El origen permitido se configura mediante la variable de entorno `FRONT_ORIGIN` (por defecto `http://localhost:5173`).

---

## 2. Autenticación y Autorización

- **Esquema**: Token en encabezado HTTP `Authorization: Bearer <token>`.
- **Obtención del token**: Mediante `POST /api/v1/login` o `POST /api/v1/register`.
- **Cierre de sesión / Invalidación**: `DELETE /api/v1/logout` pone el `auth_token` del usuario en `null`.
- **Rutas públicas**: `POST /login`, `POST /register`, `GET /courses`, `GET /courses/:id`, `GET /courses/:course_id/reviews`, `GET /categories`.
- **Rutas protegidas**: Requieren `Authorization: Bearer <token>`.
  - Si falta o el token es inválido: `401 Unauthorized` con `{"error": "No autorizado"}`.
  - Si una operación requiere que el alumno esté inscripto (ej. reseñar curso): `403 Forbidden` con `{"error": "Debés estar inscripto en el curso para dejar una reseña"}`.

---

## 3. Formato Estándar de Errores

- **401 No autorizado**:
  ```json
  { "error": "No autorizado" }
  ```
- **403 Prohibido**:
  ```json
  { "error": "Debés estar inscripto en el curso para dejar una reseña" }
  ```
- **404 No encontrado**:
  ```json
  { "error": "Curso no encontrado" }
  ```
- **422 Error de validación**:
  ```json
  { "errors": ["Email ya ha sido registrado", "Password es demasiado corto"] }
  ```

---

## 4. Endpoints

### 4.1. `POST /login`
Inicia sesión con credenciales y devuelve el token de autenticación.
- **Acceso**: Público.
- **Parámetros (JSON body)**:
  - `email` (string, obligatorio)
  - `password` (string, obligatorio)
- **Respuesta 200 OK**:
  ```json
  {
    "token": "a1b2c3d4e5f6...",
    "user": {
      "id": 1,
      "name": "Juan Alumno",
      "role": "alumno"
    }
  }
  ```
- **Error 401 Unauthorized**:
  ```json
  { "error": "Credenciales inválidas" }
  ```

---

### 4.2. `POST /register`
Registra un nuevo usuario con rol forzado `alumno`.
- **Acceso**: Público.
- **Parámetros (JSON body)**:
  - `name` (string, obligatorio)
  - `email` (string, obligatorio, formato email válido, único)
  - `password` (string, obligatorio, mín. 6 caracteres)
  - `password_confirmation` (string, obligatorio, igual a `password`)
- **Respuesta 201 Created**:
  ```json
  {
    "token": "f7e8d9c0...",
    "user": {
      "id": 5,
      "name": "Pedro Alumno",
      "role": "alumno"
    }
  }
  ```
- **Error 422 Unprocessable Entity**:
  ```json
  { "errors": ["Email ya está en uso", "Password confirmation no coincide"] }
  ```

---

### 4.3. `DELETE /logout`
Invalida el token del usuario actual.
- **Acceso**: Protegido (`Authorization: Bearer <token>`).
- **Respuesta 204 No Content**.

---

### 4.4. `GET /profile`
Devuelve los datos del usuario en sesión.
- **Acceso**: Protegido.
- **Respuesta 200 OK**:
  ```json
  {
    "id": 1,
    "name": "Juan Alumno",
    "email": "juan@test.com",
    "role": "alumno"
  }
  ```

---

### 4.5. `PUT /profile`
Actualiza nombre, email o contraseña del usuario en sesión.
- **Acceso**: Protegido.
- **Parámetros (JSON body)**:
  - `name` (string, opcional)
  - `email` (string, opcional)
  - `password` (string, opcional)
  - `password_confirmation` (string, opcional)
- **Respuesta 200 OK**:
  ```json
  {
    "id": 1,
    "name": "Juan Carlos Alumno",
    "email": "juan.carlos@test.com",
    "role": "alumno"
  }
  ```
- **Error 422 Unprocessable Entity**:
  ```json
  { "errors": ["Email es inválido"] }
  ```

---

### 4.6. `GET /categories`
Lista todas las categorías disponibles ordenadas alfabéticamente.
- **Acceso**: Público.
- **Respuesta 200 OK**:
  ```json
  [
    { "id": 1, "name": "Ciencia de Datos" },
    { "id": 2, "name": "Desarrollo Web" }
  ]
  ```

---

### 4.7. `GET /courses`
Lista los cursos disponibles. Permite filtros de categoría y búsqueda textual.
- **Acceso**: Público.
- **Parámetros de Query (opcionales)**:
  - `category_id` (integer): filtra por id de categoría.
  - `search` (string): filtra por coincidencia parcial en título o descripción.
- **Respuesta 200 OK**:
  ```json
  [
    {
      "id": 1,
      "title": "Desarrollo Web desde Cero",
      "description": "Aprendé HTML, CSS y JavaScript...",
      "price": 15000.0,
      "cover_image_url": "http://localhost:3000/rails/active_storage/blobs/...",
      "category": { "id": 2, "name": "Desarrollo Web" },
      "user": { "id": 2, "name": "Carlos Docente" }
    }
  ]
  ```

---

### 4.8. `GET /courses/:id`
Devuelve el detalle de un curso con sus lecciones.
- **Acceso**: Público. Si se envía token de un alumno con inscripción activa, cada lección incluirá su atributo `content`; en caso contrario `content` es `null`.
- **Respuesta 200 OK**:
  ```json
  {
    "id": 1,
    "title": "Desarrollo Web desde Cero",
    "description": "...",
    "price": 15000.0,
    "cover_image_url": "...",
    "category": { "id": 2, "name": "Desarrollo Web" },
    "user": { "id": 2, "name": "Carlos Docente" },
    "lessons": [
      {
        "id": 1,
        "title": "Introducción a HTML",
        "position": 1,
        "content": "HTML es el lenguaje de marcado..." 
      }
    ]
  }
  ```
- **Error 404 Not Found**:
  ```json
  { "error": "Curso no encontrado" }
  ```

---

### 4.9. `GET /courses/:course_id/reviews`
Devuelve el promedio de calificación y la lista de reseñas de un curso.
- **Acceso**: Público.
- **Respuesta 200 OK**:
  ```json
  {
    "average_rating": 5.0,
    "reviews_count": 1,
    "reviews": [
      {
        "id": 1,
        "rating": 5,
        "comment": "Excelente curso...",
        "created_at": "2026-11-01T15:30:00.000Z",
        "user": { "id": 3, "name": "Juan Alumno" }
      }
    ]
  }
  ```

---

### 4.10. `POST /courses/:course_id/reviews`
Crea una reseña para un curso.
- **Acceso**: Protegido. El usuario debe estar inscripto (estado no cancelado) y no tener una reseña previa.
- **Parámetros (JSON body)**:
  - `rating` (integer 1..5, obligatorio)
  - `comment` (string, obligatorio)
- **Respuesta 201 Created**:
  ```json
  {
    "id": 2,
    "rating": 5,
    "comment": "Muy buenas explicaciones",
    "created_at": "2026-11-03T11:00:00.000Z"
  }
  ```
- **Error 403 Forbidden**:
  ```json
  { "error": "Debés estar inscripto en el curso para dejar una reseña" }
  ```
- **Error 422 Unprocessable Entity**:
  ```json
  { "errors": ["User ya calificó este curso", "Rating debe estar entre 1 y 5"] }
  ```

---

### 4.11. `GET /orders`
Lista las inscripciones del usuario autenticado.
- **Acceso**: Protegido.
- **Respuesta 200 OK**:
  ```json
  [
    {
      "id": 1,
      "user_id": 3,
      "course_id": 1,
      "status": "activa",
      "created_at": "2026-11-01T10:00:00.000Z",
      "course": {
        "id": 1,
        "title": "Desarrollo Web desde Cero",
        "price": "15000.0"
      }
    }
  ]
  ```

---

### 4.12. `POST /orders`
Inscribe al usuario autenticado en un curso (estado inicial `pendiente`). Envía email de confirmación en segundo plano.
- **Acceso**: Protegido.
- **Parámetros (JSON body)**:
  - `course_id` (integer, obligatorio)
- **Respuesta 201 Created**:
  ```json
  {
    "id": 3,
    "user_id": 4,
    "course_id": 1,
    "status": "pendiente",
    "created_at": "2026-11-03T11:20:00.000Z"
  }
  ```
- **Error 422 Unprocessable Entity**:
  ```json
  { "errors": ["User ya está inscripto en este curso"] }
  ```

---

### 4.13. `DELETE /orders/:id`
Cancela la inscripción propia del usuario.
- **Acceso**: Protegido.
- **Respuesta 204 No Content**.
- **Error 404 Not Found**: Si la inscripción no existe o pertenece a otro usuario.
