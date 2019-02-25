# frozen_string_literal: true

module Baseballbot
  class Task
    def bundle_exec_ruby(*args)
      on roles(:web) do
        within "#{release_path}/lib" do
          execute(:bundle, :exec, :ruby, args.compact.join(' '))
        end
      end
    end
  end

  class LoadGameThreadsTask < Task
    def initialize(month, teams)
      @month = month
      @teams = teams&.tr('+', ',')
    end

    def run!
      bundle_exec_ruby 'load_game_threads.rb', @month, @teams
    end
  end

  class RefreshTokensTask < Task
    def run!
      bundle_exec_ruby 'refresh_tokens.rb'
    end
  end

  class ChaosTask < Task
    def initialize(teams)
      if teams.blank?
        raise 'Please provide one or more wagons to light on fire.'
      end

      @teams = teams.tr('+', ',')
    end

    def run!
      bundle_exec_ruby 'chaos.rb', @teams
    end
  end

  class GameThreadsTask < Task
    def initialize(action, subreddits)
      raise 'Please provide an action to perform.' unless action

      @action = action
      @subreddits = subreddits&.split('+')
    end

    def run!
      bundle_exec_ruby 'game_threads.rb', @action, *@subreddits
    end
  end

  class SidebarsTask < Task
    def initialize(action, subreddits)
      raise 'Please provide an action to perform.' unless action

      @action = action
      @subreddits = subreddits&.split('+') || []
    end

    def run!
      bundle_exec_ruby 'sidebars.rb', @action, *@subreddits
    end
  end
end

namespace :bot do
  desc 'Load game threads'
  task :load_game_threads, %i[month teams] do |_, args|
    Baseballbot::LoadGameThreadsTask.new(args[:month], args[:teams]).run!
  end

  desc 'Refresh tokens'
  task :refresh_tokens do
    Baseballbot::RefreshTokensTask.new.run!
  end

  desc 'Chaos!'
  task :chaos, %i[teams] do |_, args|
    Baseballbot::ChaosTask.new(args[:teams]).run!
  end

  desc 'Post/update game threads'
  task :game_threads, %i[action subreddits] do |_, args|
    Baseballbot::GameThreadsTask.new(args[:action], args[:subreddits]).run!
  end

  desc 'Subreddit sidebars'
  task :sidebars, %i[action subreddits] do |_, args|
    Baseballbot::SidebarsTask.new(args[:action], args[:subreddits]).run!
  end
end
