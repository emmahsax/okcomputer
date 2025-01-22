module OkComputer
  # Verifies that Rails cache is set up and can speak with SolidCache
  class CacheCheckSolidCache < Check
    # Public: Check whether the cache is active
    def check
      mark_message "Cache is available (#{stats})"
    rescue ConnectionFailed => e
      mark_failure
      mark_message "Error: '#{e}'"
    end

    # Public: Outputs stats string for cache
    def stats
      return "" unless Rails.cache.respond_to? :stats

      stats = Rails.cache.stats
      connection_stats = stats[:connection_stats][SolidCache::Entry.current_shard]

      max_entries = connection_stats[:max_entries]
      current_entries = connection_stats[:entries]
      max_age = connection_stats[:max_age]
      oldest_age = connection_stats[:oldest_age]

      age_text = if oldest_age
        "oldest: #{format_duration(oldest_age)}, max: #{format_duration(max_age)}"
      else
        "no entries"
      end

      "entries: #{current_entries}/#{max_entries}, #{age_text}, #{stats[:connections]} connections"
    rescue => e
      raise ConnectionFailed, e
    end

    private

    def format_duration(seconds)
      if seconds < 60
        "#{seconds.round}s"
      elsif seconds < 3600
        "#{(seconds / 60).round}m"
      else
        "#{(seconds / 3600).round}h"
      end
    end

    ConnectionFailed = Class.new(StandardError)
  end
end
