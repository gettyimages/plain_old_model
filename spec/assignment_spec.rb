require 'spec_helper'

describe PlainOldModel::Base do

  describe "creating a new model" do

    it "accepts the params and instantiate with variables initialized" do
      @person= Person.new(
        {:fname => "Tom",
         :address => {
            :city => 'Oso',
            :state => 'WA'
         }
      })
      @person.fname.should == "Tom"
      @person.address.should == {:city => 'Oso', :state => 'WA'}
    end

    it "eliminates the params that are not available in the class" do
      @person= Person.new({:fname => "Tom", :foo => "bar"})
      @person.valid?.should == true
      @person.instance_variable_get(:@foo).should == nil
    end

    it "supports activemodel validations" do
      @person= Person.new({:lname => "Jobim"})
      @person.valid?.should == false
      @person.errors.should_not == nil
    end

  end

  describe "assigning attributes to an existing model" do
    before(:each) do
      @address = Address.new
      @address.assign_attributes({:state => "WA"})
      @address.attributes = {:city => "Oakland"}
    end

    it "assigns value to the attr_reader attributes/ read only attribute" do
      @address.state.should == "WA"
    end

    it "supports the assignment operator syntax" do
      @address.city.should == "Oakland"
    end

  end
end

