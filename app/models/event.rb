# frozen_string_literal: true

class Event < ApplicationRecord
  include UnaryPlus::Concerns::CleanAttributes

  belongs_to :eventable, polymorphic: true, touch: true, inverse_of: :events
  belongs_to :user, polymorphic: true, inverse_of: :user_events

  validates :type, presence: true

  # validates :note, presence: true, if: -> { type == 'Note' }

  before_save :clean_data

  alias_attribute :to_s, :note

  protected

  # Remove empty hash values, and nilify entirely if there's no data
  def clean_data
    self[:data] = self[:data].compact_blank.presence if self[:data]
  end
end
