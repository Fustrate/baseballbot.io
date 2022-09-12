# frozen_string_literal: true

require 'js-routes'

namespace :assets do
  desc 'Regenerate assets for the front end'
  task(regenerate: :environment) do
    js_folder = Rails.root.join('app/frontend/javascript')

    JsRoutes.generate! js_folder.join('routes.js'), camel_case: true, documentation: false, module_type: 'CJS'
    JsRoutes.definitions! js_folder.join('routes.d.ts'), camel_case: true

    system %(rails routes -E | sed -E "s/--.*$//g" > #{Rails.root.join('docs/routes.txt')})
  end
end
