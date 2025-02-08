class Worker < User
  validates :gender, :position, :birth_date, presence: true
end
