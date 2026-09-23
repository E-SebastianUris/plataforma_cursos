require "test_helper"

class EnrollmentMailerTest < ActionMailer::TestCase
  test "confirmation" do
    prof = User.create!(name: "Prof Mailer", email: "prof_mailer@test.com", password: "123456", role: "profesor")
    alumno = User.create!(name: "Alumno Mailer", email: "alumno_mailer@test.com", password: "123456", role: "alumno")
    category = Category.create!(name: "Categoria Mailer")
    course = Course.create!(title: "Curso Mailer", description: "Desc", price: 100, category: category, user: prof)
    enrollment = Enrollment.create!(user: alumno, course: course, status: :pendiente)

    email = EnrollmentMailer.confirmation(enrollment)

    assert_equal [ alumno.email ], email.to
    assert_equal "Confirmación de inscripción a #{course.title}", email.subject
  end
end
