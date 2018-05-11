# frozen_string_literal: true

require_relative 'default_bot'

default_bot(purpose: 'Post Off Day Threads').post_off_day_threads! names: ARGV
