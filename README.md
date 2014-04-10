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

params = {"name" =>"Leo", :book => {:author =>"Tolstoy", :category => "fiction"}}


p = Person.new(params)

p.book 
p.valid? #true
```


### Mass Assignment ###

```ruby
p.assign_attributes({name: "Leo", book: {author: "Tolstoy", category: "fiction"}})
```

or

```ruby
p.attributes = {:name =>"Fyodor", :book => {:author =>"Tolstoy", :category => "fiction"}}
```


### Associations ###

* has_one 
* has_many 


