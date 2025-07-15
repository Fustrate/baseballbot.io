# frozen_string_literal: true

class AppController < ApplicationController
  # There's only one HTML view, we don't need to extract the layout
  layout false

  def app; end
end
