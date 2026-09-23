class Course < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_one_attached :cover_image
  has_many :lessons, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
