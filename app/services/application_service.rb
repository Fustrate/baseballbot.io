# frozen_string_literal: true

class ApplicationService
  # Lets us use `t` and `l` helpers.
  include ActionView::Helpers::TranslationHelper

  def self.call(*parameters)
    new.call(*parameters)
  end

  protected

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def params
    Current.params
  end

  class LoadPage < self
    DEFAULT_ORDER = nil
    DEFAULT_INCLUDES = nil
    RESULTS_PER_PAGE = 25

    def call(page: nil, includes: nil, scope: nil, order: nil)
      (scope || default_scope)
        .reorder(order || default_order)
        .paginate(
          page: (page || params[:page]),
          per_page: self.class::RESULTS_PER_PAGE
        )
        .includes(includes || self.class::DEFAULT_INCLUDES)
    end

    protected

    def default_scope
      raise '#default_scope not defined'
    end

    def default_order
      return self.class::DEFAULT_ORDER.call if self.class::DEFAULT_ORDER.is_a? Proc

      self.class::DEFAULT_ORDER
    end
  end
end
