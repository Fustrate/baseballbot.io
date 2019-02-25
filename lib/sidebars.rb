# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'update'
  DefaultBot.create(purpose: 'Update Sidebars').update_sidebars! names: ARGV
when 'show'
  puts DefaultBot.create(purpose: 'Display Sidebar').show_sidebar ARGV[0]
end
