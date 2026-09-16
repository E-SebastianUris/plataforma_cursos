class Course < ApplicationRecord
  belongs_to :category
  belongs_to :teacher, class_name: 'User', foreign_key: 'user_id'

  has_many :lessons, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :title, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end