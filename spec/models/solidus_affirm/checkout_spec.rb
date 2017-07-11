require 'spec_helper'

RSpec.describe SolidusAffirm::Checkout do
  subject { SolidusAffirm::Checkout.new }

  describe "#reusable?" do
    it "is never reusable" do
      expect(subject.reusable?).to eq(false)
    end
  end

  it "supports the capture, void and credit actions" do
    expect(subject.actions).to eql ["capture", "void", "credit"]
  end
end
