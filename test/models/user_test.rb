require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "es válido con datos correctos" do
    user = User.new(name: "Test", email: "test@test.com", password: "123456", role: "alumno")
    assert user.valid?
  end

  test "no es válido sin nombre" do
    user = User.new(email: "test@test.com", password: "123456", role: "alumno")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :name
  end

  test "no es válido sin email" do
    user = User.new(name: "Test", password: "123456", role: "alumno")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "no es válido con un email mal formado" do
    user = User.new(name: "Test", email: "no-es-un-email", password: "123456", role: "alumno")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "no es válido con un email repetido" do
    create_user(email: "repetido@test.com")
    user = User.new(name: "Otro", email: "repetido@test.com", password: "123456", role: "alumno")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "no es válido sin contraseña" do
    user = User.new(name: "Test", email: "test@test.com", role: "alumno")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :password
  end

  test "no es válido sin rol" do
    user = User.new(name: "Test", email: "test@test.com", password: "123456")
    assert_not user.valid?
    assert_includes user.errors.attribute_names, :role
  end

  test "no acepta un rol inexistente" do
    assert_raises(ArgumentError) { User.new(role: "superusuario") }
  end

  test "authenticate acepta la contraseña correcta y rechaza la incorrecta" do
    user = create_user(password: "secreta1")
    assert user.authenticate("secreta1")
    assert_not user.authenticate("otra-clave")
  end

  test "los métodos del enum identifican el rol" do
    admin = create_user(role: "admin")
    assert admin.admin?
    assert_not admin.alumno?
    assert_not admin.profesor?
  end

  test "al eliminar un alumno se eliminan sus inscripciones y reseñas" do
    alumno = create_user
    course = create_course
    create_enrollment(user: alumno, course: course)
    create_review(user: alumno, course: course)

    assert_difference [ "Enrollment.count", "Review.count" ], -1 do
      alumno.destroy
    end
  end

  test "al eliminar un profesor se eliminan sus cursos" do
    profesor = create_user(role: "profesor")
    create_course(professor: profesor)

    assert_difference "Course.count", -1 do
      profesor.destroy
    end
  end
end
