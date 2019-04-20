# frozen_string_literal: true

module Slack
  class CommandsController < ApplicationController
    before_action :verify_slack_signature

    # We don't need CSRF protection here
    protect_from_forgery with: :null_session

    def gdt
      # params[:command] => '/gdt
      # params[:text] => 'add angels 4/19'

      command, args = params[:text].split(' ', 2)

      case command
      when 'add' then add_gdt(args)
      when 'list' then list_gdt(args)
      else
        render plain: '???', status: 200
      end
    end

    def add_gdt(_text)
      # if text.match?(//)
      render plain: 'Add', status: 200
    end

    protected

    def verify_slack_signature
      raise 'Invalid signature' unless Slack::VerifySignature.valid?
    end
  end
end
