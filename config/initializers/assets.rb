# frozen_string_literal: true

# Rails.application.config.assets.paths << Rails.root.join('node_modules/@fortawesome/webfonts')

module Sprockets
  module Rails
    # Resolve assets referenced in CSS `url()` calls and replace them with the digested paths
    class AssetUrlProcessor
      def self.call(input)
        context = input[:environment].context_class.new(input)

        data = input[:data].gsub(REGEX) do |_match|
          path = Regexp.last_match[:path]

          ::Rails.logger.info "MATCH MATCH MATCH #{path} = #{context.asset_path(path)}"

          "url(#{context.asset_path(path)})"
        end

        context.metadata.merge(data: data)
      end
    end
  end
end
