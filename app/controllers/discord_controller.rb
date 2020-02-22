# frozen_string_literal: true

class DiscordController < ApplicationController
  def reddit_callback
    raise UserError, 'Invalid auth code' unless params[:code]

    raise UserError, 'Invalid state' unless params[:state]

    save_account
  end

  def debug
    Rails.application.redis.publish 'discord.debug', 'Debug endpoint hit'

    redirect_to '/'
  end

  protected

  def save_account
    session = Redd.it(
      code: params[:code],
      client_id: Rails.application.credentials.dig(:discord, :client_id),
      secret: Rails.application.credentials.dig(:discord, :secret),
      redirect_uri: 'https://baseballbot.io/discord/reddit-callback'
    )

    save_to_redis_and_publish session
  end

  def save_to_redis_and_publish(session)
    data = {
      state_token: params[:state],
      reddit_username: session.me.name
    }.to_json

    Rails.application.redis.rpush 'discord.verification_queue', data
    Rails.application.redis.publish 'discord.verified', data
  end
end
