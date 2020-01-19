# frozen_string_literal: true

Rails.application.config.i18n.enforce_available_locales = true

Rails.application.config.i18n
  .load_path += Dir[Rails.root.join('config/locales/**/*.yml')]

# https://github.com/rails/rails/commit/da28edf9baf0bd83b5308564bdcd8f4673b492bd
if Rails::VERSION::STRING < '6.0.3'
  module I18n
    class Config
      def eager_load_paths
        []
      end
    end
  end
end
