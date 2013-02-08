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

    # refactor this later to single method to gather all attributes
    def self.attr_accessor(*attrs)
      gather_attributes(attrs)
      super(*attrs)
    end

    def self.attr_writer(*attrs)
      gather_attributes(attrs)
      super(*attrs)
    end

    def self.attr_reader(*attrs)
      gather_attributes(attrs)
      super(*attrs)
    end

    def self.attributes
      @attributes ||= []
    end

    def self.gather_attributes(attrs)
      attributes.concat attrs
    end

    def initialize(attributes = nil, options = {})
      options[:new_record]= true
      assign_attributes(attributes, options) if attributes
    end

    #creation attributes ->create the class referred , and assign the variables

    def self.associated_class(klass, options={})
      @association = {}
      if options[:class_name]
        @association[klass] = options[:class_name].to_s.capitalize unless options[:class_name].nil?
      else
        @association[klass] = klass.to_s.capitalize
      end
      @association
    end

    def self.association
      @association
    end

    def assign_attributes(new_attributes, options = {})
      return unless new_attributes

      attributes = sanitize_attributes(new_attributes).stringify_keys
      multi_parameter_attributes = []
      @mass_assignment_options = options

      attributes.each do |k, v|
        if k.include?("(")
          multi_parameter_attributes << [ k, v ]
        elsif respond_to?("#{k}=")
          send("#{k}=", v)
        else
          raise(Exception)
        end
      end
    end

    def sanitize_attributes(attributes)
      sanitized_attributes = {}
      attributes.each do |k,v|
        if respond_to?("#{k}=")
          sanitized_attributes[k]=v
        end
      end
      sanitized_attributes
    end

    def persisted?
      false
    end

    def attributes
      self.class.attributes
    end

    def mass_assignment_options
      @mass_assignment_options ||= {}
    end

    def mass_assignment_role
      mass_assignment_options || :default
    end

  end

end