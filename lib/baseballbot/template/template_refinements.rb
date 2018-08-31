# frozen_string_literal: true

module TemplateRefinements
  refine Numeric do
    def ordinalize
      "#{self}#{ordinal}"
    end

    def ordinal
      abs_number = to_i.abs

      return 'th' if (11..13).cover?(abs_number % 100)

      case abs_number % 10
      when 1 then 'st'
      when 2 then 'nd'
      when 3 then 'rd'
      else        'th'
      end
    end
  end
end
