# frozen_string_literal: true

# :notest:
module HandleExceptions
  extend ActiveSupport::Concern

  # These are exceptions that we really don't need to log to Honeybadger
  IGNORED_EXCEPTIONS = [UserError, ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation].freeze

  included do
    rescue_from Exception, with: :handle_exceptions

    protect_from_forgery with: :exception
  end

  def handle_exceptions(exception)
    @exception = exception

    status, @error_message = exception_status_and_message(exception)

    respond_to do |format|
      format.json do
        render json: { error: @error_message }, status:
      end

      format.any { handle_non_json_error(exception) }
    end

    notify_honeybadger(exception)
  end

  protected

  def handle_non_json_error(exception)
    raise exception if Rails.env.development?

    flash[:error] = @error_message

    redirect_back_or_to :app
  end

  def notify_honeybadger(exception)
    # We don't really care about users being told they're stupid
    return if IGNORED_EXCEPTIONS.any? { exception.is_a?(it) }

    if Rails.env.production?
      Honeybadger.notify exception
    else
      Rails.logger.error exception.message
      Rails.logger.error exception.backtrace.join "\n"
    end
  end

  def exception_status_and_message(exception)
    case exception
    when ActiveModel::Errors then model_errors(exception)
    when ActiveRecord::RecordInvalid then record_invalid(exception)
    when ActiveRecord::RecordNotFound then record_not_found
    # when Auror::PolicyViolation then policy_violation
    when ActionController::UnknownFormat then unknown_format
    when ActionController::InvalidAuthenticityToken then invalid_token
    else
      [:bad_request, exception.message]
    end
  end

  def model_errors(exception) = [:not_acceptable, exception.message.to_a.to_sentence]

  def record_invalid(exception) = [:not_acceptable, exception.record.errors.to_a.to_sentence]

  def record_not_found = [:not_found, t('record_not_found')]

  def policy_violation = [:unauthorized, t('access_denied')]

  def unknown_format = [:not_acceptable, t('unknown_format')]

  def invalid_token = [:forbidden, t('please_log_in')]
end
