# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@baseballbot.io'
  layout 'mailer'
end
