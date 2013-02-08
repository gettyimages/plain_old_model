require 'spec_helper'

describe PlainOldModel::Base do


  describe "gem version" do
    it "should return the current version of the gem" do
      PlainOldModel::VERSION.should == '0.0.1'
    end
  end

  describe " assign_attribute and new" do
    it "should return all the attributes of the class instance even if they are not initialized" do
      @person = Person.new
      @person.attributes.count.should == 3
      @person.attributes.should == [:fname, :lname, :address]
      @address = Address.new
      @address.attributes.should == [:fname, :lname, :country, :read_test, :write_test, :me]
    end
    it "should accept the params and new up a class with variables initialized" do
      @person= Person.new({:fname => "first value", :lname => "second value", :address => {:fname => 'fname', :lname => 'lname'}})
      @person.fname.should == "first value"
      @person.lname.should == "second value"
      @person.address.should == {:fname => 'fname', :lname => 'lname'}
    end
    it "should not assign value to the attr_reader attributes/ read only attribute" do
      @address = Address.new
      @address.assign_attributes({:fname => "first value", :lname => "second value", :country => 'India', :read_test => 'This should not be assigned'})
      @address.country.should == 'India'
      @address.read_test.should == nil
    end
    it "should assign value to the attr_writer attributes" do
      @address = Address.new
      @address.assign_attributes({:fname => "first value", :lname => "second value", :country => 'India', :read_test => 'This should not be assigned',:write_test => "this shd be available"})
      @address.country.should == 'India'
      @address.instance_variable_get(:@write_test).should == "this shd be available"
    end
    it "should assign_attributes to the class" do
      @person = Person.new
      @person.assign_attributes({:fname => "first value", :lname => "second value"})
      @person.fname.should == "first value"
      @person.lname.should == "second value"
    end
    it "should eliminate the params that are not available in the class" do
      @person= Person.new({:fname => "first value", :lname => "second value"})
      @person.valid?.should == true
    end
    it "should allow the class to use activemodel validations and errors" do
      @address = Address.new
      @address.assign_attributes({:fname => "first value", :lname => "second value"})
      @address.valid?.should == false
      @address.errors.should_not  == nil
    end
  end

  describe "association" do
    #it "should create a new instance and assign_attributes to the has_one class" do
    #  @person = Person.new({:fname => "first value", :lname => "second value",:address => {:fname => "test", :lname =>"testme",:country => "india"}})
    #end
  end
  describe "usage of activemodel classes " do
    #it "should allow model's naming properties" do
    #  @address = Address.new
    #  Address.model_name.should == "Address"
    #  @address.to_model.should == @addess
    #end
  end

end


class Person < PlainOldModel::Base
  attr_accessor :fname, :lname, :address

end

class Address < PlainOldModel::Base
  attr_accessor :fname, :lname, :country
  attr_reader :read_test
  attr_writer :write_test, :me

  #belongs_to :person
  validates_presence_of :country

end
