# frozen_string_literal: true

class RedisConnection
  class << self
    attr_reader :redis

    def ensure_redis
      unless EM.reactor_running? && EM.reactor_thread.alive?
        Thread.new { EM.run }
        sleep 0.25
      end

      return if @redis

      @redis = EM::Hiredis.connect

      sleep 0.25
    end

    def publish(channel, message)
      ensure_redis

      EM.next_tick do
        @redis.publish channel.to_s, message.to_json
      end
    end

    def set(key, value)
      ensure_redis

      EM.next_tick do
        @redis.set key, value
      end
    end

    def get(key)
      ensure_redis

      @redis.get(key) do |value|
        yield value
      end
    end

    def getset(key, value)
      ensure_redis

      @redis.getset(key, value) do |old_value|
        yield old_value
      end
    end
  end
end
