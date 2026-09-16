# Clear existing data
Review.destroy_all
Enrollment.destroy_all
Lesson.destroy_all
Course.destroy_all
Category.destroy_all
User.destroy_all

# Create Users
admin = User.create!(name: "Admin", email: "admin@test.com", password: "password", role: :admin)
profe = User.create!(name: "Profe Ruby", email: "profe@test.com", password: "password", role: :teacher)

# Create Categories
cat1 = Category.create!(name: "Programación", description: "Cursos de desarrollo de software")
cat2 = Category.create!(name: "Diseño", description: "Cursos de UI/UX")

# Create Courses
Course.create!(title: "Ruby on Rails 101", description: "Aprende backend desde cero", price: 49.99, category: cat1, teacher: profe)
Course.create!(title: "Figma para Devs", description: "Diseño de Wireframes", price: 29.99, category: cat2, teacher: profe)