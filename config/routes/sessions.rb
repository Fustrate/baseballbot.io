# frozen_string_literal: true

controller :sessions do
  get    :login,  action: :new
  post   :login,  action: :create
  delete :logout, action: :destroy
end
