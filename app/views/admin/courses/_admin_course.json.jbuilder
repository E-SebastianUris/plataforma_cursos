json.extract! admin_course, :id, :title, :description, :price, :category_id, :user_id, :created_at, :updated_at
json.url admin_course_url(admin_course, format: :json)
