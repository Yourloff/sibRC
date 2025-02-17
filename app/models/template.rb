class Template < ApplicationRecord
  has_one_attached :file, service: :minio_templates, dependent: :destroy
  has_one_attached :metadata, service: :minio_templates, dependent: :destroy

  validates :title, presence: true
end
