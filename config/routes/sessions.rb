# frozen_string_literal: true

controller :sessions do
  get  :log_in
  post :log_in, action: :process_log_in

  delete :sign_out
end
