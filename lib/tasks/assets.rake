# frozen_string_literal: true

require 'js-routes'

namespace :assets do
  desc 'Regenerate assets for the front end'
  task(regenerate: :environment) do
    js_folder = Rails.root.join('app/frontend/javascript')

    js_routes_options = { camel_case: true, documentation: false, exclude: [/api|conductor/i] }

    JsRoutes.generate! js_folder.join('routes.js'), module_type: 'CJS', **js_routes_options
    JsRoutes.definitions! js_folder.join('routes.d.ts'), **js_routes_options

    routes = ActionDispatch::Routing::RoutesInspector.new(Rails.application.routes.routes)
      .format(ActionDispatch::Routing::ConsoleFormatter::Expanded.new)
      .gsub(/^-.*/, '')
      .gsub(/\nSource.*/, '')

    Rails.root.join('docs/routes.txt').write("#{routes}\n")
  end
end
