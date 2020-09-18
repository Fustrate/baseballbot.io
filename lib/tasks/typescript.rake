# frozen_string_literal: true

FILE_TEMPLATE = <<~TYPESCRIPT
  declare module 'js/routes' {
    export type RouteComponent = string | number | { id?: number};

    export type RouteOptionsComponent = string | number | string[] | number[] | boolean;

    export type RouteOptions = {
      format?: string;
      [s: string]: RouteOptionsComponent;
    };

    %<routes>s
  }
TYPESCRIPT

ROUTE_TEMPLATE = <<~TYPESCRIPT.strip
  export function %<name>sPath(%<parameters>s): string;
TYPESCRIPT

class RouteDefinitionBuilder
  LAST_OPTIONS_KEY = 'options'

  def generate
    @typescript_definitions = {}

    # Ensure routes are loaded. If they're not, load them.
    application.reload_routes!

    generate_information

    definitions = @typescript_definitions.map do |name, parameters|
      format(ROUTE_TEMPLATE, name: name, parameters: parameters)
    end

    format(
      FILE_TEMPLATE,
      routes: definitions.join("\n  ")
    )
  end

  def generate!
    # Some libraries like Devise do not yet loaded their routes so we will wait
    # until initialization process finish
    # https://github.com/railsware/js-routes/issues/7
    Rails.configuration.after_initialize do
      file_path = Rails.root.join('app/frontend/routes.d.ts')

      content = generate

      # We don't need to rewrite file if it already exist and have same content.
      # It helps asset pipeline or webpack understand that file wasn't changed.
      next if File.exist?(file_path) && File.read(file_path) == content

      File.write(file_path, content)
    end
  end

  protected

  def application
    Rails.application
  end

  def named_routes
    application.routes.named_routes.to_a
  end

  def generate_information
    named_routes.sort_by(&:first).flat_map do |_, route|
      build_js(route)

      mounted_app_routes(route)
    end
  end

  def mounted_app_routes(route)
    rails_engine_app = get_app_from_route(route)

    some_conditional = rails_engine_app.respond_to?(:superclass) &&
                       rails_engine_app.superclass == Rails::Engine &&
                       !route.path.anchored

    return [] unless some_conditional

    rails_engine_app.routes.named_routes.map do |_, engine_route|
      build_js(engine_route, route)
    end
  end

  def get_app_from_route(route)
    # rails engine in Rails 4.2 use additional
    # ActionDispatch::Routing::Mapper::Constraints, which contain app
    if route.app.respond_to?(:app) && route.app.respond_to?(:constraints)
      route.app.app
    else
      route.app
    end
  end

  def build_js(route, parent_route = nil)
    name = [parent_route.try(:name), route.name].compact.join('_')

    @typescript_definitions[camel_case(name)] = route_arguments(route)
  end

  def route_arguments(route)
    parameters = route.required_parts.map do |part|
      "#{camel_case(part)}: RouteComponent"
    end

    parameters << route_options(route)

    parameters.join(', ')
  end

  def route_options(route)
    non_required_parts = route.parts - route.required_parts

    return "#{LAST_OPTIONS_KEY}?: RouteOptions" if non_required_parts == %i[format]

    options = non_required_parts.sort.map do |part|
      "#{camel_case(part)}?: RouteOptionsComponent"
    end

    options << '[s: string]: RouteOptionsComponent'

    "#{LAST_OPTIONS_KEY}?: { #{options.join('; ')} }"
  end

  def camel_case(name)
    name.to_s.camelize(:lower)
  end
end

namespace :typescript do
  desc 'Generate typescript definitions for routes from docs/routes.txt'
  task(routes: :environment) do
    RouteDefinitionBuilder.new.generate!
  end
end
