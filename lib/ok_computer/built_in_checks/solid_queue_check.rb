module OkComputer
  # Verifies that SolidQueue is up and processing jobs by confirming that at
  # least one worker process has a recent heartbeat, and reports a summary of
  # the current job counts.
  #
  # See https://github.com/rails/solid_queue
  class SolidQueueCheck < Check
    # Public: Check whether SolidQueue has live workers and report job stats
    def check
      if live_workers.zero?
        mark_failure
        mark_message "SolidQueue is DOWN. No workers are alive. (#{stats})"
      else
        mark_message "SolidQueue is up (#{live_workers} worker(s) alive). Job Counts: #{stats}"
      end
    rescue => e
      mark_failure
      mark_message "Error: '#{e}'"
    end

    # Public: The number of worker processes whose heartbeat is within
    # SolidQueue's configured alive threshold (default: 5 minutes)
    def live_workers
      alive_processes.where(kind: "Worker").count
    end

    # Public: A summary of the current job counts across SolidQueue
    def stats
      "ready: #{ready}, scheduled: #{scheduled}, in progress: #{in_progress}, failed: #{failed}"
    end

    private

    # SolidQueue::Process records that have sent a heartbeat recently enough to
    # be considered alive. Mirrors SolidQueue's own Prunable logic.
    def alive_processes
      SolidQueue::Process.where("last_heartbeat_at > ?", SolidQueue.process_alive_threshold.ago)
    end

    def ready
      SolidQueue::ReadyExecution.count
    end

    def scheduled
      SolidQueue::ScheduledExecution.count
    end

    def in_progress
      SolidQueue::ClaimedExecution.count
    end

    def failed
      SolidQueue::FailedExecution.count
    end
  end
end
