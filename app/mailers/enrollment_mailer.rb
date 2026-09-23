class EnrollmentMailer < ApplicationMailer
  def confirmation(enrollment)
    @enrollment = enrollment
    @user = enrollment.user
    @course = enrollment.course

    mail(to: @user.email, subject: "Confirmación de inscripción a #{@course.title}")
  end
end
