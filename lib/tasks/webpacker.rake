# frozen_string_literal: true

require 'js-routes'

namespace :js do
  desc 'Regenerate assets for front end'
  task(regenerate_assets: :environment) do
    JsRoutes.generate! Rails.root.join('app/frontend/javascript/routes.js'), camel_case: true, documentation: false, module_type: 'CJS'
    JsRoutes.definitions! Rails.root.join('app/frontend/javascript/routes.d.ts'), camel_case: true

    system "rails routes > #{Rails.root.join('docs/routes.txt')}"
  end
end
