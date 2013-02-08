require_relative '../lib/activeservice/base'
class Book < PlainOldModel::Base

  attr_accessor :author, :category

end