require_relative '../lib/plain_old_model/base'
class Book < PlainOldModel::Base

  attr_accessor :author, :category

end