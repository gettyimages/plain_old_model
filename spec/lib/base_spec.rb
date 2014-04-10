require 'spec_helper'

describe PlainOldModel::Base do

  describe "assign_attribute and new" do

    it "should accept the params and new up a class with variables initialized" do
      @person= Person.new({:fname => "first value", :lname => "second value", :address => {:fname => 'fname', :lname => 'lname'}})
      @person.persisted?.should == false
    end

  end
end
