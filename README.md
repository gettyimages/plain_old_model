# PlainOldModel #

Implements nested attribute mass-assignment and has_many and has_one associations, and also pulls in:

* ActiveModel::Naming
* ActiveModel::Translation
* ActiveModel::Validations
* ActiveModel::Conversion


## Installation ##

Add this line to your application's Gemfile:

    gem 'plain_old_model'

## Usage ##

    class Person < PlainOldModel::Base
      attr_accessor :name
      validates_presence_of :book
    end

    params = {"name" =>"Leo", :book => {:author =>"Tolstoy", :category => "fiction"}}

## Initialization ##

    p = Person.new(params)

    p.valid? #true


## Mass Assignment ##

    p.assign_attributes({:name =>"Leo", :age => "25", :book => {:author =>"Tolstoy", :category => "fiction"}})

or

    p.attributes = {:name =>"Fyodor", :book => {:author =>"Tolstoy", :category => "fiction"}}


## Associations ##

* has_one 
* has_many 


