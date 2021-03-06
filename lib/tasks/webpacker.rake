# frozen_string_literal: true

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

    Rake::Task['typescript:routes'].invoke
  end
end
