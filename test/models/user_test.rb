require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "es válido con datos correctos" do
    user = User.new(name: "Test", email: "test@test.com", password: "123456", role: "alumno")
    assert user.valid?
  end

  test "no es válido sin email" do
    user = User.new(name: "Test", password: "123456", role: "alumno")
    assert_not user.valid?
  end

  test "no es válido con email duplicado" do
    User.create(name: "Uno", email: "dup@test.com", password: "123456", role: "alumno")
    user2 = User.new(name: "Dos", email: "dup@test.com", password: "123456", role: "alumno")
    assert_not user2.valid?
  end
end
