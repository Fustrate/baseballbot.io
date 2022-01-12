# frozen_string_literal: true

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0.1'

Rails.application.config.assets.paths << Rails.root.join('node_modules/@fortawesome/fontawesome-pro/webfonts')
