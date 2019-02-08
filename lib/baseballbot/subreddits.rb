# frozen_string_literal: true

class Baseballbot
  module Subreddits
    BOT_SUBREDDITS_QUERY = <<~SQL
      SELECT subreddits.*
      FROM subreddits
      LEFT JOIN accounts ON (account_id = accounts.id)
    SQL

    # The default subreddits for each team, as used by /r/baseball. These can
    # be overridden on a team-by-team basis in their templates.
    DEFAULT_SUBREDDITS = {
      'ARI' => 'azdiamondbacks',
      'ATL' => 'Braves',
      'BAL' => 'Orioles',
      'BOS' => 'RedSox',
      'CHC' => 'CHICubs',
      'CIN' => 'Reds',
      'CLE' => 'ClevelandIndians',
      'COL' => 'ColoradoRockies',
      'CWS' => 'WhiteSox',
      'DET' => 'MotorCityKitties',
      'HOU' => 'Astros',
      'KC' => 'KCRoyals',
      'LAA' => 'AngelsBaseball',
      'LAD' => 'Dodgers',
      'MIA' => 'letsgofish',
      'MIL' => 'Brewers',
      'MIN' => 'MinnesotaTwins',
      'NYM' => 'NewYorkMets',
      'NYY' => 'NYYankees',
      'OAK' => 'OaklandAthletics',
      'PHI' => 'Phillies',
      'PIT' => 'Buccos',
      'SD' => 'Padres',
      'SEA' => 'Mariners',
      'SF' => 'SFGiants',
      'STL' => 'Cardinals',
      'TB' => 'TampaBayRays',
      'TEX' => 'TexasRangers',
      'TOR' => 'TorontoBlueJays',
      'WSH' => 'Nationals'
    }.freeze

    def name_to_subreddit(name)
      name.is_a?(Subreddit) ? name : subreddits[name.downcase]
    end

    protected

    def load_subreddits
      db.exec(BOT_SUBREDDITS_QUERY)
        .map { |row| [row['name'].downcase, process_subreddit_row(row)] }
        .to_h
    end

    def process_subreddit_row(row)
      Subreddit.new(
        bot: self,
        id: row['id'].to_i,
        name: row['name'],
        team_id: row['team_id'],
        account: accounts[row['account_id']],
        options: JSON.parse(row['options'])
      )
    end
  end
end
