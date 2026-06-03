module OkComputer
  class SolidQueueFailedJobsCheck < SizeThresholdCheck
    attr_accessor :threshold

    # Public: Initialize a check for the total number of failed SolidQueue jobs
    #
    # threshold - An Integer to compare the failed job count against to
    #   consider it over threshold
    def initialize(threshold)
      self.threshold = Integer(threshold)
      self.name = "SolidQueue Failed Jobs"
    end

    # Public: The total number of failed jobs
    def size
      SolidQueue::FailedExecution.count
    end
  end
end
