require 'spec_helper'

describe PlainOldModel::Base do


  describe "gem version" do
    it "should return the current version of the gem" do
      PlainOldModel::VERSION.should == '0.0.4'
    end
  end

  describe " assign_attribute and new" do
    it "should return all the attributes of the class instance even if they are not initialized" do
      @person = Person.new
      @person.attributes.count.should == 3
      @person.attributes.should == [:fname, :lname, :address]
      @address = Address.new
      @address.attributes.should == [:fname, :lname, :country, :read_test, :write_test]
    end
    it "should accept the params and new up a class with variables initialized" do
      @person= Person.new({:fname => "first value", :lname => "second value", :address => {:fname => 'fname', :lname => 'lname'}})
      @person.fname.should == "first value"
      @person.lname.should == "second value"
      @person.address.should == {:fname => 'fname', :lname => 'lname'}
    end
    it "should not assign value to the attr_reader attributes/ read only attribute" do
      @address = Address.new
      @address.assign_attributes({:fname => "first value", :lname => "second value", :read_test => 'This should not be assigned'})
      @address.read_test.should == nil
    end
    it "should assign value to the attr_writer attributes" do
      @address = Address.new
      @address.assign_attributes({:fname => "first value", :lname => "second value", :read_test => 'This should not be assigned',:write_test => "this shd be available"})
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
      @person= Person.new({:lname => "second value"})
      @person.valid?.should == false
      @person.errors.should_not  == nil
    end
  end

  describe "association" do
    it "should return empty hash for unassociated class" do
      @person = Person.new()
      @person.association.should == {}
    end
    it "should provide all the associations when the class has associations" do
      @address = Address.new()
      @address.association.should == {:country => "Country"}
    end
    it "should create a new instance and assign_attributes to the associated class" do
      @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India"}, :read_test => 'This should not be assigned',:write_test => "this shd be available"})
      @address.country.class.should == Country
    end
    it "should create the nested class instance and assign_attributes to the associated nested class" do
      @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India", :continent => {:name => "asia"}}, :read_test => 'This should not be assigned',:write_test => "this shd be available"})
      @address.country.continent.class.should == Continent
    end
    it "should create a new instance and assign_attributes to the associated class" do
      @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India", :continent => {:name => "asia", :desc => {:this => "is a test", :actual_desc => "is another test"}}}, :read_test => 'This should not be assigned',:write_test => "this shd be available"})
      @address.country.continent.class.should == Continent
      @address.country.continent.name.should == "asia"
      @continent = @address.country.continent
      @continent.name.should == "asia"
    end
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
  #has_one :address
  validates_presence_of :fname
end

class Address < PlainOldModel::Base
  attr_accessor :fname, :lname, :country
  attr_reader :read_test
  attr_writer :write_test

  has_one :country

end

class Country < PlainOldModel::Base
  attr_accessor :code, :name, :continent

  has_one :continent
end

class Continent < PlainOldModel::Base
  attr_accessor :name, :desc
end

