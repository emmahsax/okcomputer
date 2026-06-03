module OkComputer
  class SolidQueueBackedUpCheck < SizeThresholdCheck
    attr_accessor :queue
    attr_accessor :threshold

    # Public: Initialize a check for a backed-up SolidQueue queue
    #
    # queue - The name of the SolidQueue queue to check
    # threshold - An Integer to compare the queue's number of ready jobs
    #   against to consider it backed up
    def initialize(queue, threshold)
      self.queue = queue
      self.threshold = Integer(threshold)
      self.name = "SolidQueue queue '#{queue}'"
    end

    # Public: The number of ready (pending) jobs in the check's queue
    def size
      SolidQueue::Queue.new(queue).size
    end
  end
end
