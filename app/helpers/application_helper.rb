# frozen_string_literal: true

module ApplicationHelper
  def title(title)
    content_for :title, title
  end

  def html_data(html_data = {})
    @data ||= {}

    @data.merge!(html_data) if html_data.any?

    @data
  end
end
