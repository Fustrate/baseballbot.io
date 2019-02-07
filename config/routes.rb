# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#home'

  Dir[Rails.root.join('config', 'routes', '*.rb')].sort.each do |file|
    instance_eval File.read(file)
  end
end
