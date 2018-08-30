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
        update_flair postgame_flair

        info "[PST] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      protected

      def postgame_template
        body, title = @subreddit.template_for('postgame')

        Template::Gamechat.new(
          body: body,
          subreddit: @subreddit,
          game_pk: @game_pk,
          title: title
        )
      end

      def postgame_flair
        flairs = @subreddit.options.dig('postgame', 'flair')

        return flairs['won'] if @template.won? && flairs['won']
        return flairs['lost'] if @template.lost? && flairs['lost']

        flairs
      end
    end
  end
end
