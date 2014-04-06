module PlainOldModel
  module Associations
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

    def merge_association_instance_variables_with_attributes(association, attr_name, attributes)
      association_instance = send(attr_name)

      if association.class == HasOneAssociation
        merged_hash = instance_hash(association_instance).deep_merge(attributes[attr_name])
      elsif association.class == HasManyAssociation
        association_instance_array = []
        if association_instance.nil?
          merged_hash = attributes[attr_name]
        else
          association_instance.each_with_index do |instance, i|
            association_instance_array << instance_hash(instance).deep_merge(attributes[attr_name][i])
          end
          merged_hash = association_instance_array
        end
      end
    end

    def instance_hash(association_instance)
      hash = HashWithIndifferentAccess.new
      unless association_instance.nil?
        association_instance.instance_variables.each do |var|
          if association_instance.instance_variable_get(var).instance_variables.length > 0
            hash[var.to_s.delete("@")] = instance_hash(association_instance.instance_variable_get(var))
          else
            hash[var.to_s.delete("@")] = association_instance.instance_variable_get(var)
          end
        end
      end
      hash
    end

  end
end
