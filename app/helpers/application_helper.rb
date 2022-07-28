# frozen_string_literal: true

module ApplicationHelper
  def authorized?(action, resource, **options) = resource.auror.authorized?(action, resource, **options)
end
