# frozen_string_literal: true

require 'js-routes'

module AssetsTasks
  def self.regenerate_routes!
    utilities_folder = Rails.root.join('app/frontend/utilities')

    js_routes_options = { camel_case: true, documentation: false, exclude: [/api|conductor/i] }

    JsRoutes.generate! utilities_folder.join('routes.js'), module_type: 'CJS', **js_routes_options
    JsRoutes.definitions! utilities_folder.join('routes.d.ts'), **js_routes_options

    regenerate_route_docs!
  end

  def self.regenerate_route_docs!
    routes = ActionDispatch::Routing::RoutesInspector.new(Rails.application.routes.routes)
      .format(ActionDispatch::Routing::ConsoleFormatter::Expanded.new)
      .gsub(/^-.*/, '')
      .gsub(/\nSource.*/, '')

    Rails.root.join('docs/routes.txt').write("#{routes}\n")
  end
end

class ConstantDumper
  EXCLUDE_CONSTANTS = {}.freeze

  def initialize(model_names = nil)
    @model_names = model_names&.split(',')

    @types = []
    @consts = []
  end

  def dump!
    Rails.application.eager_load!

    ApplicationRecord.descendants.each { process_model(_1) }

    constants_file.write("#{@types.sort.join}\n#{@consts.sort.join}")
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
    when Array then process_array(prefix, constant_name, value)
    when Hash then process_hash(prefix, constant_name, value)
    end
  end

  def process_array(prefix, constant_name, value)
    return if value.none?

    type = "#{prefix}#{constant_name.downcase.singularize.camelize}"

    @types << "export type #{type} = #{value.map { "'#{_1}'" }.join(' | ')};\n"
    @consts << "export const #{prefix.downcase_first}#{constant_name.downcase.camelize}: #{type}[] = " \
               "#{array_value(value)} as const;\n"
  end

  def process_hash(prefix, constant_name, value)
    values = value
      .sort
      .map { |k, v| "\n  #{quote_key(k)}: #{v.is_a?(Array) ? array_value(v) : "'#{v}'"}," }
      .join

    @consts << "export const #{prefix.downcase_first}#{constant_name.downcase.camelize} = {#{values}\n};\n"
  end

  def array_value(value) = "[#{value.map { "'#{_1}'" }.join(', ')}]"

  def quote_key(key) = key[/[: ]/] ? "'#{key}'" : key
end

namespace :assets do
  desc 'Regenerate assets for the front end'
  task(regenerate: :environment) do
    AssetsTasks.regenerate_routes!

    ConstantDumper.new.dump!
  end

  desc 'Regenerate constants from Ruby models to TypeScript'
  task(:regenerate_constants, [:models] => :environment) do |_, args|
    ConstantDumper.new(args[:models]).dump!
  end

  desc 'Regenerate route assets'
  task(regenerate_routes: :environment) do
    AssetsTasks.regenerate_routes!
  end
end
