module OkComputer
  class CheckCollection
    attr_accessor :collection, :registrant_name, :display, :skip_all

    # Public: Initialize a new CheckCollection
    #
    # display - the display name for the Check Collection
    # exclude_skipped_checks - whether checks marked skip_all should be omitted
    def initialize(display, exclude_skipped_checks=false)
      self.display = display
      self.collection = {}
      self.skip_all = false
      @exclude_skipped_checks = exclude_skipped_checks
    end

    # Public: Run the collection's checks
    def run
      OkComputer.check_in_parallel ? check_in_parallel : check_in_sequence
    end

    # Public: Returns a check or collection if it's in the check collection
    #
    # key - a check or collection name
    # throws a KeyError when the key is not found
    def fetch(key, default=nil)
      found_in = self_and_sub_collections.detect{ |c| c[key] }
      raise KeyError unless found_in
      found_in[key]
    end

    # Public: Returns a  check or collection if it's in the check collection
    #
    # key - a check or collection name
    def [](key)
      fetch(key)
      rescue KeyError
    end

    # Public: The list of checks in the collection
    #
    # Returns an Array of the collection's values
    def checks
      included_collection.values
    end

    def <=>(check)
      if check.is_a?(CheckCollection)
        registrant_name <=> check.registrant_name
      else
        1
      end
    end

    alias_method :values, :checks

    def check_names
      included_collection.keys
    end

    alias_method :keys, :check_names

    def sub_collections
      collection.values.select{ |c| c.is_a?(CheckCollection)}
    end

    def self_and_sub_collections
      [collection] + sub_collections
    end

    # Public: Registers a check into the collection
    #
    # Returns the check
    def register(name, check)
      check.registrant_name = name
      collection[name] = check
    end

    # Public: Deregisters a check from the collection
    #
    # Returns the check
    def deregister(name)
      check = collection.delete(name)
    end

    # Public: The text of each check in the collection
    #
    # Returns a String
    def to_text
      "#{display}\n#{checks.sort.map{ |c| "#{"\s\s" unless c.is_a?(CheckCollection)}#{c.to_text}"}.join("\n")}"
    end

    # Public: The JSON of each check in the collection
    #
    # Returns a String containing a JSON array of hashes
    def to_json(*args)
      # smooshing their #to_json objects into one JSON hash
      combined = {}
      checks.each do |check|
        combined.merge!(JSON.parse(check.to_json))
      end

      combined.to_json
    end

    # Public: Whether all the checks succeed
    #
    # Returns a Boolean
    def success?
      checks.all?(&:success?)
    end

    private

    def included_collection
      return collection unless @exclude_skipped_checks
      collection.reject{ |_name, check| check.respond_to?(:skip_all) && check.skip_all }
    end

    def check_in_sequence
      checks.each(&:run)
    end

    def check_in_parallel
      checks.map{ |check| Thread.new(check, &:run) }.each(&:join)
    end
  end
end
