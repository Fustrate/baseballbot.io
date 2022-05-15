# frozen_string_literal: true

module Auror
  def self.authorize(action, resource) = authorizer_for_resource(resource).authorize!(action, resource)

  def self.authorizer_for_resource(resource) = "#{resource.class.name}Auror".constantize.new

  class Authorizer
    # Lets us use `t` and `l` helpers.
    include ActionView::Helpers::TranslationHelper

    attr_reader :resource, :action, :options

    class << self
      attr_reader :permission_check, :permission_scope, :crud_delegation, :subreddit_check
    end

    def self.check_subreddit
      @subreddit_check = true
    end

    def self.verify_permissions(**options)
      @permission_scope = options[:scope]

      @permission_check = lambda do |action|
        return true unless check_action?(action, **options)

        return true if Current.user.permission?(options[:scope], action)

        raise Auror::MissingPermission.new(action, options[:scope])
      end
    end

    def self.delegate_crud(to:)
      @crud_delegation = { to: }
    end

    def self.model
      @model ||= name.delete_suffix('Auror')
    end

    def self.check_action?(action, **options)
      return Array(options[:except]).exclude?(action) if options[:except]
      return Array(options[:only]).include?(action) if options[:only]

      true
    end

    def any? = true

    def authorized?(action, resource, **options)
      authorize!(action, resource, **options)

      true
    rescue Auror::PolicyViolation, UserError
      false
    end

    def authorize!(action, resource, **options)
      # If we're authorizing against a model instead of a record, just do the basic check
      return resource.auror.authorize!(action, resource, **options) unless self.class.model == resource.class.name

      @action = action
      @resource = resource
      @options = options

      perform_authorization!

      true
    end

    protected

    # @raise Auror::PolicyViolation
    def perform_authorization!
      subreddit_check!
      user_permission!
      action_authorized!
    end

    def subreddit_check!
      return unless self.class.subreddit_check && !Current.user.permission?(:subreddits, :manage)

      raise Auror::NotSubredditModerator unless Current.user.subreddit_ids.include?(@resource.subreddit_id)
    end

    def user_permission!
      self.class.permission_check&.call(@action)
    end

    # Authorization actions can return true or nil to pass, a symbol or string to raise a lang error, or false to raise
    # a generic unauthorized error.
    def action_authorized!
      return crud_delegation! if self.class.crud_delegation

      case error = respond_to?("#{@action}?") ? __send__("#{@action}?") : any?
      when Symbol, String then raise Auror::UnauthorizedAction, error_lang_string(error)
      when false
        human_name = @resource.class.human_name.humanize(capitalize: false)

        raise Auror::UnauthorizedAction, "You are not authorized to #{@action} this #{human_name}."
      end
    end

    def crud_delegation!
      authorize!(@action == :read ? :read : :update, @resource.__send__(self.class.crud_delegation[:to]))
    end

    def error_lang_string(key)
      return key unless key.is_a? Symbol

      t("auror.errors.#{@resource.class.name.underscore}.#{@action}.#{key}")
    end
  end

  class PolicyViolation < StandardError
  end

  class NotSubredditModerator < PolicyViolation
    def message = 'You are not authorized as a moderator for this subreddit.'
  end

  class MissingPermission < PolicyViolation
    def initialize(action, scope)
      @action = action
      @scope = scope

      super()
    end

    def message
      format(
        'You do not have permission to %<action>s %<scope>s.',
        action: @action,
        scope: @scope.to_s.humanize(capitalize: false)
      )
    end
  end

  class UnauthorizedAction < PolicyViolation
  end
end
