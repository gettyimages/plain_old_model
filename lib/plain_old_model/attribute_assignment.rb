require 'active_support/all'

module PlainOldModel
  module AttributeAssignment
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

    def self.included(klass)
      klass.extend ClassMethods
    end

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes
      attributes = new_attributes.dup

      associations.each do |association|
        attr_name = association.attr_name
        if attributes.include?(attr_name)
          value = merge_association_with_attributes(association, attr_name, attributes)
          set_attribute(attr_name, value)
          attributes  = attributes.delete_if { |key, value| key.to_s == attr_name.to_s }
        end
      end
      assign_simple_attributes(attributes, options)
    end

    def merge_association_with_attributes(association, attr_name, attributes)
      association_instance = send(attr_name)
      association_instance_hash = {}
      if association.class == HasOneAssociation
        association_instance.instance_variables.each { |var| association_instance_hash[var.to_s.delete("@")] = association_instance.instance_variable_get(var) } unless association_instance.nil?
        association_instance_hash.merge!(attributes[attr_name])
        value = association.create_value_from_attributes(association_instance_hash)
      elsif association.class == HasManyAssociation
        association_instance_array = []
        if association_instance.nil?
          value = association.create_value_from_attributes(attributes[attr_name])
        else
          for i in 0..association_instance.length-1
            attributes_hash = {}
            association_instance[i].instance_variables.each do |var|
              attributes_hash[var.to_s.delete("@").to_sym] = association_instance[i].instance_variable_get(var)
            end
            merged_hash = attributes_hash.merge(attributes[attr_name][i])
            association_instance_array << merged_hash
          end
          value = association.create_value_from_attributes(association_instance_array)
        end
      end
      value
    end

    def associations
      self.class.associations
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

    def sanitize_attributes(attributes)
      sanitized_attributes = {}
      attributes.each do |k, v|
        if respond_to?("#{k}=") || respond_to?("#{k}")
          sanitized_attributes[k]=v
        end
      end
      sanitized_attributes
    end

    def assign_simple_attributes(attributes, options)
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
