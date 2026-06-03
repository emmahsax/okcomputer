module OkComputer
  # Detects rapid increases in failed SolidQueue jobs by counting failures
  # that occurred within a rolling time window, rather than the total
  # accumulated failures. This is stateless across requests: it relies on the
  # created_at timestamp of each failed execution.
  class SolidQueueFailedJobsRateCheck < SizeThresholdCheck
    attr_accessor :threshold
    attr_accessor :window

    # Public: Initialize a check for the rate of failing SolidQueue jobs
    #
    # threshold - An Integer number of failures within the window to tolerate
    #   before the check is considered failed
    # window - The size of the rolling window to count failures within. Accepts
    #   either a number of seconds or an ActiveSupport::Duration (e.g.
    #   5.minutes). Defaults to 300 seconds (5 minutes).
    def initialize(threshold, window = 300)
      self.threshold = Integer(threshold)
      self.window = window
      self.name = "SolidQueue Failed Jobs Rate"
    end

    # Public: The number of jobs that have failed within the window
    def size
      cutoff = window.respond_to?(:ago) ? window.ago : Time.now - window
      SolidQueue::FailedExecution.where("created_at > ?", cutoff).count
    end
  end
end
