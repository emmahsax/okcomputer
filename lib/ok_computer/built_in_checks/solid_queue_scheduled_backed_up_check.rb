module OkComputer
  # Detects a stalled SolidQueue dispatcher by counting scheduled jobs that are
  # overdue — i.e. their scheduled_at is more than `grace` in the past, so a
  # healthy dispatcher should already have promoted them to ready_executions.
  #
  # This is distinct from SolidQueueBackedUpCheck, which measures ready (already
  # promoted) depth. A dead/behind dispatcher leaves jobs stuck in scheduled and
  # invisible to that check; this check surfaces them.
  class SolidQueueScheduledBackedUpCheck < SizeThresholdCheck
    attr_accessor :threshold
    attr_accessor :grace

    # Public: Initialize a check for overdue scheduled SolidQueue jobs
    #
    # threshold - An Integer; the number of overdue scheduled jobs to tolerate
    #   before considering the dispatcher backed up.
    # grace - An ActiveSupport::Duration; how far past scheduled_at a job must be
    #   before it counts as overdue. The dispatcher polls roughly every second
    #   (config/queue.yml polling_interval), so sub-poll lateness is normal and a
    #   grace window prevents flapping. Defaults to 1 minute.
    def initialize(threshold, grace: 1.minute)
      self.threshold = Integer(threshold)
      self.grace = grace
      self.name = "SolidQueue overdue scheduled jobs"
    end

    # Public: Count of scheduled jobs overdue by more than `grace`. A healthy
    # dispatcher keeps this at 0.
    def size
      SolidQueue::ScheduledExecution.where("scheduled_at <= ?", grace.ago).count
    end
  end
end
