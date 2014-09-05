# PlainOldModel #

Implements nested attribute mass-assignment and has_many and has_one associations, and also pulls in:

* ActiveModel::Naming
* ActiveModel::Translation
* ActiveModel::Validations
* ActiveModel::Conversion


### Installation ###

Add this line to your application's Gemfile:

```ruby
gem install plain_old_model
```

or run

```ruby
gem 'plain_old_model'
```


### Usage ###

```ruby
class Person < PlainOldModel::Base
  attr_accessor :name
  validates_presence_of :book
end

params = {"name" =>"Anna", :book => {:author =>"Tolstoy", :category => "fiction"}}


p = Person.new(params)

p.book 
p.valid? #true
```


### Mass Assignment ###

```ruby
p.assign_attributes({name: "Anna", book: {author: "Tolstoy", category: "fiction"}})
```

or

```ruby
p.attributes = {:name =>"Anna", :book => {:author =>"Tolstoy", :category => "fiction"}}
```


### Associations ###

* has_one 
* has_many 

```ruby
class Person < PlainOldModel::Base
  has_many :phones
end
```
or, with optional factory_method and class_name:

```ruby
class Person < PlainOldModel::Base
  has_many :phones, factory_method: :create, class_name: :telephone
end

class Telephone < PlainOldModel::Base
  attr_accessor :number, :extension

  def self.create(attributes)
    attributes[:extension] = '000'
    new(attributes)
  end
end
```


