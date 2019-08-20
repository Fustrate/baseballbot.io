# frozen_string_literal: true

class MarkdownCalendar
  class << self
    def generate(cells, dates)
      <<~TABLE
        S|M|T|W|T|F|S
        :-:|:-:|:-:|:-:|:-:|:-:|:-:
        #{calendar_rows(cells, dates).join("\n")}
      TABLE
    end

    protected

    def calendar_rows(cells, dates)
      rows = [cells.shift(7 - dates.values.first[:date].wday).join('|')]
      rows << cells.shift(7).join('|') while cells.any?

      # Fill out the beginning and end of the table
      rows[0] = "#{' |' * dates.values.first[:date].wday}#{rows[0]}"
      rows[-1] = "#{rows[-1]}#{' |' * (6 - dates.values.last[:date].wday)}"

      rows
    end
  end
end
