# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'post'
  default_bot(purpose: 'Post Game Threads').post_game_threads! names: ARGV
when 'update'
  default_bot(purpose: 'Update Game Threads').update_game_threads! names: ARGV
when 'pregame'
  default_bot(purpose: 'Post Pregame Threads').post_pregame_threads! names: ARGV
when 'off_day'
  default_bot(purpose: 'Post Off Day Threads').post_off_day_threads! names: ARGV
end
