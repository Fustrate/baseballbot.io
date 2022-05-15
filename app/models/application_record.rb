# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ::Fustrate::Rails::Concerns::Model
end
