# frozen_string_literal: true

module Baseballbot
  module Posts
    class Pregame < GameChat
      def create!
        post_pregame_thread!

        info "[PRE] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def post_pregame_thread!
        @bot.use_account(@subreddit.account.name)

        @template = pregame_template
        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        change_status 'Pregame'

        update_sticky @subreddit.sticky_gamechats?
        update_flair @subreddit.options.dig('pregame', 'flair')
      end

      def pregame_template
        body, title = template_for('pregame')

        Template::Gamechat.new(
          body: body,
          subreddit: @subreddit,
          game_pk: @game_pk,
          title: title
        )
      end
    end
  end
end
