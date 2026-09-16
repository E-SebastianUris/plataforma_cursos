require "test_helper"

class Admin::CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_course = admin_courses(:one)
  end

  test "should get index" do
    get admin_courses_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_course_url
    assert_response :success
  end

  test "should create admin_course" do
    assert_difference("Admin::Course.count") do
      post admin_courses_url, params: { admin_course: { category_id: @admin_course.category_id, description: @admin_course.description, price: @admin_course.price, title: @admin_course.title, user_id: @admin_course.user_id } }
    end

    assert_redirected_to admin_course_url(Admin::Course.last)
  end

  test "should show admin_course" do
    get admin_course_url(@admin_course)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_course_url(@admin_course)
    assert_response :success
  end

  test "should update admin_course" do
    patch admin_course_url(@admin_course), params: { admin_course: { category_id: @admin_course.category_id, description: @admin_course.description, price: @admin_course.price, title: @admin_course.title, user_id: @admin_course.user_id } }
    assert_redirected_to admin_course_url(@admin_course)
  end

  test "should destroy admin_course" do
    assert_difference("Admin::Course.count", -1) do
      delete admin_course_url(@admin_course)
    end

    assert_redirected_to admin_courses_url
  end
end
