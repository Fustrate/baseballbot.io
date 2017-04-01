# frozen_string_literal: true

require_relative 'default_bot'

default_bot(purpose: 'Post Pregame Chats').post_pregames! names: ARGV
