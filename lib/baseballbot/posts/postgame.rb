# frozen_string_literal: true

module Baseballbot
  module Posts
    class Postgame < GameChat
      def create!
        @template = postgame_template

        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        update_sticky @subreddit.sticky_gamechats?
        update_flair @subreddit.options.dig('postgame', 'flair')

        info "[PST] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def postgame_template
        body, title = @subreddit.template_for('postgame')

        Template::Gamechat.new(
          body: body,
          bot: @subreddit.bot,
          subreddit: @subreddit,
          game_pk: @game_pk,
          title: title
        )
      end
    end
  end
end
