require_relative '../lib/plain_old_model/base'
require_relative'book'
class Person < PlainOldModel::Base
  attr_accessor :name, :age, :book

  attr_reader :test
  attr_writer :testmewriter

  has_one :book, :class_name => :book

  validates_presence_of :name ,:message => "The field is a required field"
end


#params = { :person =>{:name =>"testme", :age => "25"}, :commit=>"Create Person"}
params = {"name1" =>"testmeparams", "age" => "25", "book" =>["wewrwrwr", "werwrwrr"], :erre =>"wewrwrwrw"}
params1 = {:name1 =>"testmeparams", :age => "25", :book => {:author =>"my name", :category => "fiction"}}

params11 = {:name =>"testmeparamsnew", :age => "28", :book => {:author =>"my new name", :category => "science fiction"}}

#puts params.inspect
#params = params.with_indifferent_access
#puts params.inspect
#p = Person.new



p = Person.new(params1)
p.valid?
#@book = Book.new
p.assign_attributes(params11)
puts p.book

#@book.assign_attributes(p.book)
p1 = Person.new(params1)
puts p.attributes
puts p.attributes.inspect
puts p.errors.values.inspect
puts p.inspect
puts p1.inspect

p2 = Person.new

p2.attributes

