# frozen_string_literal: true

require_relative 'default_bot'

default_bot(purpose: 'Update Sidebars').update_sidebars! names: ARGV
