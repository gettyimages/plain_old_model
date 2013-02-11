require 'active_support/all'
require 'active_model/validations'
require 'active_model/naming'
require 'active_model/translation'
require 'active_model/conversion'
require 'active_model/attribute_methods'
require 'active_model/serialization'
require 'active_model/serializers/json'
require 'active_model/mass_assignment_security'
require 'active_support/inflector'
module PlainOldModel
  class Base
    extend ActiveModel::Naming
    include ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::AttributeMethods
    include ActiveModel::Serializers::JSON
    include ActiveModel::MassAssignmentSecurity

    def initialize(attributes = nil, options = {})
      assign_attributes(attributes, options) if attributes
    end

    def self.has_one(attr_name, options={})
      if options[:class_name]
        association[attr_name] = options[:class_name].to_s.capitalize unless options[:class_name].nil?
      else
        association[attr_name] = attr_name.to_s.capitalize
      end
     attr_accessor attr_name
    end

    def self.association
      @association ||= {}
    end

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes
      association.each do |k,v|
        if new_attributes.include?(k)
          new_klass = k.to_s.camelcase.constantize.new(new_attributes[k])

          respond_to?("#{k}=") ? (send("#{k}=", new_klass)) : (instance_variable_set("@#{k}".to_sym,new_klass))
          new_attributes = new_attributes.delete_if {|key, value| key == k }
        end
      end
      assignment(new_attributes, options)
    end

    def assignment(attributes, options)
      attributes = sanitize_attributes(attributes).stringify_keys
      multi_parameter_attributes = []
      @mass_assignment_options = options

      attributes.each do |k, v|
        if k.include?("(")
          multi_parameter_attributes << [k, v]
        elsif respond_to?("#{k}=")
          send("#{k}=", v)
        elsif respond_to?("#{k}")
          instance_variable_set("@#{k}".to_sym,v)
        else
          raise(Exception)
        end
      end
    end

    def sanitize_attributes(attributes)
      sanitized_attributes = {}
      attributes.each do |k,v|
        if respond_to?("#{k}=") || respond_to?("#{k}")
          sanitized_attributes[k]=v
        end
      end
      sanitized_attributes
    end

    def persisted?
      false
    end

    def association
      self.class.association
    end

    def mass_assignment_options
      @mass_assignment_options ||= {}
    end

    def mass_assignment_role
      mass_assignment_options || :default
    end

  end

end