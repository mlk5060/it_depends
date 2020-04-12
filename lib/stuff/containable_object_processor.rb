require 'parser/current'
require 'byebug'

class ContainableObjectProcessor < AST::Processor
  attr_reader :object_namespace, :initialize_parameters
  
  def initialize
    @object_namespace = []
    @initialize_parameters = []
  end

  def on_begin(node)
    node.children.each { |c| process(c) }
  end

  def on_module(node)
    check_for_symbol_or_continue(node)
  end

  def on_class(node)
    check_for_symbol_or_continue(node)
  end

  def on_const(node)
    check_for_symbol_or_continue(node)
  end

  def on_def(node)
    check_for_initialize(node)
  end

  def handler_missing(node)

  end

  private

  def check_for_symbol_or_continue(node)

    node.children.each do |child|
      if child.class == Symbol
        add_symbol_to_object_namespace(child)
      else
        process(child)
      end
    end
  end

  def add_symbol_to_object_namespace(symbol)
    @object_namespace << symbol.to_s
  end

  def check_for_initialize(node)
    if node.children[0] == :initialize
      @initialize_parameters = node
        .children[1]
        .children
        .map { | initialize_parameter | initialize_parameter.children[0].to_s }
    end

  end
end