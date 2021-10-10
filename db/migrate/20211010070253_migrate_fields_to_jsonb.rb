class MigrateFieldsToJsonb < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      ALTER TABLE bot_actions ALTER COLUMN data TYPE jsonb USING data::jsonb;
      ALTER TABLE scheduled_posts ALTER COLUMN options TYPE jsonb USING options::jsonb;
      ALTER TABLE subreddits ALTER COLUMN options TYPE jsonb USING options::jsonb;

      SELECT setval('accounts_id_seq', (SELECT MAX(id) FROM accounts));
      SELECT setval('game_threads_id_seq', (SELECT MAX(id) FROM game_threads));
      SELECT setval('subreddits_id_seq', (SELECT MAX(id) FROM subreddits));
      SELECT setval('templates_id_seq', (SELECT MAX(id) FROM templates));
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      ALTER TABLE bot_actions ALTER COLUMN data TYPE json USING data::json;
      ALTER TABLE scheduled_posts ALTER COLUMN options TYPE json USING options::json;
      ALTER TABLE subreddits ALTER COLUMN options TYPE json USING options::json;
    SQL
  end
end
