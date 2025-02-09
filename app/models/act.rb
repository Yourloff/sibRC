class Act < ApplicationRecord
  belongs_to :client
  belongs_to :template
  has_one_attached :file, service: :minio_acts

  validates :file, presence: true
end
