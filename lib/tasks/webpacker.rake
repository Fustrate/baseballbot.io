# frozen_string_literal: true

# Copyright (c) 2020 Valencia Management Group
# All rights reserved.

require 'js-routes'

namespace :webpacker do
  desc 'Regenerate assets for Webpacker'
  task(regenerate_assets: :environment) do
    I18n::JS.export

    JsRoutes.generate!(
      'app/frontend/javascript/routes.js',
      namespace: 'Routes',
      camel_case: true
    )

    output = Rails.root.join('docs/routes.txt')

    system "rails routes > #{output}"
  end
end
