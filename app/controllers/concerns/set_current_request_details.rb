# frozen_string_literal: true

# :notest:
module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.request = request
      Current.params = params
      Current.session = session
    end
  end
end
