# frozen_string_literal: true

Rails.application.config.i18n.enforce_available_locales = true

Rails.application.config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml')]
