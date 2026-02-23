# frozen_string_literal: true

class ApplicationService
  # Lets us use `t` and `l` helpers.
  include ActionView::Helpers::TranslationHelper

  def self.call(...) = new.call(...)

  protected

  def authorize!(action, resource) = resource.auror.authorize!(action, resource)

  def transaction(&) = ActiveRecord::Base.transaction(&)

  def params = Current.params

  def session = Current.session

  def log_edit(...) = ::LogEdit.call(...)

  class LoadPage < self
    DEFAULT_INCLUDES = nil
    DEFAULT_JOINS = nil
    DEFAULT_ORDER = nil

    def call(includes: nil, scope: nil, order: nil, joins: nil)
      (scope || default_scope)
        .includes(includes || self.class::DEFAULT_INCLUDES)
        .joins(joins || self.class::DEFAULT_JOINS)
        .reorder(order || default_order)
    end

    protected

    def default_scope = (raise NotImplementedError, '#default_scope not defined')

    def default_order
      return self.class::DEFAULT_ORDER.call if self.class::DEFAULT_ORDER.is_a? Proc

      self.class::DEFAULT_ORDER
    end
  end
end
