# Copyright (c) Valencia Management Group
# All rights reserved.

# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[8.0]
  def change
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      # Remove `null: false` or use conditional constraint if you are planning to use public clients.
      t.string :secret, null: false

      # Remove `null: false` if you are planning to use grant flows
      # that doesn't require redirect URI to be used during authorization
      # like Client Credentials flow or Resource Owner Password.
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ''
      t.boolean :confidential, null: false, default: true

      t.timestamps null: false

      t.index :uid, unique: true
    end

    create_table :oauth_access_grants do |t|
      t.references :resource_owner, null: false, polymorphic: true
      t.references :application, null: false
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ''
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :code_challenge, null: true
      t.string :code_challenge_method, null: true

      t.index :token, unique: true
      t.index %i[resource_owner_id resource_owner_type], name: 'polymorphic_owner_oauth_access_grants'
    end

    create_table :oauth_access_tokens do |t|
      t.references :resource_owner, index: true, polymorphic: true

      t.references :application, null: false

      # If you use a custom token generator you may need to change this column
      # from string to text, so that it accepts tokens larger than 255
      # characters. More info on custom token generators in:
      # https://github.com/doorkeeper-gem/doorkeeper/tree/v3.0.0.rc1#custom-access-token-generator
      #
      # t.text :token, null: false
      t.string :token, null: false

      t.string :refresh_token
      t.integer :expires_in
      t.string :scopes
      t.datetime :created_at, null: false
      t.datetime :revoked_at

      # The authorization server MAY issue a new refresh token, in which case
      # *the client MUST discard the old refresh token* and replace it with the
      # new refresh token. The authorization server MAY revoke the old
      # refresh token after issuing a new refresh token to the client.
      # @see https://datatracker.ietf.org/doc/html/rfc6749#section-6
      #
      # Doorkeeper implementation: if there is a `previous_refresh_token` column,
      # refresh tokens will be revoked after a related access token is used.
      # If there is no `previous_refresh_token` column, previous tokens are
      # revoked as soon as a new access token is created.
      #
      # Comment out this line if you want refresh tokens to be instantly
      # revoked after use.
      t.string :previous_refresh_token, null: false, default: ''

      t.index :token, unique: true
      t.index :refresh_token, unique: true
      t.index %i[resource_owner_id resource_owner_type], name: 'polymorphic_owner_oauth_access_tokens'
    end

    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id
  end
end
