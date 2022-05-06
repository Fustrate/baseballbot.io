# frozen_string_literal: true

# :notest:
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy, inverse_of: :eventable, class_name: '::Event'
  end

  # Accounts that can perform actions
  module User
    extend ActiveSupport::Concern

    included do
      has_many :user_events, as: :user, class_name: 'Event', dependent: :nullify
    end

    def type = self.class.name
  end
end
