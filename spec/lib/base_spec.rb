require 'spec_helper'

describe PlainOldModel::Base do

  describe " assign_attribute and new" do
    it "should accept the params and new up a class with variables initialized" do
      @person= Person.new({:fname => "first value", :lname => "second value", :address => {:fname => 'fname', :lname => 'lname'}})
      @person.fname.should == "first value"
      @person.lname.should == "second value"
      @person.address.should == {:fname => 'fname', :lname => 'lname'}
    end
    it "should assign value to the attr_reader attributes/ read only attribute" do
      @address = Address.new
      @address.fname = "first value"
      @address.assign_attributes({:lname => "second value", :read_test => 'This should be assigned'})
      @address.fname.should == "first value"
      @address.read_test.should == "This should be assigned"
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

  describe "associations" do
    it "should return empty array for unassociated class" do
      @person = Continent.new
      @person.associations.should == []
    end
    it "should provide all the associations when the class has associations" do
      @address = Address.new
      @address.associations.length.should == 1
      @address.associations.first.attr_name.should == :country
    end
    describe "has_one" do
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
      it "should assign values to the read only attributes" do
        @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India"}, :read_test => 'This should be assigned',:write_test => "this shd be available"})
        @address.read_test.should == "This should be assigned"
      end
      it "should override assigned attributes" do
        @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India"}, :read_test => 'This should be assigned',:write_test => "this shd be available"})
        @address.assign_attributes({:fname => "replaced first value", :lname => "replaced second value", :country => {:code => "USA", :name => "United States"}})
        @address.fname.should == "replaced first value"
        @address.country.code.should == "USA"
        @address.country.name.should == "United States"
        @address.read_test.should == "This should be assigned"
      end
      it "should not override unassigned nested attributes" do
        @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India"}, :read_test => 'This should be assigned',:write_test => "this shd be available"})
        @address.assign_attributes({:fname => "replaced first value", :lname => "replaced second value"})
        @address.fname.should == "replaced first value"
        @address.country.code.should == "In"
        @address.country.name.should == "India"
        @address.read_test.should == "This should be assigned"
      end
      it "should not override unassigned nested attributes' values" do
        @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "In", :name => "India", :continent => {:name => "asia", :desc => {:this => "is a test", :actual_desc => "is another test"}}}, :read_test => 'This should be assigned',:write_test => "this shd be available"})
        @address.assign_attributes({"fname" => "replaced first value", :lname => "replaced second value", :country => {:name => "United States", :continent => {:desc => {:this => "is a replacement", :actual_desc => "is another replacement"}}}})
        @address.fname.should == "replaced first value"
        @address.country.code.should == "In"
        @address.country.name.should == "United States"
        @address.country.continent.name.should == "asia"
        @address.read_test.should == "This should be assigned"
      end
      it "should create assigned nested attributes" do
        @address = Address.new({:lname => "second value", :read_test => 'This should be assigned',:write_test => "this shd be available"})
        @address.assign_attributes({"fname" => "first value", :lname => "replaced second value", :country => {:code => "In", :name => "India"} })
        @address.fname.should == "first value"
        @address.country.code.should == "In"
        @address.country.name.should == "India"
        @address.read_test.should == "This should be assigned"
      end
      it "should assigned nested attributes with mixed string and symbol hash keys" do
        @address = Address.new({:fname => "first value", :lname => "second value", :country => {:code => "", :name => ""}, :read_test => 'This should be assigned',:write_test => "this shd be available"})
        @address.assign_attributes({:fname => "replaced first value", :lname => "replaced second value", :country => {"code" => "In", "name" => "India"} })
        @address.fname.should == "replaced first value"
        @address.country.code.should == "In"
        @address.country.name.should == "India"
        @address.read_test.should == "This should be assigned"
      end
    end

    describe "has_many" do
      it "should create a new instance and assign attributes for each value in array" do
        @person = Person.new({ addresses: [{ fname: "first name 1", lname: "last name 1"}, { fname: "first name 2", lname: "last name 2"}]})
        @person.addresses.length.should == 2
        @person.addresses.first.class.should == Address
        @person.addresses.first.fname.should == "first name 1"
        @person.addresses.first.lname.should == "last name 1"
        @person.addresses[1].class.should == Address
        @person.addresses[1].fname.should == "first name 2"
        @person.addresses[1].lname.should == "last name 2"
      end
      it "should not alter the params passed in" do
        passed_params = { addresses: [{ fname: "first name 1", lname: "last name 1"}, { fname: "first name 2", lname: "last name 2"}]}
        @person = Person.new(passed_params)
        @person.addresses.length.should == 2
        @person.addresses.first.class.should == Address
        @person.addresses.first.fname.should == "first name 1"
        passed_params.should == { addresses: [{ fname: "first name 1", lname: "last name 1"}, { fname: "first name 2", lname: "last name 2"}]}
      end
      it "should create each class via factory_method if one is specified" do
        @person = Person.new({ phones: [{ number: '423-5841'}, {number: '383-9139'}]})
        @person.phones.length.should == 2
        @person.phones[0].number.should == '423-5841'
        @person.phones[0].extension.should == 'set_via_factory'
        @person.phones[1].extension.should == 'set_via_factory'
      end
      it "should not override unassigned nested attributes' values" do
        @person = Person.new({ addresses: [{ fname: "first name 1", lname: "last name 1", :country => {:code => "In", :name => "India", :continent => {:name => "asia", :desc => {:this => "is a test", :actual_desc => "is another test"}}}}, { fname: "first name 2", lname: "last name 2"}]})
        @person.assign_attributes({ addresses: [{ fname: "first name 1", :country => {:name => "United States", :continent => {:desc => {:this => "is a replacement", :actual_desc => "is another replacement"}}}}, { fname: "first name 2", lname: "last name 2"}]})
        @person.addresses.first.lname.should == "last name 1"
        @person.addresses.last.lname.should == "last name 2"
        @person.addresses.first.country.name.should == "United States"
        @person.addresses.first.country.continent.name.should == "asia"
      end
    end
  end
end

class Person < PlainOldModel::Base
  attr_accessor :fname, :lname, :address
  has_many :addresses
  has_many :phones, factory_method: :create
  validates_presence_of :fname
end

class Phone < PlainOldModel::Base
  attr_accessor :number, :extension

  def self.create(attributes)
    attributes[:extension] = 'set_via_factory'
    new(attributes)
  end
end

class Address < PlainOldModel::Base
  attr_accessor :fname, :lname
  attr_reader :read_test
  attr_writer :write_test

  has_one :country
end

class Country < PlainOldModel::Base
  attr_accessor :code, :name

  has_one :continent
end

class Continent < PlainOldModel::Base
  attr_accessor :name, :desc
end

