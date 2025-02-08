class Client < User
  validates :first_name, :middle_name, :last_name, :inn, :kpp, :customer, :address, :phone, presence: true
end
