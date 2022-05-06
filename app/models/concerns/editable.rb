# frozen_string_literal: true

module Editable
  extend ActiveSupport::Concern

  included do
    has_many :edits, as: :editable, dependent: :destroy, inverse_of: :editable, class_name: '::Edit'
  end

  # Accounts that can perform edits
  module User
    extend ActiveSupport::Concern

    included do
      has_many :user_edits, as: :user, class_name: 'Edit', dependent: :nullify
    end

    def type = self.class.name
  end
end
