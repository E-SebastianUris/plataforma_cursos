# Seeds idempotentes — se corren en cada arranque en Render (sin disco persistente)

# ── Usuarios ──────────────────────────────────────────────────────────────────
admin = User.find_or_create_by!(email: "admin@test.com") do |u|
  u.name = "Administrador"
  u.password = "admin123"
  u.role = :admin
end

profesor = User.find_or_create_by!(email: "profesor@test.com") do |u|
  u.name = "Carlos Docente"
  u.password = "123456"
  u.role = :profesor
end

juan = User.find_or_create_by!(email: "juan@test.com") do |u|
  u.name = "Juan Alumno"
  u.password = "123456"
  u.role = :alumno
end

ana = User.find_or_create_by!(email: "ana@test.com") do |u|
  u.name = "Ana Alumna"
  u.password = "123456"
  u.role = :alumno
end

# ── Categorías ────────────────────────────────────────────────────────────────
web = Category.find_or_create_by!(name: "Desarrollo Web") do |c|
  c.description = "HTML, CSS, JavaScript, frameworks y más"
end

data = Category.find_or_create_by!(name: "Ciencia de Datos") do |c|
  c.description = "Python, análisis de datos y machine learning"
end

# ── Cursos ────────────────────────────────────────────────────────────────────
curso_web = Course.find_or_create_by!(title: "Desarrollo Web desde Cero") do |c|
  c.description = "Aprendé HTML, CSS y JavaScript desde los fundamentos hasta crear sitios web completos y responsivos."
  c.price = 15000.0
  c.category = web
  c.user = profesor
end

unless curso_web.cover_image.attached?
  cover_web_path = Rails.root.join("db/seeds/cover_web.svg")
  curso_web.cover_image.attach(
    io: File.open(cover_web_path),
    filename: "cover_web.svg",
    content_type: "image/svg+xml"
  )
end

curso_data = Course.find_or_create_by!(title: "Introducción a Ciencia de Datos") do |c|
  c.description = "Explorá el mundo del análisis de datos con Python, Pandas y conceptos básicos de machine learning."
  c.price = 18500.0
  c.category = data
  c.user = profesor
end

unless curso_data.cover_image.attached?
  cover_data_path = Rails.root.join("db/seeds/cover_data.svg")
  curso_data.cover_image.attach(
    io: File.open(cover_data_path),
    filename: "cover_data.svg",
    content_type: "image/svg+xml"
  )
end

# ── Lecciones ────────────────────────────────────────────────────────────────
[
  { title: "Introducción a HTML", position: 1, content: "HTML es el lenguaje de marcado de la web. En esta lección aprenderás la estructura básica de un documento HTML, las etiquetas principales y cómo crear tu primera página." },
  { title: "CSS: Estilos y Layout", position: 2, content: "CSS (Cascading Style Sheets) permite dar estilo visual a tus páginas. Aprenderás selectores, propiedades, el modelo de caja (box model) y técnicas modernas de layout con Flexbox y Grid." },
  { title: "JavaScript Esencial", position: 3, content: "JavaScript es el lenguaje de programación de la web. Aprenderás variables, funciones, eventos del DOM y cómo hacer tu página interactiva." }
].each do |attrs|
  Lesson.find_or_create_by!(course: curso_web, position: attrs[:position]) do |l|
    l.title = attrs[:title]
    l.content = attrs[:content]
  end
end

[
  { title: "¿Qué es la Ciencia de Datos?", position: 1, content: "La ciencia de datos combina estadística, programación y dominio del negocio. En esta lección veremos el ciclo de vida de un proyecto de datos y herramientas del ecosistema Python." },
  { title: "Python para Datos", position: 2, content: "Aprenderás las bases de Python orientadas al análisis: listas, diccionarios, comprensiones, y las bibliotecas NumPy y Pandas para manipulación de datos." },
  { title: "Visualización con Matplotlib", position: 3, content: "Comunicar hallazgos es clave. Veremos cómo crear gráficos de barras, líneas, dispersión e histogramas con Matplotlib y Seaborn." }
].each do |attrs|
  Lesson.find_or_create_by!(course: curso_data, position: attrs[:position]) do |l|
    l.title = attrs[:title]
    l.content = attrs[:content]
  end
end

# ── Inscripciones ────────────────────────────────────────────────────────────
enrollment_juan = Enrollment.find_or_create_by!(user: juan, course: curso_web) do |e|
  e.status = :activa
end

Enrollment.find_or_create_by!(user: ana, course: curso_data) do |e|
  e.status = :activa
end

# ── Reseñas ───────────────────────────────────────────────────────────────────
Review.find_or_create_by!(user: juan, course: curso_web) do |r|
  r.rating = 5
  r.comment = "Excelente curso, muy bien explicado y con ejemplos prácticos. Lo recomiendo a todos los que quieran iniciarse en el desarrollo web."
end

puts "Seeds completados: #{User.count} usuarios, #{Category.count} categorías, #{Course.count} cursos, #{Lesson.count} lecciones, #{Enrollment.count} inscripciones, #{Review.count} reseñas."
