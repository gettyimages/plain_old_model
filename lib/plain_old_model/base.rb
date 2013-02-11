require 'active_model/naming'
require 'active_model/translation'
require 'active_model/validations'
require 'active_model/conversion'
require 'plain_old_model/attribute_assignment'

module PlainOldModel
  class Base
    extend ActiveModel::Naming
    include ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include PlainOldModel::AttributeAssignment

    def initialize(attributes = nil, options = {})
      assign_attributes(attributes, options) if attributes
    end

    def persisted?
      false
    end

  end

end