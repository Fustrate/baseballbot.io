# frozen_string_literal: true

class Baseballbot
  module Utility
    def self.parse_time(utc, in_time_zone:)
      utc = Time.parse(utc).utc unless utc.is_a? Time

      time_zone = if in_time_zone.is_a?(TZInfo::DataTimezone)
                    in_time_zone
                  else
                    TZInfo::Timezone.get(in_time_zone)
                  end

      period = time_zone.period_for_utc(utc)
      with_offset = utc + period.utc_total_offset

      Time.parse "#{with_offset.strftime('%FT%T')} #{period.zone_identifier}"
    end

    def self.adjust_time_proc(post_at)
      if post_at =~ /\A\-?\d{1,2}\z/
        ->(time) { time - Regexp.last_match[0].to_i.abs * 3600 }
      elsif post_at =~ /(1[012]|\d)(:\d\d|) ?(am|pm)/i
        constant_time(Regexp.last_match)
      else
        # Default to 3 hours before game time
        ->(time) { time - 3 * 3600 }
      end
    end

    def self.constant_time(match_data)
      lambda do |time|
        hours = match_data[1].to_i
        hours += 12 if hours != 12 && match_data[3].casecmp('pm').zero?
        minutes = (match_data[2] || ':00')[1..2].to_i

        Time.new(time.year, time.month, time.day, hours, minutes, 0)
      end
    end
  end
end
