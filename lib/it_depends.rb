require 'parser/current'
require 'zeitwerk'
require_relative 'stuff/containable_object_processor'
require_relative 'stuff/namespaced_component'
require_relative 'stuff/namespaced_components'

class ItDepends
    
  ALL_RUBY_FILES_IN_APP_DIRECTORY = '/app/**/*.rb'.freeze
  CONTAINERIZE_MAGIC_COMMENT = '# depend_on_me'.freeze
  CURRENT_APP_PROFILE = ENV['PROFILE'].freeze
  NAMESPACE_SEPARATOR = '::'.freeze

  def setup

    loader = Zeitwerk::Loader.new
    loader.push_dir( 'app')
    loader.setup
    loader.eager_load

    namespaced_components_with_dependencies = {} # { namespace1: [dependency_1, [dependency_2, dependency_3]], ... ]
    namespaced_components_by_id = {} # { id_1: component_1, id_2: component_2, ... }
    namespaced_components_by_type = {} # { type_1: [component_1, component_3], type_2: [component_2], ... }

    get_all_files_in_app_directory.each do |app_file|
      app_file_first_line = first_line_in_file(app_file)

      if app_file_first_line.start_with?(CONTAINERIZE_MAGIC_COMMENT)

        component_configuration = remove_comment_marker(app_file_first_line)
        user_defined_component_configuration = eval(component_configuration)  

        if should_containerize_component_in_current_application_profile(component_configuration)
        component_namespace_and_dependencies = component_namespace_and_dependencies(app_file)
        component_namespace = component_namespace_and_dependencies[0]
        component_dependencies = component_namespace_and_dependencies[1]
        namespaced_components_with_dependencies[component_namespace] = component_dependencies

                
        id = user_defined_component_configuration[:id] 
        type = user_defined_component_configuration[:type]

        # Key by ID
        if id.nil? == false && id.empty? == false
          raise StandardError("A dependency with ID '#{id}' has already been specified") if namespaced_components_by_id.key?(id)
          namespaced_components_by_id[id] = component_namespace 
        end

        if namespaced_components_by_type.key?(type) 
          namespaced_components_by_type[type].push(component_namespace)
        else
          namespaced_components_by_type[type] = [ component_namespace ]
        end

        # end 
      end
    end

    # We now have all namespaces for components, but their dependencies are 
    # as defined by the user; not namespaced. 
    # We need to replace non-namespaced dependencies with namespaced ones so
    # that we can run a tsort on them
    namespaced_components_and_flattened_dependencies = {} 
    namespaced_components_with_dependencies.each do | namespaced_component, dependencies |
      
      namespaced_dependencies = []

      dependencies.each do | dependency | 

        # Is an ID being specified?
        if dependency.start_with?('the_')
          id_specified = dependency.split('the_')[1]
          namespaced_dependencies.push(namespaced_components_by_id[id_specified])
        # Are all components of a type being specified?
        elsif dependency.start_with?('every_') 
          type_specified = dependency.split('every_')[1]
          namespaced_types = namespaced_components_by_type[type_specified]
          namespaced_dependencies.push(namespaced_types)
        # This must be a single instance of a type then
        else
          dependencies_of_type = namespaced_components_by_type[dependency]
          raise StandardError('You declared a dependency using a type, but more than one of these are available') if dependencies_of_type.size > 1
          namespaced_dependencies.push(dependencies_of_type[0])
        end
      end

      namespaced_components_with_dependencies[namespaced_component] = namespaced_dependencies
      namespaced_components_and_flattened_dependencies[namespaced_component] = namespaced_dependencies.flatten
    end

    # Construct graph for tsort and sort it now that all the namespaces are calculated
    components = {} # { namespace => object_instance }
    NamespacedComponents.new(namespaced_components_and_flattened_dependencies)
      .tsort_each do | tsorted_namespaced_component | 

        # If the namespaced_component has dependencies, they should have already been created
        # as objects, so retrieve the objects to use in the initialize method for the namespaced component
        parameters = namespaced_components_with_dependencies[tsorted_namespaced_component].map do | namespaced_dependency |
          if namespaced_dependency.kind_of?(Array)
            namespaced_dependency.map { | namespaced_inner_dependency | components[namespaced_inner_dependency] } 
          else
            components[namespaced_dependency]
          end
        end

        component = Object.const_get(tsorted_namespaced_component).new(*parameters)
        
        components[tsorted_namespaced_component] = component
      end

    byebug
  end    

  def get_all_files_in_app_directory
    Dir[Dir.pwd + ALL_RUBY_FILES_IN_APP_DIRECTORY]
  end

  def first_line_in_file (file_path)
    File.open(file_path, &:readline)
  end

  def remove_comment_marker (string)
    string[1..-1].strip
  end

  def depend_on_me(type:, id:)
    {type: type, id: id}
  end

  def should_containerize_component_in_current_application_profile (component_configuration)
    component_configuration[:profile] == CURRENT_APP_PROFILE
  end

  def component_namespace_and_dependencies(file_path)
    parsed_component_code = Parser::CurrentRuby.parse(File.read(file_path))
    
    cop = ContainableObjectProcessor.new
    cop.process(parsed_component_code)
    [
      cop.object_namespace.join(NAMESPACE_SEPARATOR),
      cop.initialize_parameters
    ]
  end
end