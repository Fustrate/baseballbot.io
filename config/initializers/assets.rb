# frozen_string_literal: true

# Propshaft doesn't include files in node_module by default
Rails.application.config.assets.paths << Rails.root.join('node_modules/@fortawesome/fontawesome-pro/webfonts')
