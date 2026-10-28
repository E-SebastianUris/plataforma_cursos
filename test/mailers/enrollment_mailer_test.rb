require "test_helper"

class EnrollmentMailerTest < ActionMailer::TestCase
  setup do
    @alumno = create_user(name: "Ana Gomez")
    @course = create_course(title: "Rails desde cero", price: 1500)
    @enrollment = create_enrollment(user: @alumno, course: @course, status: :pendiente)
    @email = EnrollmentMailer.confirmation(@enrollment)
  end

  test "se envía al email del alumno con el asunto del curso" do
    assert_equal [ @alumno.email ], @email.to
    assert_equal "Confirmación de inscripción a Rails desde cero", @email.subject
  end

  test "el cuerpo HTML incluye el nombre del alumno, el curso, el estado y el precio" do
    html = @email.html_part.body.decoded

    assert_includes html, "Ana Gomez"
    assert_includes html, "Rails desde cero"
    assert_includes html, "pendiente"
    assert_includes html, "1500"
  end

  test "incluye también una versión en texto plano" do
    assert_includes @email.text_part.body.decoded, "Rails desde cero"
  end

  test "se entrega correctamente" do
    assert_emails 1 do
      @email.deliver_now
    end
  end
end
