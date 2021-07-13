# frozen_string_literal: true

require 'js-routes'

namespace :webpacker do
  desc 'Regenerate assets for Webpacker'
  task(regenerate_assets: :environment) do
    I18n::JS.export

    JsRoutes.generate! 'app/packs/javascript/routes.js', camel_case: true, documentation: false

    system "rails routes > #{Rails.root.join('docs/routes.txt')}"

    Rake::Task['typescript:routes'].invoke
  end
end
