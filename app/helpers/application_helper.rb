# frozen_string_literal: true

module ApplicationHelper
  def title(title)
    content_for :title, title
  end
end
