require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/indifferent_access'

module PlainOldModel
  module AttributeAssignment

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes
      @new_attributes = new_attributes.dup
      assign_attributes_from_associations
      assign_simple_attributes
    end

    alias attributes= assign_attributes

    def self.included(klass)
      klass.extend ClassMethods
    end

    def associations
      self.class.associations
    end


    module ClassMethods

      def has_one(attr_name, options={})
        associations << HasOneAssociation.new(attr_name, options)
        attr_accessor attr_name
      end

      def has_many(attr_name, options={})
        associations << HasManyAssociation.new(attr_name, options)
        attr_accessor attr_name
      end

      def associations
        @associations ||= []
      end

    end


    class Association
      attr_reader :attr_name

      def initialize(attr_name, options)
        @attr_name = attr_name
        @options = options
      end

      def create_value_from_attributes(attributes)
        if @options[:factory_method]
          klass.send(@options[:factory_method], attributes)
        else
          klass.new(attributes)
        end
      end

      def klass
        if @options[:class_name]
          @options[:class_name].to_s.camelcase.constantize
        else
          klass_from_attr_name
        end
      end

      def klass_from_attr_name
        @attr_name.to_s.camelcase.constantize
      end
    end


    class HasOneAssociation < Association
    end


    class HasManyAssociation < Association
      def create_value_from_attributes(items)
        items.map{|item| super(item)}
      end

      def klass_from_attr_name
        @attr_name.to_s.singularize.camelcase.constantize
      end
    end


    private

      def assign_attributes_from_associations
        associations.each do |association|
          assign_attributes_from_association(association)
        end
      end

      def assign_attributes_from_association(association)
        attr_name = association.attr_name
        if @new_attributes.include?(attr_name)
          merged_hash = merged_association_hash(association, attr_name)
          value = association.create_value_from_attributes(merged_hash)
          set_attribute(attr_name, value)
          @new_attributes.delete_if { |key, value| key.to_s == attr_name.to_s }
        end
      end

      # deep merge of instance variables from one association
      # with the rest of the 'new_attributes'
      def merged_association_hash(association, attr_name)
        association_instance = send(attr_name)

        if association.class == HasOneAssociation
          return instance_variables_hash(association_instance).deep_merge(@new_attributes[attr_name])
        elsif association.class == HasManyAssociation
          if association_instance.nil?
            return @new_attributes[attr_name]
          else
            association_instance_array = []
            association_instance.each_with_index do |instance, i|
              association_instance_array << instance_variables_hash(instance).deep_merge(@new_attributes[attr_name][i])
            end
            return association_instance_array
          end
        end
      end

      def instance_variables_hash(association_instance)
        hash = HashWithIndifferentAccess.new

        unless association_instance.nil?
          association_instance.instance_variables.each do |var|
            if association_instance.instance_variable_get(var).instance_variables.length > 0
              hash[var.to_s.delete("@")] = instance_variables_hash(association_instance.instance_variable_get(var))
            else
              hash[var.to_s.delete("@")] = association_instance.instance_variable_get(var)
            end
          end
        end
        hash
      end

      def assign_simple_attributes
        sanitized_attributes.stringify_keys.each do |k, v|
          set_attribute(k, v)
        end
      end

      # attributes for which we have an attr_reader and/or an attr_writer
      def sanitized_attributes
        sanitized = {}
        @new_attributes.each do |k, v|
          if respond_to?("#{k}=") || respond_to?("#{k}")
            sanitized[k] = v
          end
        end
        sanitized
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
