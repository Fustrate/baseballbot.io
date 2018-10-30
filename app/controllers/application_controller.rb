# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentRequestDetails
  include HandleExceptions
  include Authenticate

  class << self
    def restrict_formats(format, options = {})
      before_action(options) do
        unless request.format.symbol == format
          raise ActionController::UnknownFormat
        end
      end
    end
  end
end
