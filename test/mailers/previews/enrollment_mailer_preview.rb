# Preview all emails at http://localhost:3000/rails/mailers/enrollment_mailer
class EnrollmentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/enrollment_mailer/confirmation
  def confirmation
    EnrollmentMailer.confirmation
  end
end
