class Client < User
  validates :first_name, :middle_name, :last_name, :inn, :kpp, :customer, :address, :phone, presence: true
  validates :email, presence: true
  validates :password, absence: true

  def password_required?
    false
  end
end
