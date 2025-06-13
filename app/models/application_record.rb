# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ::UnaryPlus::Concerns::Model
end
