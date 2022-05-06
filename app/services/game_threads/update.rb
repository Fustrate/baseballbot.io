# frozen_string_literal: true

module GameThreads
  class Update < ApplicationService
    PERMITTED_PARAMS = %i[title post_at].freeze

    def call(game_thread)
      authorize! :update, game_thread

      game_thread.assign_params PERMITTED_PARAMS

      log_edit game_thread

      game_thread.save!
    end
  end
end
