require 'spec_helper'

RSpec.describe Affirm::AddressSerializer do
  let(:address) { create(:address, firstname: "John", lastname: "Do", zipcode: "58451") }
  let(:serializer) { Affirm::AddressSerializer.new(address, root: false) }
  subject { JSON.parse(serializer.to_json) }

  describe "name" do
    it "will be a composition with first -and lastname" do
      name_json = { "first" => "John", "last" => "Do" }
      expect(subject["name"]).to eql name_json
    end
  end

  describe "address" do
    it "will be a composition with the address fields" do
      address_json = {
        "line1" => "10 Lovely Street",
        "line2" => "Northwest",
        "city" => "Herndon",
        "state" => "AL",
        "zipcode" => "58451",
        "country" => "USA"
      }
      expect(subject["address"]).to eql address_json
    end
  end
end
