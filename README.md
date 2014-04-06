# PlainOldModel

Implements attribute assignment and basic associations for ActiveModel, and also pulls in:

ActiveModel::Naming
ActiveModel::Translation
ActiveModel::Validations
ActiveModel::Conversion


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

class Person < PlainOldModel::Base
  attr_accessor :name, :age, :book
  validates_presence_of :book
end

params = {"name" =>"Leo", "age" => "25", "book" =>["War and Peace", "Tolstoy"]}


p = Person.new(params)
  
p.book  # ["wewrwrwr", "werwrwrr"]

p.valid? #true

  OR
  
p = Person.new()

p.assign_attributes {:name =>"Leo", :age => "25", :book => {:author =>"Tolstoy", :category => "fiction"}}

=====================================================================
  p1 = Person.new(params1)

  p1.book # {:author =>"my name", :category => "fiction"}

  p.attributes #[:name, :age, :book, :account_number, :address]


TODO:

- mass assignments

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
