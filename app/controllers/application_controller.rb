# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentRequestDetails
  include HandleExceptions
  include Authenticate

  def self.restrict_formats(format, **options)
    before_action(options) do
      raise ActionController::UnknownFormat unless request.format.symbol == format
    end
  end
end
