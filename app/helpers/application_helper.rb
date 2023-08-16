# frozen_string_literal: true

module ApplicationHelper
  def authorized?(action, resource, **) = resource.auror.authorized?(action, resource, **)
end
