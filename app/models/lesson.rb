class Lesson < ApplicationRecord
  belongs_to :course

  validates :title, presence: true
  validates :content, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
end
