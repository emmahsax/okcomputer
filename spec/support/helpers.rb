module Helpers
  # Public: Temporarily change the ENV hash
  #
  # env - Hash of new keys and values to inject into ENV
  def with_env(env)
    original = ENV.to_hash
    env.each do |key, value|
      ENV[key] = value
    end

    yield

    ENV.replace(original)
  end

  def with_clean_registry
    registry = OkComputer::Registry
    default_collection_defined = registry.instance_variable_defined?(:@default_collection)
    default_collection = registry.instance_variable_get(:@default_collection)
    registry.remove_instance_variable(:@default_collection) if default_collection_defined

    yield
  ensure
    registry.remove_instance_variable(:@default_collection) if registry.instance_variable_defined?(:@default_collection)
    registry.instance_variable_set(:@default_collection, default_collection) if default_collection_defined
  end
end
