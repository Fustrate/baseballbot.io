# frozen_string_literal: true
require_relative 'default_bot'

default_bot(purpose: 'Post Game Chats').post_gamechats! names: ARGV
