# frozen_string_literal: true

module ApplicationHelper
  def title(title)
    content_for :title, title
  end

  def post_at_format(post_at)
    return '3 Hours Pregame' unless post_at

    if post_at.match?(/\A\-?\d{1,2}\z/)
      "#{post_at.to_i.abs} Hours Pregame"
    elsif post_at =~ /(1[012]|\d)(:\d\d|) ?(am|pm)/i
      hours = Regexp.last_match[1].to_i
      hours += 12 if hours != 12 && Regexp.last_match[3].casecmp('pm').zero?

      time = Time.zone.local(2001, 1, 1, hours, Regexp.last_match[2])

      "at #{time.strftime('%-I:%M %p')}"
    end
  end

  def html_data(html_data = {})
    @data ||= {}

    @data.merge!(html_data) if html_data.any?

    @data
  end
end
