# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :request, :params, :session

  resets { Time.zone = 'America/Los_Angeles' }

  def params=(params)
    if params.is_a? ActionController::Parameters
      super
    else
      super(ActionController::Parameters.new(params))
    end
  end

  def params
    attributes[:params] || ActionController::Parameters.new
  end
end
