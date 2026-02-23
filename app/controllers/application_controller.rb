# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentRequestDetails
  include HandleExceptions
  include Authenticate

  include Pagy::Method

  def paginate(*, **) = pagy(*, **, request: Current.request)
end
