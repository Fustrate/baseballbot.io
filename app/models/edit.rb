# frozen_string_literal: true

class Edit < ApplicationRecord
  include Fustrate::Rails::Concerns::CleanAttributes

  belongs_to :editable, polymorphic: true, touch: true, inverse_of: :edits
  belongs_to :user, polymorphic: true, inverse_of: :user_events

  alias_attribute :to_s, :note
end
