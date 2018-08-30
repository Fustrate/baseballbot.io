# frozen_string_literal: true

module Baseballbot
  module Posts
    class OffDay < Base
      def create!
        @template = off_day_template

        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        update_sticky @subreddit.options.dig('off_day', 'sticky') != false
        update_flair @subreddit.options.dig('off_day', 'flair')

        info "[OFF] Submitted off day thread #{@submission.id} in /r/#{@name}"

        @submission
      end

      protected

      def off_day_template
        body, title = @subreddit.template_for('off_day')

        Template::General.new(
          body: body,
          subreddit: @subreddit,
          title: title
        )
      end
    end
  end
end
