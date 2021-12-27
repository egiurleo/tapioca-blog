require 'tapioca'
require 'mongoid'

class MongoidDocument < Tapioca::Compilers::Dsl::Base
  def decorate(tree, constant)
    tree.create_path(constant) do |node|
      constant.fields.each do |field_name, field|
        generate_field_methods(node, field_name, field)
      end

      constant.aliased_fields.each do |aliased_field_name, field_name|
        field = constant.fields[field_name]
        generate_field_methods(node, aliased_field_name, field)
      end
    end
  end

  def gather_constants
    all_classes.grep(Mongoid::Fields::ClassMethods)
  end

  private

  def generate_field_methods(node, field_name, field)
    parameter_type = parameter_type_for(field.type)
    return_type = return_type_for(field.type)

    # Getters, setters, predicates
    node.create_method(field_name.to_s, return_type: return_type)
    node.create_method("#{field_name}=", parameters: [create_param('val', type: parameter_type)],
                                         return_type: return_type)
    node.create_method("#{field_name}?", return_type: 'T::Boolean')

    # Dirty methods
    node.create_method("#{field_name}_change", return_type: "T::Array[#{return_type}]")
    node.create_method("#{field_name}_was", return_type: return_type)
    node.create_method("#{field_name}_changed?", return_type: 'T::Boolean')
    node.create_method("reset_#{field_name}!", return_type: return_type)
  end

  def parameter_type_for(field_type)
    type = case field_type
    when Mongoid::StringifiedSymbol
      T.any(String, Symbol)
    else
      field_type
    end

    T.nilable(type)
  end

  def return_type_for(field_type)
    type = case field_type
    when Mongoid::StringifiedSymbol
      Symbol
    else
      field_type
    end

    T.nilable(type)
  end
end
