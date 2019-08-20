# frozen_string_literal: true

class Baseballbot
  module Posts
    class OffDay < Base
      def create!
        @template = off_day_template

        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.evaluated_body
        )

        update_sticky @subreddit.options.dig('off_day', 'sticky') != false
        update_flair @subreddit.options.dig('off_day', 'flair')

        info "[OFF] Submitted off day thread #{@submission.id} in /r/#{@name}"

        @submission
      end

      protected

      def off_day_template
        Template::General.new(
          body: @subreddit.template_for('off_day'),
          subreddit: @subreddit,
          title: @subreddit.options.dig('off_day', 'title')
        )
      end
    end
  end
end
