# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'post'
  DefaultBot.create(purpose: 'Post GDTs').post_game_threads! names: ARGV
when 'update'
  DefaultBot.create(purpose: 'Update GDT').update_game_threads! names: ARGV
when 'pregame'
  DefaultBot.create(purpose: 'Post PreGTs').post_pregame_threads! names: ARGV
when 'off_day'
  DefaultBot.create(purpose: 'Post ODTs').post_off_day_threads! names: ARGV
end
