require 'active_support/all'

module PlainOldModel
  module AttributeAssignment
    module ClassMethods
      def has_one(attr_name, options={})
        if options[:class_name]
          associations[attr_name] = options[:class_name].to_s.capitalize unless options[:class_name].nil?
        else
          associations[attr_name] = attr_name.to_s.capitalize
        end
       attr_accessor attr_name
      end

      def associations
        @associations ||= {}
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes
      associations.each do |k, v|
        if new_attributes.include?(k)
          new_klass = k.to_s.camelcase.constantize.new(new_attributes[k])

          respond_to?("#{k}=") ? (send("#{k}=", new_klass)) : (instance_variable_set("@#{k}".to_sym, new_klass))
          new_attributes = new_attributes.delete_if { |key, value| key == k }
        end
      end
      assignment(new_attributes, options)
    end

    def associations
      self.class.associations
    end

    private
    def sanitize_attributes(attributes)
      sanitized_attributes = {}
      attributes.each do |k, v|
        if respond_to?("#{k}=") || respond_to?("#{k}")
          sanitized_attributes[k]=v
        end
      end
      sanitized_attributes
    end

    def assignment(attributes, options)
      attributes = sanitize_attributes(attributes).stringify_keys

      attributes.each do |k, v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        elsif respond_to?("#{k}")
          instance_variable_set("@#{k}".to_sym, v)
        else
          raise(Exception)
        end
      end
    end
  end
end
