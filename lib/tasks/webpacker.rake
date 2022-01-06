# frozen_string_literal: true

require 'js-routes'

namespace :webpacker do
  desc 'Regenerate assets for Webpacker'
  task(regenerate_assets: :environment) do
    JsRoutes.generate! Rails.root.join('app/packs/javascript/routes.js'), camel_case: true, documentation: false
    JsRoutes.definitions! Rails.root.join('app/packs/javascript/routes.d.ts'), camel_case: true

    system "rails routes > #{Rails.root.join('docs/routes.txt')}"
  end
end
