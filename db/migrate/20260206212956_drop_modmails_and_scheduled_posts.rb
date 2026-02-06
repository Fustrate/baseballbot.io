# frozen_string_literal: true

class DropModmailsAndScheduledPosts < ActiveRecord::Migration[8.1]
  def change
    drop_table :modmails
    drop_table :scheduled_posts
  end
end
