# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'update'
  DefaultBot.create(purpose: 'Update Sidebars').update_sidebars! names: ARGV
end
