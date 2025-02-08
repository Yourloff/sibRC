class Users::RegistrationsController < Devise::RegistrationsController
  def build_resource(*args)
    super
    resource.type = "Worker"
  end
end
