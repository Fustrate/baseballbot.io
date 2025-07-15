# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetCurrentRequestDetails
  include HandleExceptions
  include Authenticate
end
