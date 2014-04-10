require 'spec_helper'

describe PlainOldModel::Base do

  describe "associations" do

    it "returns empty array for unassociated class" do
      continent = Continent.new
      continent.associations.should == []
    end

    it "provides all the associations when the class has associations" do
      address = Address.new
      address.associations.length.should == 1
      address.associations.first.attr_name.should == :country
    end

    describe "a has_one association" do
      before(:each) do
        @address = Address.new(
          {
            :city => "Mumbai",
            :state => "Maharashtra",
            :country => {
              :code => "In", :name => "India",
              :continent => {:name => "Asia", :desc => {:actual_desc => "big"}}}})
      end

      it "assigns attributes to the associated class" do
        @address.country.class.should == Country
      end

      it "creates the nested class instance and assign_attributes to the associated nested class" do
        @address.country.continent.class.should == Continent
      end

      it "creates a new instance and assign_attributes to the associated class" do
        @address.country.continent.name.should == "Asia"
      end

      it "assigns values to the read only attributes" do
        address = Address.new(
          {
            :city => "Mumbai",
            :state => "Maharashtra",
            :country => {:code => "In", :name => "India"},
            :readable => 'yes'
          })
        address.readable.should == "yes"
      end

      it "overrides assigned attributes" do
        address = Address.new(
          {
            :city => "Mumbai",
            :country => {:code => "In", :name => "India"},
            :readable => 'should be assigned'})
        address.assign_attributes(
          {
            :city => "Oso",
            :country => {:code => "USA", :name => "United States"}
          })
        address.city.should == "Oso"
        address.country.code.should == "USA"
        address.country.name.should == "United States"
        address.readable.should == "should be assigned"
      end

      it "should not overwrite unassigned nested attributes" do
        address = Address.new(
          {
            :city => "Mumbai",
            :state => "Maharashtra",
            :country => {:code => "In", :name => "India"}})
        address.assign_attributes({:city => "Bangalore"})
        address.city.should == "Bangalore"
        address.country.code.should == "In"
        address.country.name.should == "India"
      end

      it "should not overwrite unassigned nested attributes' values" do
        address = Address.new(
          {
            :city => "Mumbai",
            :country => {:code => "In", :name => "India", :continent => {:name => "asia" }},
            :readable => 'yes'})
        address.assign_attributes(
          {"city" => "Oso",
           :country => {:name => "United States", :continent => {:desc => {:text => "large landmass"}}}})
        address.city.should == "Oso"
        address.country.code.should == "In"
        address.country.name.should == "United States"
        address.country.continent.name.should == "asia"
        address.readable.should == "yes"
      end

      it "creates assigned nested attributes" do
        address = Address.new({:state => "AK", :readable => 'should be assigned'})
        address.assign_attributes({"city" => "Oso", :country => {:code => "In", :name => "India"} })
        address.city.should == "Oso"
        address.country.code.should == "In"
        address.country.name.should == "India"
        address.readable.should == "should be assigned"
      end

      it "should assigned nested attributes with mixed string and symbol hash keys" do
        address = Address.new(
          {
            :city => "Seattle",
            :country => {:code => "US", :name => "USA"},
            :readable => 'should be assigned'
          })
        address.attributes = {:city => "Mumbai", :country => {"code" => "In", "name" => "India"} }
        address.city.should == "Mumbai"
        address.country.code.should == "In"
        address.country.name.should == "India"
        address.readable.should == "should be assigned"
      end

    end

    describe "construction of a model with a has_many association" do

      it "should create a new instance and assign attributes for each value in array" do
        person = Person.new({ addresses: [{ city: "Oso", state: "WA"},
                                          { city: "Oakland", state: "CA"}]})
        person.addresses.first.class.should == Address
        person.addresses.first.city.should == "Oso"
        person.addresses.first.state.should == "WA"
        person.addresses[1].class.should == Address
        person.addresses[1].city.should == "Oakland"
        person.addresses[1].state.should == "CA"
      end
    end

    describe "assignment to a model with a has_many association" do


      it "should not alter the params passed in" do
        passed_params = { addresses: [
          { :city => "Oso", :state => "WA"},
          { :city => "Oakland", :state => "CA"}
        ]}
        person = Person.new(passed_params)
        person.addresses.length.should == 2
        person.addresses.first.class.should == Address
        person.addresses.first.city.should == "Oso"
        passed_params.should == { addresses: [
          { :city => "Oso", :state => "WA"},
          { :city => "Oakland", :state => "CA"}
        ]}
      end

      it "should create each class via factory_method if one is specified" do
        person = Person.new({ phones: [{ number: '5841'}, {number: '9139'}]})
        person.phones.length.should == 2
        person.phones[0].number.should == '5841'
        person.phones[0].extension.should == 'set_via_factory'
        person.phones[1].extension.should == 'set_via_factory'
      end
    end

    describe "mass-assignment to a model with a has_many association" do
      before(:all) do
        @person = Person.new({addresses: [
              {
                :state => "Gujarat",
                :country => {
                  :continent => {:name => "Asia"}}
              },
              {
                :state => "AK",
              }]})

        @person.attributes = {addresses: [
              {
                :city => "Surat",
                :country => {
                  :name => "India",
                  :continent => {:desc => "large"}
                }
              },
              {
                state: "CA"
              }]}
      end

      it "should overwrite assigned nested attributes' values" do
        @person.addresses.last.state.should == "CA"
        @person.addresses.first.country.name.should == "India"
      end

      it "should not affect unassigned nested attributes' values" do
        @person.addresses.first.state.should == "Gujarat"
        @person.addresses.first.country.continent.name.should == "Asia"
      end

    end
  end
end


