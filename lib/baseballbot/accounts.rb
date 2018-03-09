# frozen_string_literal: true

class Baseballbot
  module Accounts
    attr_reader :accounts, :current_account

    def use_account(name)
      unless @current_account&.name == name
        @current_account = @accounts.values.find { |acct| acct.name == name }

        @client.access = @current_account.access
      end

      refresh_access! if @current_account.access.expired?
    end

    def refresh_access!
      @client.refresh

      new_expiration = Time.now + @client.access.expires_in

      @db.exec_params(
        'UPDATE accounts
        SET access_token = $1, expires_at = $2
        WHERE refresh_token = $3',
        [
          @client.access.access_token,
          new_expiration.strftime('%Y-%m-%d %H:%M:%S'),
          @client.access.refresh_token
        ]
      )

      client
    end

    protected

    def load_accounts
      @db.exec('SELECT * FROM accounts')
        .map { |row| [row['id'], process_account_row(row)] }
        .to_h
    end

    def process_account_row(row)
      expires_at = Chronic.parse row['expires_at']

      Account.new(
        bot: self,
        name: row['name'],
        access: Redd::Models::Access.new(
          @client,
          access_token: row['access_token'],
          refresh_token: row['refresh_token'],
          scope: row['scope'][1..-2].split(','),
          # Remove 60 seconds so we don't run into invalid credentials
          expires_at: expires_at - 60,
          expires_in: expires_at - Time.now
        )
      )
    end
  end
end