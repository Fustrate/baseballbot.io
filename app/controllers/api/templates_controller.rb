# frozen_string_literal: true

module Api
  class TemplatesController < ApplicationController
    def index; end

    def show
      @template = Template.find params[:id]
    end
  end
end
