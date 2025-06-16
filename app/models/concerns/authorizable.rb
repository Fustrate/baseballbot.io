# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  included do
    def self.auror
      @auror ||= "#{name}Auror".constantize.new
    end

    delegate :auror, to: :class
  end
end
