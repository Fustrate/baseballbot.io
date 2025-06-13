# frozen_string_literal: true

Rails.application.config.i18n.enforce_available_locales = true

Rails.application.config.i18n.load_path += Rails.root.glob('config/locales/**/*.yml')
