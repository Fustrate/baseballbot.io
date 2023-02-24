# frozen_string_literal: true

module GameThreads
  class Destroy < ApplicationService
    def call(game_thread)
      authorize! :delete, game_thread

      transaction do
        game_thread.update! status: 'removed'

        game_thread.events.create! type: 'Deleted', user: Current.user
      end
    end
  end
end
