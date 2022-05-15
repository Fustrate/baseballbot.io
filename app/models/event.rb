# frozen_string_literal: true

class Event < ApplicationRecord
  include Fustrate::Rails::Concerns::CleanAttributes

  belongs_to :eventable, polymorphic: true, touch: true, inverse_of: :events
  belongs_to :user, polymorphic: true, inverse_of: :user_events

  validates :type, presence: true

  # validates :date, date_sanity: -> { 1.year.ago..Time.zone.tomorrow }
  # validates :note, presence: true, if: -> { type == 'Note' }

  before_save :clean_data
  before_create :set_date

  alias_attribute :to_s, :note

  protected

  # If they added it today, set the date to right now
  def set_date
    self[:date] = Time.zone.now if !self[:date] || self[:date].today?
  end

  # Remove empty hash values, and nilify entirely if there's no data
  def clean_data
    self[:data] = self[:data].compact_blank.presence if self[:data]
  end
end
