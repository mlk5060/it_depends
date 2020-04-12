require 'tsort'

class NamespacedComponents
  include TSort
    
  def initialize(namespaced_components)
    @namespaced_components = namespaced_components
  end

  def tsort_each_node(&block)
    @namespaced_components.each_key(&block)
  end

  def tsort_each_child(dependency, &block)
    @namespaced_components[dependency].each(&block) if @namespaced_components.has_key?(dependency)
  end
end