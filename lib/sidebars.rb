# frozen_string_literal: true

require_relative 'default_bot'

case ARGV.shift
when 'update'
  default_bot(purpose: 'Update Sidebars').update_sidebars! names: ARGV
end
