# frozen_string_literal: true

module MarkdownHelpers
  ALIGNMENT = {
    center: ':-:',
    left: '-',
    right: '-:'
  }.freeze

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
    format('%0.3<percent>f', percent: percent).sub(/\A0+/, '')
  end

  def gb(games_back)
    games_back.gsub(/\.0$/, '')
  end

  def table(columns: [], data: [])
    headers = []
    alignment = []

    columns.map do |column|
      headers << column.is_a?(Array) ? column[0] : column.to_s
      alignment << ALIGNMENT[Array(column)[1] || :left] || ALIGNMENT[:left]
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
