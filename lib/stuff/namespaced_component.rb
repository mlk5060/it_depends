class NamespacedComponent
  attr_reader :namespace, :dependencies

  def initialize(namespace, dependencies)
    @namespace = namespace
    @dependencies = dependencies
  end
end