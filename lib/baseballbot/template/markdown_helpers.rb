# frozen_string_literal: true

module MarkdownHelpers
  TABLE_ALIGNMENT = {
    center: ':-:',
    left: '-',
    right: '-:'
  }

  def bold(text)
    "**#{text}**"
  end

  def italic(text)
    "*#{text}*"
  end

  def sup(text)
    "^(#{text})"
  end

  def pct(percent)
    format('%0.3f', percent).sub(/\A0+/, '')
  end

  def gb(games_back)
    return '-' if games_back == '-'

    (games_back % 1.0).zero? ? games_back.to_i : games_back
  end

  def table(columns: [], data: [])
    headers = []
    alignment = []

    columns.map do |column|
      if column.is_a?(Array)
        headers << column[0]
        alignment << TABLE_ALIGNMENT[column[1] || :left]
      else
        headers << column.to_s
        alignment << TABLE_ALIGNMENT[:left]
      end
    end

    <<~TABLE
      #{headers.join('|')}|
      #{alignment.join('|')}|
      #{data.map { |row| row.join('|') }.join("\n")}|
    TABLE
  end

  def link_to(text = '', options = {})
    title = %( "#{options[:title]}") if options[:title]

    return "[#{text}](/r/#{options[:sub]}#{title})" if options[:sub]
    return "[#{text}](#{options[:url]}#{title})" if options[:url]
    return "[#{text}](/u/#{options[:user]}#{title})" if options[:user]

    "[#{text}](/##{title})"
  end
end
