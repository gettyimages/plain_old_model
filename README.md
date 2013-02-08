# PlainOldModel

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'plain_old_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install plain_old_model

## Usage
Example
=======

class Person < Activeservice::Base
   attr_accessor :name, :age, :book

   attr_reader :account_number
   attr_writer :address

   validates_presence_of :book
end

 params = {"name" =>"testmeparams", "age" => "25", "book" =>["wewrwrwr", "werwrwrr"]}

 params1 = {:name =>"testmeparams", :age => "25", :book => {:author =>"my name", :category => "fiction"}}

p = Person.new(params)
  
p.book  # ["wewrwrwr", "werwrwrr"]

p.valid? #true

  OR
  
p = Person.new()

p.assign_attributes(params11)

=====================================================================
  p1 = Person.new(params1)

  p1.book # {:author =>"my name", :category => "fiction"}

  p.attributes #[:name, :age, :book, :account_number, :address]


TODO:

* Association(s)
* mass assignments
*

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
