class Template < ApplicationRecord
  has_one_attached :file
  has_one_attached :metadata

  validates :title, presence: true
end
