# frozen_string_literal: true

module Users
  class Permissions
    attr_reader :permissions

    alias to_h permissions

    def initialize(user)
      @permissions = Hash.new { |hash, key| hash[key] = {} }

      merge_permissions user.permissions
    end

    def permission?(scope, name) = @permissions.dig(scope.to_sym, name.to_sym) || false

    def as_json(options = nil) = permissions.as_json(options).deep_transform_keys { _1.to_s.camelize(:lower) }

    protected

    def merge_permissions(new_permissions)
      new_permissions.each do |scope, permission_set|
        permission_set.each do |permission, value|
          @permissions[scope.to_sym][permission.to_sym] = value
        end
      end
    end
  end
end
