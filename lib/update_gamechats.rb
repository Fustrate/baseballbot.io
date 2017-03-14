# frozen_string_literal: true
require_relative 'default_bot'

default_bot(purpose: 'Update Game Chats').update_gamechats! names: ARGV
