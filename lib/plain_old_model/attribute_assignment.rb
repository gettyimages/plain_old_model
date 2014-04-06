require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/indifferent_access'

module PlainOldModel
  module AttributeAssignment

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes
      attributes = new_attributes.dup
      assign_attributes_from_associations(attributes)
      assign_simple_attributes(attributes)
    end

    def attributes=(new_attributes)
      assign_attributes(new_attributes)
    end

    private

    def assign_attributes_from_associations(attributes)
      associations.each do |association|
        attr_name = association.attr_name
        if attributes.include?(attr_name)
          merged_hash = merge_association_instance_variables_with_attributes(association, attr_name, attributes)
          value = association.create_value_from_attributes(merged_hash)
          set_attribute(attr_name, value)
          attributes.delete_if { |key, value| key.to_s == attr_name.to_s }
        end
      end
    end

    def sanitize_attributes(attributes)
      sanitized_attributes = {}
      attributes.each do |k, v|
        if respond_to?("#{k}=") || respond_to?("#{k}")
          sanitized_attributes[k] = v
        end
      end
      sanitized_attributes
    end

    def assign_simple_attributes(attributes)
      attributes = sanitize_attributes(attributes).stringify_keys

      attributes.each do |k, v|
        set_attribute(k, v)
      end
    end

    def set_attribute(attr_name, value)
      if respond_to?("#{attr_name}=")
        send("#{attr_name}=", value)
      else
        instance_variable_set("@#{attr_name}".to_sym, value)
      end
    end

  end
end
