# frozen_string_literal: true

# Copyright (c) Valencia Management Group
# All rights reserved.

module Asgard
  class RouteDumper
    EXCLUDE = /api|conductor/

    HEADER = <<~TYPESCRIPT
      import { buildRoute, type RouteOptions, type RequiredParameter, type OptionalParameter } from './routes.utils';
    TYPESCRIPT

    def dump!
      Rails.application.eager_load!

      @routes = Rails.application.routes.named_routes.to_a.filter_map do |(name, route)|
        process_route(name, route) unless EXCLUDE.match?(name)
      end

      routes_file.write "#{HEADER}\n#{@routes.sort.join}"

      regenerate_route_docs!
    end

    protected

    def routes_file = Rails.root.join('app/frontend/utilities/routes.ts')

    def process_route(name, route)
      required_parts = route.required_parts.map { _1.to_s.camelize(:lower) }
      optional_parts = (route.path.optional_names - %w[format]).map { _1.to_s.camelize(:lower) }

      <<~TYPESCRIPT
        export const #{name.to_s.camelize(:lower)}Path = (#{signature(required_parts, optional_parts)}) => buildRoute('#{camelized_spec(route)}', { #{[*required_parts, '...options'].join(', ')} });
      TYPESCRIPT
    end

    def camelized_spec(route) = route.path.spec.to_s.gsub(/:[a-z_]+/) { _1.camelize(:lower) }

    def options_type(optional_parts)
      return 'RouteOptions' if optional_parts.none?

      "{ #{optional_parts.map { "#{_1}?: OptionalParameter" }.join('; ')} } & RouteOptions"
    end

    def signature(required_parts, optional_parts)
      [
        *required_parts.map { "#{_1}: RequiredParameter" },
        "options: #{options_type(optional_parts)} = {}"
      ].join(', ')
    end

    def regenerate_route_docs!
      routes = ActionDispatch::Routing::RoutesInspector.new(Rails.application.routes.routes)
        .format(ActionDispatch::Routing::ConsoleFormatter::Expanded.new)
        .gsub(/^-.*/, '')
        .gsub(/\nSource.*/, '')

      Rails.root.join('docs/routes.txt').write("#{routes}\n")
    end
  end

  class ConstantDumper
    EXCLUDE_CONSTANTS = {
      'Attachment' => %w[THUMBNAIL]
    }.freeze

    def initialize(model_names = nil)
      @model_names = model_names&.split(',')

      @types = []
    end

    def dump!
      Rails.application.eager_load!

      ApplicationRecord.descendants.each { process_model(_1) }

      constants_file.write @types.sort.join("\n")
    end

    protected

    def constants_file = Rails.root.join('app/frontend/utilities/constants.ts')

    def skip_model?(model) = !model.table_exists? || model.abstract_class?

    def skip_constant?(model, name) = !name.match?(/\A[A-Z_]+\z/) || EXCLUDE_CONSTANTS[model]&.include?(name)

    def process_model(model)
      return if skip_model?(model)

      prefix = model.name.titleize.tr('/ ', '')

      model.constants(false).each { process_constant(model, _1, prefix) }
    end

    def process_constant(model, constant, prefix)
      constant_name = constant.to_s

      return if skip_constant?(prefix, constant_name)

      value = model.const_get(constant)

      case value
      when Array then process_array(prefix, constant_name, value, source_location(model, constant))
      when Hash then process_hash(prefix, constant_name, value, source_location(model, constant))
      end
    end

    def process_array(prefix, constant_name, value, location)
      return if value.none?

      type = "#{prefix}#{constant_name.downcase.singularize.camelize}"

      return process_array_of_hashes(prefix, constant_name, value, location) if value.first.is_a?(Hash)

      @types << <<~TYPESCRIPT
        // #{location}
        export type #{type} = #{value.map { "'#{_1}'" }.join(' | ')};
        export const #{prefix.downcase_first}#{constant_name.downcase.camelize}: #{type}[] = #{escape_value(value)} as const;
      TYPESCRIPT
    end

    def process_hash(prefix, constant_name, value, location)
      @types << <<~TYPESCRIPT
        // #{location}
        export const #{prefix.downcase_first}#{constant_name.downcase.camelize} = {
          #{hash_elements(value).join(",\n  ")},
        };
      TYPESCRIPT
    end

    def hash_elements(hash, camelize: false)
      hash.sort.map { |k, v| "#{camelize ? escape_key(k).camelize(:lower) : escape_key(k)}: #{escape_value(v)}" }
    end

    def process_array_of_hashes(prefix, constant_name, value, location)
      values = value.map { |hash| hash_elements(hash, camelize: true).join(', ') }

      # Exporting this `as const` causes problems when the value is used to satisfy a mutable interface.
      @types << <<~TYPESCRIPT
        // #{location}
        export const #{prefix.downcase_first}#{constant_name.downcase.camelize} = [
          { #{values.join(" },\n  { ")} },
        ];
      TYPESCRIPT
    end

    def escape_key(key) = key[/[: ]/] ? "'#{key}'" : key.to_s

    def escape_value(value)
      case value
      when String then "'#{value}'"
      when Numeric, TrueClass, FalseClass then value.to_s
      when Array then "[#{value.map { escape_value(_1) }.join(', ')}]"
      end
    end

    def source_location(model, constant) = model.const_source_location(constant).join(':').split('app/models/').last
  end
end

namespace :assets do
  desc 'Regenerate assets for the front end'
  task(regenerate: :environment) do
    Asgard::ConstantDumper.new.dump!
    Asgard::RouteDumper.new.dump!
  end

  desc 'Regenerate constants from Ruby models to TypeScript'
  task(:regenerate_constants, [:models] => :environment) do |_, args|
    Asgard::ConstantDumper.new(args[:models]).dump!
  end

  desc 'Regenerate route assets'
  task(regenerate_routes: :environment) do
    Asgard::RouteDumper.new.dump!
  end
end
