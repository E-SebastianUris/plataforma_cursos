# Plataforma de Cursos — Backend (API & Back Office)

Trabajo Práctico N°2 de Programación IV (Integración Back-end + Front-end).
- **Modalidad**: Individual.
- **Autor del Backend original**: Sebastian Uris (TP1).
- **Frontend asociado**: `plataforma_cursos_frontend` (React + Vite).
- **Contrato detallado de la API**: Ver [docs/API.md](docs/API.md).

Tiene dos partes integradas:
- **Back office** de administración con Rails tradicional (controllers, vistas ERB, formularios y Active Record).
- **API REST JSON** versionada (`/api/v1`) consumida por el front-end en React.

---

## 1. Requisitos y Versiones

- **Ruby**: `3.4.10`
- **Rails**: `8.1.3.1`
- **Base de datos**: SQLite 3
- **Gemas clave**: `rack-cors` (CORS para frontend), `bcrypt` (autenticación), `propshaft`, `image_processing` (Active Storage).

---

## 2. Variables de Entorno

| Variable | Descripción | Valor por defecto (desarrollo) |
|---|---|---|
| `FRONT_ORIGIN` | Origen permitido por CORS para solicitudes del front | `http://localhost:5173` |
| `RAILS_MASTER_KEY` | Clave maestra para credenciales cifradas (producción) | En `config/master.key` |

---

## 3. Instalación y Ejecución Local

```powershell
# 1. Clonar e ingresar a la carpeta
cd C:\dev\tp2\plataforma_cursos

# 2. Instalar gemas
bundle install

# 3. Preparar la base y cargar datos de demostración
ruby bin/rails db:setup

# 4. Iniciar el servidor
ruby bin/rails server
```
La aplicación queda escuchando en `http://localhost:3000`.

---

## 4. Credenciales de Prueba (Demo)

Cargadas automáticamente por `db/seeds.rb`:

| Rol | Email | Contraseña | Acceso |
|---|---|---|---|
| Admin | `admin@test.com` | `admin123` | Back office (`/login`) |
| Profesor | `profesor@test.com` | `123456` | Creador de cursos en back office |
| Alumno | `juan@test.com` | `123456` | API / Frontend (inscripto a Web) |
| Alumno | `ana@test.com` | `123456` | API / Frontend (inscripto a Datos) |

---

## 5. Back Office

Disponible en `http://localhost:3000/login` (solo administradores).
- `/admin/categories`: CRUD de categorías.
- `/admin/courses`: CRUD de cursos con carga de portadas (Active Storage).
- `/admin/lessons`: CRUD de lecciones ordenadas por posición.
- `/admin/users`: Gestión de usuarios (rol alumno, profesor o admin).
- `/admin/reviews`: Moderación y eliminación de reseñas.

---

## 6. API REST (`/api/v1`)

Resumen de endpoints (contrato completo con esquemas y ejemplos en [docs/API.md](docs/API.md)):

| Método | Endpoint | Acceso | Descripción |
|---|---|---|---|
| POST | `/api/v1/login` | Público | Autenticación de usuario; devuelve `token` y datos |
| POST | `/api/v1/register` | Público | Registro de alumno con auto-login |
| DELETE | `/api/v1/logout` | Token | Invalida el token actual del usuario |
| GET | `/api/v1/profile` | Token | Perfil del usuario en sesión |
| PUT | `/api/v1/profile` | Token | Actualización de nombre, correo y contraseña |
| GET | `/api/v1/categories` | Público | Listado de categorías `[{id, name}]` |
| GET | `/api/v1/courses` | Público | Listado con filtros `?category_id=` y `?search=`, precio float y URL de portada |
| GET | `/api/v1/courses/:id` | Público | Detalle con lecciones (contenido visible solo para inscriptos activos) |
| GET | `/api/v1/courses/:course_id/reviews` | Público | Reseñas y calificación promedio |
| POST | `/api/v1/courses/:course_id/reviews` | Token | Crear reseña (solo alumnos inscriptos) |
| GET | `/api/v1/orders` | Token | Mis inscripciones con datos del curso |
| POST | `/api/v1/orders` | Token | Inscribirse a un curso (estado inicial `pendiente`) y envía email |
| DELETE | `/api/v1/orders/:id` | Token | Cancelar inscripción propia |

---

## 7. Tests y Calidad de Código

```powershell
# Ejecutar suite de pruebas (139 tests pasando, 0 fallas)
ruby bin/rails test

# Linter de estilo Rails Omakase
ruby bin/rubocop

# Análisis de vulnerabilidades y seguridad
ruby bin/brakeman -q

# Auditoría de dependencias
ruby bin/bundler-audit
```

---

## 8. Despliegue en Producción (Render)

- **Servicio Web**: Docker (utiliza el `Dockerfile` oficial de Rails 8).
- **Arranque del contenedor**: `bin/docker-entrypoint` ejecuta automáticamente `rails db:prepare` y `rails db:seed` en cada inicio.
- **Advertencia Render Free Tier**: El plan gratuito de Render suspende el contenedor tras minutos de inactividad (el primer request puede demorar ~50 segundos en despertar) y no cuenta con disco persistente (los datos se re-siembran de forma limpia e idempotente en cada reinicio).
- **Variables requeridas en Render**:
  - `RAILS_MASTER_KEY`: contenido de tu `config/master.key`.
  - `FRONT_ORIGIN`: URL pública del frontend (ej. `https://plataforma-cursos-frontend.vercel.app`).
