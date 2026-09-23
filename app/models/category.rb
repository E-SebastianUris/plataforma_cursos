class Category < ApplicationRecord
  has_many :courses, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
