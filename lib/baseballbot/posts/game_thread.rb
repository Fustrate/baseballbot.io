# frozen_string_literal: true

class Baseballbot
  module Posts
    class GameThread < Base
      def initialize(id:, game_pk:, subreddit:, title: nil, post_id: nil)
        super(subreddit: subreddit, title: title)

        @id = id
        @game_pk = game_pk
        @post_id = post_id
      end

      def create!
        @template = template_for('game_thread')

        return change_status(id, nil, 'Postponed') if @template.postponed?

        create_game_thread_post!

        @bot.redis.hset(@template.gid, @subreddit.name.downcase, @submission.id)

        info "Posted #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @submission
      end

      def update!
        @template = template_for('game_thread_update')
        @submission = @subreddit.load_submission(id: @post_id)

        update_game_thread_post!

        info "[UPD] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        @template.final?
      end

      protected

      def create_game_thread_post!
        @submission = @subreddit.submit(
          title: @template.title,
          text: @template.body
        )

        # Mark as posted right away so that it won't post again
        change_status 'Posted'

        @submission.edit CGI.unescapeHTML(@submission.selftext)
          .gsub('#ID#', @submission.id)

        update_sticky @subreddit.sticky_game_threads?
        update_suggested_sort 'new'
        update_flair game_thread_flair('default')
      end

      def game_thread_flair(type)
        @subreddit.options.dig('game_threads', 'flair', type)
      end

      def update_game_thread_post!
        @subreddit.edit(
          id: @post_id,
          body: @template.replace_in(@submission)
        )

        return postpone_game_thread! if @template.postponed?

        return end_game_thread! if @template.final?

        change_status 'Posted'
      end

      # @param status [String] status of the game thread
      def change_status(status)
        game_thread_posted = status == 'Posted'

        fields = ['status = $2', 'updated_at = $3']
        fields.concat ['post_id = $4', 'title = $5'] if game_thread_posted

        @bot.db.exec_params(
          "UPDATE game_threads SET #{fields.join(', ')} WHERE id = $1",
          [
            @id,
            status,
            Time.now,
            (@submission.id if game_thread_posted),
            (@submission.title if game_thread_posted)
          ].compact
        )
      end

      # Mark the game thread as complete, and make any last updates
      def end_game_thread!
        change_status 'Over'

        update_sticky false if @subreddit.sticky_game_threads?

        info "[END] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        post_postgame!

        set_postgame_flair!
      end

      # If this subreddit has flair settings, apply them at the end of the game
      def set_postgame_flair!
        if @template.won?
          @subreddit.set_post_flair @submission, game_thread_flair('won')
        elsif @template.lost?
          @subreddit.set_post_flair @submission, game_thread_flair('lost')
        end
      end

      def postpone_game_thread!
        change_status 'Postponed'

        info "[PPD] #{@submission.id} in /r/#{@subreddit.name} for #{@game_pk}"

        post_postgame!
      end

      def template_for(type)
        Template::GameThread.new(
          body: @subreddit.template_for(type),
          subreddit: @subreddit,
          game_pk: @game_pk,
          title: @title && !@title.empty? ? @title : default_title,
          post_id: @post_id
        )
      end

      def default_title
        @subreddit.options.dig('game_threads', 'title')
      end

      # Create a postgame thread if the subreddit is set to have them
      #
      # @param game_pk [String] the MLB game ID
      #
      # @return [Redd::Models::Submission] the postgame thread
      def post_postgame!
        return unless @subreddit.options.dig('postgame', 'enabled')

        Baseballbot::Posts::Postgame.new(
          id: @id,
          game_pk: @game_pk,
          subreddit: @subreddit
        ).create!
      end
    end
  end
end
