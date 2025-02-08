class Act < ApplicationRecord
  belongs_to :client
  belongs_to :template
  has_one_attached :file

  validates :file, presence: true
end
